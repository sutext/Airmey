//
//  HTTPTask.swift
//  Airmey
//
//  Created by supertext on 2021/6/09.
//  Copyright © 2021年 airmey. All rights reserved.
//

import Foundation

/// `Request` is the common superclass of all request types and provides common state  and callback handling.
/// - Note provides progress interface for any request
open class HTTPTask{
    private(set) var task:URLSessionTask
    @Protected
    private var mutableData: Data? = nil
    private let session:Session
    let decoder:HTTPDecoder
    let completion:HTTPFinish?
    init(
        _ task:URLSessionTask,
        session:Session,
        retrier:Retrier?,
        decoder:HTTPDecoder,
        completion:HTTPFinish?){
        self.task = task
        self.session = session
        self.completion = completion
        self.retrier  = retrier
        self.decoder = decoder
    }
    /// some error if occured
    public internal(set) var error:Error?
    /// current retrier if present
    public internal(set) var retrier:Retrier?
    /// the metrics of current task
    public internal(set) var metrics:URLSessionTaskMetrics?
    /// the unique identifier of current request
    public var id:Int { task.taskIdentifier }
    /// the response data
    public var data:Data?{ mutableData }
    /// the current task state
    public var state:URLSessionTask.State{ task.state }
    /// the current url request
    public var request:URLRequest? { task.originalRequest }
    /// the curren task progress
    public var progress:Progress { task.progress }
    /// the current http url respone
    public var response:HTTPURLResponse?{ task.response as? HTTPURLResponse }
    /// the current http status code
    public var statusCode:Int?{  response?.statusCode  }
    /// the current http method
    public var method:HTTPMethod? {
        guard let str = request?.httpMethod else {
            return nil
        }
        return .init(rawValue: str)
    }
    public func resume()  {
        task.resume()
    }
    public func cancel()  {
        task.cancel()
    }
    public func suspend()  {
        task.suspend()
    }
    func append(_ data:Data) {
        $mutableData.write {
            if $0 == nil {
                $0 = data
            } else {
                $0?.append(data)
            }
        }
    }
    func finish(_ error:Error?)->TimeInterval? {
        guard case .completed = state else {
            return nil
        }
        self.error = error
        if let error = error {
            return self.retry(when: error)
        }
        guard let resp = response else {
            let error = HTTPError.invalidResponse(resp: task.response)
            self.error = error
            return self.retry(when: error)
        }
        do {
            let json = try decoder.decode(data,response: resp)
            let response = Response<JSON>(data: json, task: self, result: .success(json))
            self.completion?(response)
            return nil
        } catch {
            self.error = error
            return self.retry(when: error)
        }
    }
    func retry(when error:Error)->TimeInterval?{
        guard let delay = self.retrier?.doRetry(self, when: error) else {
            let response = Response<JSON>(data: .null, task: self, result: .failure(error))
            self.completion?(response)
            return nil
        }
        return delay
    }
    func restart(req:URLRequest? = nil) {
        guard case .completed = state else{
            return
        }
        guard let req = req ?? task.originalRequest else {
            return
        }
        self.mutableData = nil
        self.metrics = nil
        self.error = nil
        self.task = self.session.session.dataTask(with: req)
        self.session.add(self)
    }
    func cleanup(){
        
    }
}
public class UploadTask:HTTPTask{
    private var fileManager:FileManager
    var cleanupFile:URL?
    init(
        _ task: URLSessionTask,
        session:Session,
        decoder:HTTPDecoder,
        fileManager: FileManager,
        completion:HTTPFinish?) {
        self.fileManager = fileManager
        super.init(task,session: session, retrier: nil,decoder: decoder,completion: completion)
    }
    override func cleanup() {
        super.cleanup()
        if let url = cleanupFile {
            try? fileManager.removeItem(at: url)
        }
    }
}
extension URLRequest{
    public mutating func setHeader(_ value:String,for field:HTTPHeaders.Field){
        setValue(value, forHTTPHeaderField: field.rawValue)
    }
    public func header(for field:HTTPHeaders.Field)->String?{
        return value(forHTTPHeaderField: field.rawValue)
    }
}
public class DownloadTask:HTTPTask{
    /// temp file url transfer
    public typealias URLTransfer = (_ tempURL:URL,_ response:HTTPURLResponse?) -> URL
    private var fileManager:FileManager
    private let transfer:URLTransfer
    private var fileURL:URL?
    init(
        _ task: URLSessionDownloadTask,
        session:Session,
        transfer: URLTransfer?,
        fileManager:FileManager,
        completion:HTTPFinish?) {
        self.transfer = transfer ?? {url,_ in
            let filename = "Airmey_\(url.lastPathComponent)"
            let destination = url.deletingLastPathComponent().appendingPathComponent(filename)
            return destination
        }
        self.fileManager = fileManager
        super.init(task, session: session,retrier: nil,decoder: HTTP.JSONDecoder(),completion: completion)
    }
    override func finish(_ error: Error?) -> TimeInterval? {
        guard case .completed = state else {
            return nil
        }
        if error != nil{
            self.error = error
        }
        if let error = self.error {
            return self.retry(when: error)
        }
        guard let resp = response else {
            return self.retry(when: HTTPError.invalidResponse(resp: task.response))
        }
        guard let code = statusCode,code == 200 else {
            let error = HTTPError.invalidStatus(code:resp.statusCode, info: .null)
            return self.retry(when: error)
        }
        guard let location = self.fileURL?.absoluteString else {
            return retry(when: HTTPError.download(info:"invalid destination file url"))
        }
        self.completion?(Response<JSON>(data: .null, task: self, result: .success(JSON(location))))
        return nil
    }
    func finishDownload(_ location:URL){
        let destination = transfer(location,response)
        do {
            try? fileManager.removeItem(at: destination)
            let directory = destination.deletingLastPathComponent()
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
            try fileManager.moveItem(at: location, to: destination)
            self.fileURL = destination
        } catch {
            self.error = error
        }
    }
    /// cancel dirctly without resume data
    public override func cancel() {
        self.cancel(resumer: nil)
    }
    /// cancel a donwload task and get the resume data
    public func cancel(resumer:((Data?)->Void)?){
        guard task.state != .completed else {
            return
        }
        guard let task = task as? URLSessionDownloadTask else {
            return
        }
        guard let block = resumer else {
            task.cancel { _ in }
            return
        }
        task.cancel(byProducingResumeData: block)
    }
}

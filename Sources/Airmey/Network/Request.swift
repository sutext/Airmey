//
//  Request.swift
//  Airmey
//
//  Created by supertext on 2021/6/09.
//  Copyright © 2021年 airmey. All rights reserved.
//

import UIKit
open class Request{
    typealias Handler = (Response<JSON>)->Void
    public typealias ONProgress = (Progress) -> Void
    private(set) var task:URLSessionTask
    private let handler:Handler?
    private var progressHandlers:[ONProgress] = []
    var error:Error?
    public private(set) var retrier:HTTPRetrier?
    @Protected
    private var mutableData: Data? = nil
    var metrics:URLSessionTaskMetrics?
    init(
        _ task:URLSessionTask,
        handler:Handler?,
        retrier:HTTPRetrier?){
        self.task = task
        self.handler = handler
        self.retrier  = retrier
    }
    public var method:HTTPMethod? {
        guard let str = request?.httpMethod else {
            return nil
        }
        return .init(rawValue: str)
    }
    public var statusCode:Int?{
        response?.statusCode
    }
    public var response:HTTPURLResponse?{
        task.response as? HTTPURLResponse
    }
    public var request:URLRequest?{ task.originalRequest }
    public var progress:Progress { task.progress }
    public var data:Data?{ mutableData }
    public var taskIdentifier:Int { task.taskIdentifier }
    public var state:URLSessionTask.State{
        self.task.state
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
    public func onProgress(handler:ONProgress?){
        if let handler = handler {
            self.progressHandlers.append(handler)
        }
    }
    func updateProgress(){
        self.progressHandlers.forEach{$0(self.progress)}
    }
    func append(_ data:Data) {
        if self.data == nil {
            mutableData = data
        } else {
            $mutableData.write { $0?.append(data) }
        }
    }
    func finish(_ error:Error?)->HTTPRetrier.Result {
        guard task.state == .completed else {
            fatalError("finis task when task did not completed")
        }
        self.error = error
        // success callback directly
        guard let error = error else{
            var result:Result<JSON,Error>
            if let data = data {
                result = .init{try JSON.parse(data)}
            }else{
                result = .success(.null)
            }
            let response = Response<JSON>(data: data, result: result, request: task.originalRequest, metrics: metrics,response: task.response)
            self.handler?(response)
            return .not
        }
        // when some error consider retry
        
        guard let result = self.retrier?.doRetry(self, when: error),
              result != .not else {
            let response = Response<JSON>(data: data, result: .failure(error), request: task.originalRequest, metrics: metrics,response: task.response)
            self.handler?(response)
            return .not
        }
        return result
    }
    func reset(task:URLSessionTask) {
        self.mutableData = nil
        self.metrics = nil
        self.error = nil
        self.task = task
    }
    func cleanup(){
        progressHandlers = []
    }
}
public class Upload:Request{
    private var fileManager:FileManager
    var cleanupFile:URL?
    init(_ task: URLSessionTask, handler: Request.Handler?, fileManager: FileManager) {
        self.fileManager = fileManager
        super.init(task, handler: handler, retrier: nil)
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
}
public class Download:Request{
    public typealias URLTransfer = (_ tempURL:URL,_ response:HTTPURLResponse?) -> URL
    public static let defaultTransfer:URLTransfer = {url,_ in
        let filename = "Airmey_\(url.lastPathComponent)"
        return url.deletingLastPathComponent().appendingPathComponent(filename)
    }
    private var fileManager:FileManager
    let transfer:URLTransfer
    var fileURL:URL?
    init(_ task: URLSessionDownloadTask,transfer: @escaping URLTransfer,fileManager:FileManager) {
        self.transfer = transfer
        self.fileManager = fileManager
        super.init(task, handler: nil, retrier: nil)
    }
    func finishDownload(_ location:URL){
        let destination = transfer(location,response)
        do {
            try fileManager.removeItem(at: destination)
            let directory = destination.deletingLastPathComponent()
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
            try fileManager.moveItem(at: location, to: destination)
            self.fileURL = destination
        } catch {
            self.error = error
        }
    }
    public override func cancel() {
        self.cancel(needResume: false)
    }
    public func cancel(needResume:Bool){
        self.cancel(resumer: needResume ? { _ in } : nil)
    }
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
        task.cancel {
            block($0)
        }
    }
}

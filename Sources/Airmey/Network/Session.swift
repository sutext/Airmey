//
//  Session.swift
//  Airmey
//
//  Created by supertext on 2021/6/09.
//  Copyright © 2021年 airmey. All rights reserved.
//

import Foundation

class Session:NSObject{
    private let rootQueue:DispatchQueue = .init(label: "com.airmey.network.rootQueue")
    private let retryQueue:DispatchQueue = .init(label: "com.airmey.network.retryQueue")
    private var requests:[Int:Request] = [:]
    private lazy var session:URLSession = {
        let config = URLSessionConfiguration.default
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.underlyingQueue = rootQueue
        queue.name = "com.airmey.network.delegateQueue"
        queue.qualityOfService = .default
        return URLSession(configuration: config,delegate: self,delegateQueue: queue)
    }()
    func request(
        _ url:URL,
        method:HTTPMethod = .post,
        params:HTTPParams?=nil,
        headers:HTTPHeaders = .default,
        encoder:HTTPEncoder = JSNEncoder(),
        retrier:Retrier? = nil,
        timeout:TimeInterval = 60,
        completion:((Response<JSON>)->Void)?=nil)->Request?{
        let result = encoder.encode(url, method: method, params: params, headers: headers, timeout: timeout)
        guard let urlreq = result.value else{
            let result:Result<JSON,Swift.Error> = .failure(HTTPError.encode(result.error!))
            completion?(Response<JSON>(result: result))
            return nil
        }
        let task = self.session.dataTask(with: urlreq)
        let req = Request(task,retrier: retrier,completion: completion)
        self.add(req)
        return req
    }
    func upload(
        _ url:URL,
        file:URL,
        params:HTTPParams? = nil,
        headers:HTTPHeaders? = nil,
        fileManager:FileManager = .default,
        completion:((Response<JSON>)->Void)?=nil)->Request?{
        let result = URLEncoder.query.encode(url, method: .post, params: params, headers: headers, timeout: 0)
        guard let urlreq = result.value else{
            let result:Result<JSON,Swift.Error> = .failure(HTTPError.encode(result.error!))
            completion?(Response<JSON>(result: result))
            return nil
        }
        let task = self.session.uploadTask(with: urlreq, fromFile: file)
        let req = Upload(task,fileManager: fileManager,completion: completion)
        self.add(req)
        return req
    }
    func upload(
        _ url:URL,
        form:FormData,
        params:HTTPParams?=nil,
        headers:HTTPHeaders? = nil,
        fileManager:FileManager = .default,
        completion:((Response<JSON>)->Void)?=nil)->Request?{
        let result = URLEncoder.query.encode(url, method: .post, params: params, headers: headers, timeout: 0)
        guard var urlreq = result.value else{
            let result:Result<JSON,Swift.Error> = .failure(HTTPError.encode(result.error!))
            completion?(Response<JSON>(result: result))
            return nil
        }
        urlreq.setHeader(form.contentType, for: .contentType)
        do {
            let upload = try form.toUpload()
            var req:Upload
            switch upload {
            case .data(let data):
                let task = self.session.uploadTask(with: urlreq, from: data)
                req = Upload(task,fileManager: form.fileManager,completion: completion)
            case .file(let fileURL):
                let task = self.session.uploadTask(with: urlreq, fromFile: fileURL)
                req = Upload(task,fileManager: form.fileManager,completion: completion)
                req.cleanupFile = fileURL
            }
            self.add(req)
            return req
        } catch {
            let result:Result<JSON,Swift.Error> = .failure(error)
            completion?(Response<JSON>(result: result))
            return nil
        }
    }
    func download(
        resume data: Data,
        fileManager:FileManager = .default,
        transfer:@escaping Download.URLTransfer = Download.defaultTransfer,
        completion:((Response<JSON>)->Void)?)->Download?{
        let task = self.session.downloadTask(withResumeData: data)
        let req = Download(task, transfer: transfer, fileManager: fileManager,completion: completion)
        self.add(req)
        return req
    }
    func download(
        _ url: URL,
        params:HTTPParams? = nil,
        headers:HTTPHeaders? = nil,
        fileManager:FileManager = .default,
        transfer:@escaping Download.URLTransfer = Download.defaultTransfer,
        completion:((Response<JSON>)->Void)?)->Download?{
        let result = URLEncoder.query.encode(url, method: .get, params: params, headers: headers, timeout: 0)
        guard let urlreq = result.value else{
            let result:Result<JSON,Swift.Error> = .failure(HTTPError.encode(result.error!))
            completion?(Response<JSON>(result: result))
            return nil
        }
        let task = self.session.downloadTask(with: urlreq)
        let req = Download(task, transfer: transfer, fileManager: fileManager,completion: completion)
        self.add(req)
        return req
    }
}

extension Session{
    func add(_ req:Request) {
        self.requests[req.id] = req
        req.resume()
    }
    func remove(_ req:Request){
        self.requests.removeValue(forKey: req.id)
    }
    func restart(_ req:Request,after:TimeInterval = 0){
        retryQueue.asyncAfter(deadline: .now()+after) {
            req.reset(task: self.session.dataTask(with: req.request!))
            self.add(req)
        }
    }
}
extension Session:URLSessionTaskDelegate{
    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        if let req = self.requests[task.taskIdentifier] {
            req.metrics = metrics
        }
    }
}
extension Session:URLSessionDataDelegate{
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if let req = self.requests[dataTask.taskIdentifier] {
            req.append(data)
        }
    }
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Swift.Error?) {
        if let req = self.requests[task.taskIdentifier] {
            if let delay = req.finish(error) {
                self.restart(req,after: delay)
            }else{
                req.cleanup()
            }
            self.remove(req)
        }
    }
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
    }
}

extension Session : URLSessionDownloadDelegate{
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL){
        if let req = self.requests[downloadTask.taskIdentifier] as? Download{
            req.finishDownload(location)
        }
    }
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64){

    }
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64){
        
    }
}

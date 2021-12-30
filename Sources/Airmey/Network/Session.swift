//
//  Session.swift
//  Airmey
//
//  Created by supertext on 2021/6/09.
//  Copyright © 2021年 airmey. All rights reserved.
//

import Foundation

class Session:NSObject{
    @Protected
    private var tasks:[Int:HTTPTask] = [:]
    private let rootQueue:DispatchQueue = .init(label: "com.airmey.network.rootQueue")
    private let retryQueue:DispatchQueue = .init(label: "com.airmey.network.retryQueue")
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
        method:HTTPMethod,
        params:Parameters?,
        headers:HTTPHeaders,
        encoder:HTTPEncoder,
        decoder:HTTPDecoder,
        retrier:Retrier? = nil,
        timeout:TimeInterval = 60,
        completion:HTTPFinish?=nil)->HTTPTask?{
        let result = encoder.encode(url, method: method, params: params, headers: headers, timeout: timeout)
        guard let urlreq = result.value else{
            let result:Result<JSON,Swift.Error> = .failure(HTTPError.encode(result.error!))
            completion?(Response<JSON>(result: result))
            return nil
        }
        let task = self.session.dataTask(with: urlreq)
        let req = HTTPTask(task,retrier: retrier,decoder: decoder,completion: completion)
        self.add(req)
        return req
    }
    func upload(
        _ url:URL,
        file:URL,
        params:Parameters?,
        headers:HTTPHeaders?,
        decoder:HTTPDecoder,
        fileManager:FileManager = .default,
        completion:HTTPFinish?=nil)->HTTPTask?{
        let result = HTTP.URLEncoder.query.encode(url, method: .post, params: params, headers: headers, timeout: 0)
        guard let urlreq = result.value else{
            let result:Result<JSON,Swift.Error> = .failure(HTTPError.encode(result.error!))
            completion?(Response<JSON>(result: result))
            return nil
        }
        let task = self.session.uploadTask(with: urlreq, fromFile: file)
        let req = UploadTask(task,decoder: decoder,fileManager: fileManager,completion: completion)
        self.add(req)
        return req
    }
    func upload(
        _ url:URL,
        form:FormData,
        params:Parameters?,
        decoder:HTTPDecoder,
        headers:HTTPHeaders?,
        fileManager:FileManager = .default,
        completion:HTTPFinish?=nil)->HTTPTask?{
        let result = HTTP.URLEncoder.query.encode(url, method: .post, params: params, headers: headers, timeout: 0)
        guard var urlreq = result.value else{
            let result:Result<JSON,Swift.Error> = .failure(HTTPError.encode(result.error!))
            completion?(Response<JSON>(result: result))
            return nil
        }
        urlreq.setHeader(form.contentType, for: .contentType)
        do {
            let upload = try form.toUpload()
            var req:UploadTask
            switch upload {
            case .data(let data):
                let task = self.session.uploadTask(with: urlreq, from: data)
                req = UploadTask(task,decoder: decoder,fileManager: form.fileManager,completion: completion)
            case .file(let fileURL):
                let task = self.session.uploadTask(with: urlreq, fromFile: fileURL)
                req = UploadTask(task,decoder: decoder,fileManager: form.fileManager,completion: completion)
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
        transfer:DownloadTask.URLTransfer? = nil,
        completion:HTTPFinish?)->DownloadTask?{
        let task = self.session.downloadTask(withResumeData: data)
        let req = DownloadTask(task, transfer: transfer, fileManager: fileManager,completion: completion)
        self.add(req)
        return req
    }
    func download(
        _ url: URL,
        params:Parameters?,
        headers:HTTPHeaders?,
        fileManager:FileManager = .default,
        transfer:DownloadTask.URLTransfer? = nil,
        completion:HTTPFinish?)->DownloadTask?{
        let result = HTTP.URLEncoder.query.encode(url, method: .get, params: params, headers: headers, timeout: 0)
        guard let urlreq = result.value else{
            let result:Result<JSON,Swift.Error> = .failure(HTTPError.encode(result.error!))
            completion?(Response<JSON>(result: result))
            return nil
        }
        let task = self.session.downloadTask(with: urlreq)
        let req = DownloadTask(task, transfer: transfer, fileManager: fileManager,completion: completion)
        self.add(req)
        return req
    }
}

extension Session{
    func add(_ task:HTTPTask) {
        self.$tasks[task.id] = task
        task.resume()
    }
    func remove(_ task:HTTPTask){
        self.$tasks[task.id] = nil
    }
    func restart(_ task:HTTPTask,after:TimeInterval = 0){
        retryQueue.asyncAfter(deadline: .now()+after) {
            task.reset(task: self.session.dataTask(with: task.request!))
            self.add(task)
        }
    }
}
extension Session:URLSessionTaskDelegate{
    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        if let req = self.$tasks[task.taskIdentifier] {
            req.metrics = metrics
        }
    }
}
extension Session:URLSessionDataDelegate{
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if let req = self.$tasks[dataTask.taskIdentifier] {
            req.append(data)
        }
    }
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Swift.Error?) {
        if let req = self.$tasks[task.taskIdentifier] {
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
        if let req = self.$tasks[downloadTask.taskIdentifier] as? DownloadTask{
            req.finishDownload(location)
        }
    }
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64){

    }
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64){
        
    }
}

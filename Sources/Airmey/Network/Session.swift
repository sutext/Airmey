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
        method:HTTPMethod = .get,
        params:HTTPParams?=nil,
        headers:HTTPHeaders = .default,
        encoder:HTTPEncoder = HTTP.JSONEncoder(),
        retrier:HTTPRetrier? = nil,
        timeout:TimeInterval = 60,
        completion:((Response<JSON>)->Void)?=nil)->Request?{
        guard let urlreq = encoder.encode(url, method: method, params: params, headers: headers, timeout: timeout) else{
            let result:Result<JSON,Swift.Error> = .failure(HTTPError.encodeFailure)
            completion?(Response<JSON>(result: result))
            return nil
        }
        let task = self.session.dataTask(with: urlreq)
        let req = Request(task,urlreq: urlreq,handler: completion,retrier: retrier)
        self.add(req)
        return req
    }
    func upload(
        _ file:URL,
        to url:URL,
        params:HTTPParams?=nil,
        headers:HTTPHeaders = .default,
        completion:((Response<JSON>)->Void)?=nil)->Request?{
        guard let urlreq = HTTP.URLEncoder().encode(url, method: .post, params: params, headers: headers, timeout: 0) else{
            let result:Result<JSON,Swift.Error> = .failure(HTTPError.encodeFailure)
            completion?(Response<JSON>(result: result))
            return nil
        }
        let task = self.session.uploadTask(with: urlreq, fromFile: file)
        let req = Request(task,urlreq: urlreq,handler: completion,retrier: nil)
        self.add(req)
        return req
    }
    func upload(
        _ form:FormData,
        to url:URL,
        params:HTTPParams?=nil,
        headers:HTTPHeaders = .default,
        completion:((Response<JSON>)->Void)?=nil)->Request?{
        guard let urlreq = HTTP.URLEncoder().encode(url, method: .post, params: params, headers: headers, timeout: 0) else{
            let result:Result<JSON,Swift.Error> = .failure(HTTPError.encodeFailure)
            completion?(Response<JSON>(result: result))
            return nil
        }
        do {
            let data = try form.encode()
            let task = self.session.uploadTask(with: urlreq, from: data)
            let req = Request(task,urlreq: urlreq,handler: completion,retrier: nil)
            self.add(req)
            return req
        } catch {
            let result:Result<JSON,Swift.Error> = .failure(error)
            completion?(Response<JSON>(result: result))
            return nil
        }
    }
}

extension Session{
    func add(_ req:Request) {
        self.requests[req.taskIdentifier] = req
        req.resume()
    }
    func remove(_ taskId:Int){
        self.requests.removeValue(forKey: taskId)
    }
    func restart(_ req:Request,after:TimeInterval = 0){
        retryQueue.asyncAfter(deadline: .now()+after) {
            req.reset(in: self.session)
            req.resume()
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
            let result = req.finish(error)
            switch result {
            case .now:
                self.restart(req)
            case .delay(let time):
                self.restart(req,after: time)
            default:
                self.remove(task.taskIdentifier)
            }
        }
    }
}

extension Session : URLSessionDownloadDelegate{
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL){
        
    }
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64){
        
    }
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64){
        
    }
}

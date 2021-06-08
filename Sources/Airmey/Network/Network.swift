//
//  Network.swift
//  
//
//  Created by supertext on 2021/6/6.
//

import Foundation

open class Network:NSObject{
    private static var monitor:Monitor?
    public private(set) static var status:Monitor.Status = .unknown{
        didSet{
            if status != oldValue{
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .AMNetworkStatusChanged, object: self)
                }
            }
        }
    }
    private let session:URLSession
    private let rootQueue:DispatchQueue = .init(label: "com.airmey.network.rootQueue")
    private let delegate:Delegate
    public override init() {
        let config = URLSessionConfiguration.default
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.underlyingQueue = rootQueue
        queue.name = "com.airmey.network.delegateQueue"
        queue.qualityOfService = .default
        let delegate = Delegate()
        self.delegate  = delegate
        self.session = URLSession(configuration: config,delegate: delegate,delegateQueue: queue)
        super.init()
    }
    public func request(
        _ url:URL,
        method:Method = .get,
        params:Params?=nil,
        headers:Headers = Headers.default,
        timeout:TimeInterval = 60,
        encoder:RequestEncoder = JSONEncoder(),
        completion:((Response<JSON>)->Void)?=nil)->Request?{
        guard let request = encoder.encode(url, method: method, params: params, headers: headers, timeout: timeout) else{
            let result:Result<JSON,Swift.Error> = .failure(NTError.paramsEncodeFailure)
            completion?(Response<JSON>(result: result))
            return nil
        }
        let task = self.session.dataTask(with: request)
        let req = Request(task,handler: completion)
        self.delegate.add(req)
        req.resume()
        return req
    }
//    public func upload(
//        _ url:URL,
//        params:Params?=nil,
//        headers:Headers = Headers.default,
//        completion:((Response<JSON>)->Void)?=nil)->URLSessionUploadTask?{
//
//    }
}
extension Network{
    class Delegate:NSObject {
        private var requests:[Int:Request] = [:]
        func add(_ req:Request) {
            self.requests[req.taskIdentifier] = req
        }
    }
}
extension Network.Delegate:URLSessionTaskDelegate{
    public func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        if let req = self.requests[task.taskIdentifier] {
            req.metrics = metrics
        }
    }
}
extension Network.Delegate:URLSessionDataDelegate{
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if let req = self.requests[dataTask.taskIdentifier] {
            req.append(data)
        }
    }
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Swift.Error?) {
        if let req = self.requests[task.taskIdentifier] {
            req.finish(error)
            self.requests.removeValue(forKey: task.taskIdentifier)
        }
    }
}

extension Network{
    public class func listen(host:String?=nil) {
        if let monitor = self.monitor {
            monitor.startListening { (stus) in
                self.status = status
            }
            return
        }
        if let host = host {
            self.monitor = Monitor(host: host)
        }else{
            self.monitor = Monitor()
        }
        self.monitor?.startListening { (status) in
            self.status = status
        }
    }
    
    public class func refresh(){
        guard  let status = self.monitor?.status else {
            return
        }
        self.status = status
    }
    public class func stopListen() {
        self.monitor?.stopListening()
    }
}
extension Network{
    public typealias TaskHandler = (Response<JSON>)->Void
    public typealias Params = [String:JSON]
    public enum Method:String{
        case get = "GET"
        case put = "PUT"
        case head = "HEAD"
        case post = "POST"
        case trace = "TRACE"
        case patch = "PATCH"
        case delete = "DELETE"
        case connect = "CONNECT"
        case options = "OPTIONS"
    }
}


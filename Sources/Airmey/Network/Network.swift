//
//  Network.swift
//  
//
//  Created by supertext on 2021/6/6.
//

import Foundation

open class Network{
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
    private var metrics:[Int:URLSessionTaskMetrics] = [:]
    public init() {
        let config = URLSessionConfiguration.default
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.underlyingQueue = rootQueue
        queue.name = "com.airmey.network.delegateQueue"
        queue.qualityOfService = .default
        session = URLSession(configuration: config,delegate: nil,delegateQueue: queue)
    }
    public func request(
        _ url:URL,
        method:Method = .get,
        params:Params?=nil,
        headers:Headers = Headers.default,
        timeout:TimeInterval = 60,
        encoder:RequestEncoder = JSONEncoder(),
        completion:((Response<JSON>)->Void)?=nil)->URLSessionDataTask?{
        guard let request = encoder.encode(url, method: method, params: params, headers: headers, timeout: timeout) else{
            let result:Result<JSON,Swift.Error> = .failure(Error.paramsEncodeFailure)
            completion?(Response<JSON>(result: result))
            return nil
        }
        let task = self.session.dataTask(with: request) { data, resp, error in
            var result:Result<JSON,Swift.Error>
            if let data = data{
                result = .success(JSON.parse(data))
            }else{
                result = .failure(error ?? Error.invalidData)
            }
            completion?(Response<JSON>(data: data,result:result, request: request, response: resp))
        }
        task.resume()
        return task
    }
    public func upload(){

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
    public typealias Params = [String:JSON]
    public enum Error:Swift.Error{
        case unkown
        case invalidURL
        case invalidData
        case paramsEncodeFailure
    }
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


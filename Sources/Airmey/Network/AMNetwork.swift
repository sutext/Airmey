//
//  AMNetwork.swift
//  Airmey
//
//  Created by supertext on 2020/6/24.
//  Copyright © 2020年 airmey. All rights reserved.
//

import Alamofire
import Foundation

extension Notification.Name{
    public static let AMNetworkStatusChanged:Notification.Name = Notification.Name("com.airmey.network.status.changed")
}

open class AMNetwork {
    private static var monitor:NetworkReachabilityManager?
    public private(set) static var status:Status = .unknown{
        didSet{
            if status != oldValue{
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .AMNetworkStatusChanged, object: self)
                }
            }
        }
    }
    private lazy var session:Session = {
        let manager = Session(configuration: self.sessionConfig, serverTrustManager: nil)
        return manager
    }()
    private var baseURL:URL?
    public init(baseURL:String) {
        self.baseURL = URL(string:baseURL);
    }
    public var isDebug:Bool = false
    /// global http headers @default empty
    open var headers:[String:String]{[:]}
    /// global http method settings  @default .get
    open var method:Method{.get}
    /// global timeout settings @default 60s
    open var timeout:TimeInterval{60 }
    /// global request encode @default .json
    open var encoding:Encoding{.json}
    /// global response verifer @default map directly
    open func verify(_ old:AMResponse<Any>)->AMResponse<JSON>{
        return old.tryMap{.init($0)}
    }
    /// global error catched here
    open func oncatch (_ error:Error){
        
    }
    open var sessionConfig:URLSessionConfiguration{
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = self.timeout
        config.headers = HTTPHeaders.default;
        return config;
    }
    @discardableResult
    public func request<R:AMRequest>(_ req:R,completion:((AMResponse<R.Model>)->Void)? = nil)->Task?{
        return self.request(req.path, params: req.params, options: req.options) { resp in
            completion?(resp.tryMap{try req.convert($0)})
        }
    }
    @discardableResult
    public func request(
        _  path:String,
        params:[String:Any]?=nil,
        options:Options?=nil,
        completion:((AMResponse<JSON>)->Void)? = nil)->Task?{
        
        guard let baseURL = options?.baseURL ?? self.baseURL ,
              let url = URL(string:path,relativeTo:baseURL) else {
            completion?(.init(DataResponse(
                                request: nil,
                                response: nil,
                                data: nil,
                                metrics:nil,
                                serializationDuration:0 ,
                                result: .failure(AFError.invalidURL(url: path)))))
            return nil;
        }
        let method = options?.method?.af ?? self.method.af
        let encoding = options?.encoding?.af ?? self.encoding.af
        let timeout = options?.timeout ?? self.timeout
        var headers = HTTPHeaders(self.headers)
        if let h = options?.headers {
            h.forEach {
                headers.add(name: $0.key, value: $0.value)
            }
        }
        let task = self.session.request(
            url,
            method: method,
            parameters: params,
            encoding:encoding,
            headers:headers,
            requestModifier: {$0.timeoutInterval = timeout}
        )
        task.responseJSON(queue: .main) { (resp) in
            let amres:AMResponse<Any> = .init(resp.mapError{$0})
            var result:AMResponse<JSON>! = nil
            if let verifier = options?.verifier{
                result = verifier(amres)
            }else{
                result = self.verify(amres)
            }
            if let error = result?.error {
                self.oncatch(error)
            }
            completion?(result)
        }
        if isDebug{
            task.responseJSON {
                debugPrint($0)
            }
        }
        return .init(task);
    }
    @discardableResult
    public func upload<R:AMUploadRequest>(_ req:R,completion:((AMResponse<R.Model>)->Void)? = nil)->UploadTask?{
        //Assert
        guard let baseURL = req.options?.baseURL ?? self.baseURL ,
              let url = URL(string:req.path,relativeTo:baseURL) else {
            completion?(.init(DataResponse(
                                request: nil,
                                response: nil,
                                data: nil,
                                metrics:nil,
                                serializationDuration:0 ,
                                result: .failure(AFError.invalidURL(url:req.path)))))
            return nil
        }
        var headers = HTTPHeaders(self.headers)
        if let h = req.options?.headers {
            h.forEach {
                headers.add(name: $0.key, value: $0.value)
            }
        }
        //Assert
        guard let request = try? URLRequest(url: url, method: .post, headers: headers),
              var newreq = try? URLEncoding.queryString.encode(request, with: req.params) else {
            completion?(.init(DataResponse(request: nil, response: nil, data: nil,metrics:nil, serializationDuration:0 , result: .failure(AFError.parameterEncodingFailed(reason: .missingURL)))))
            return nil
        }
        newreq.timeoutInterval = req.options?.timeout ?? self.timeout
        //create task
        let task = self.session.upload(multipartFormData: { (data) in
            for object in req.uploads{
                data.append(object: object)
            }
        }, with: newreq)
        task.responseJSON(queue: .main) { (resp) in
            let amres:AMResponse<Any> = .init(resp.mapError{$0})
            var result:AMResponse<R.Model>! = nil
            if let verifier = req.options?.verifier{
                result = verifier(amres).tryMap{try req.convert($0)}
            }else{
                result = self.verify(amres).tryMap{try req.convert($0)}
            }
            if let error = result?.error {
                self.oncatch(error)
            }
            completion?(result)
        }
        if isDebug{
            task.responseJSON {
                debugPrint($0)
            }
        }
        return .init(task)
    }
}
extension AMNetwork{
    public class func listen(host:String?=nil) {
        if let monitor = self.monitor {
            monitor.startListening { (stus) in
                self.status = Status(stus)
            }
            return
        }
        if let host = host {
            self.monitor = NetworkReachabilityManager(host: host)
        }else{
            self.monitor = NetworkReachabilityManager()
        }
        self.monitor?.startListening { (stus) in
            self.status = Status(stus)
        }
    }
    
    public class func refresh(){
        guard  let status = self.monitor?.status else {
            return
        }
        self.status = Status(status)
    }
    public class func stopListen() {
        self.monitor?.stopListening()
    }
}
extension AMNetwork{
    public enum Status {
        case unknown
        case wifi
        case wwan
        case none
        init(_ astus:NetworkReachabilityManager.NetworkReachabilityStatus){
            switch astus {
            case .unknown:
                self = .unknown
            case .notReachable:
                self = .none
            case .reachable(let type):
                switch type{
                case .ethernetOrWiFi:
                    self = .wifi
                case .cellular:
                    self = .wwan
                }
            }
        }
        public var isReachable:Bool{
            switch self {
            case .wifi,.wwan:
                return true
            default:
                return false
            }
        }
    }
}
extension AMNetwork{
    public typealias Verifier = (AMResponse<Any>) -> AMResponse<JSON>
    public struct Options{
        /// overwrite the global method settings
        public var method:Method?
        /// overwrite the global baseURL settings
        public var baseURL:URL?
        /// merge into global headers
        public var headers:[String:String]?
        /// overwrite global timeout settings
        public var timeout:TimeInterval?
        /// overwrite the global params encoding settings
        public var encoding:Encoding?
        /// overwrite the network verify method
        public var verifier:Verifier?

        public init(_ method:Method?=nil,
                    base:URL?=nil,
                    headers:[String:String]?=nil,
                    timeout:TimeInterval?=nil,
                    encoding:Encoding?=nil,
                    verifier:Verifier? = nil) {
            self.method = method
            self.baseURL = base
            self.headers = headers
            self.timeout = timeout
            self.verifier = verifier
            self.encoding = encoding
        }
    }
    public enum Method:String{
        case get = "GET"
        case put = "PUT"
        case post = "POST"
        case delete = "DELETE"
        var af:HTTPMethod{HTTPMethod(rawValue: rawValue)}
    }
    public enum Encoding{
        case url
        case json
        var af:ParameterEncoding{
            switch self {
            case .json:
                return JSONEncoding.default
            case .url:
                return URLEncoding.default
            }
        }
    }
    public class Task{
        private var af:DataRequest
        init(_ af:DataRequest) {
            self.af = af
        }
        /// Returns whether `state` is `.initialized`.
        public var isInitialized: Bool { af.isInitialized }
        /// Returns whether `state is `.resumed`.
        public var isResumed: Bool { af.isResumed }
        /// Returns whether `state` is `.suspended`.
        public var isSuspended: Bool { af.isSuspended }
        /// Returns whether `state` is `.cancelled`.
        public var isCancelled: Bool { af.isCancelled }
        /// Returns whether `state` is `.finished`.
        public var isFinished: Bool { af.isFinished }
        public func suspend() {
            self.af.suspend()
        }
        public func resume() {
            self.af.resume()
        }
        public func cancel() {
            self.af.cancel()
        }
    }
    public class UploadTask:Task{
 
    }
}

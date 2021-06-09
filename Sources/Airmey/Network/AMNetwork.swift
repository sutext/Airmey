//
//  AMNetwork.swift
//  Airmey
//
//  Created by supertext on 2021/6/09.
//  Copyright © 2021年 airmey. All rights reserved.
//

import Foundation
extension Notification.Name{
    public static let AMNetworkStatusChanged:Notification.Name = Notification.Name("com.airmey.network.status.changed")
}

open class AMNetwork {
    public private(set) static var monitor:AMMonitor?
    public private(set) static var status:AMMonitor.Status = .unknown{
        didSet{
            if status != oldValue{
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .AMNetworkStatusChanged, object: self)
                }
            }
        }
    }
    private lazy var session:Session = Session()
    public init(baseURL:String) {
        self.baseURL = URL(string:baseURL);
    }
    private var baseURL:URL?

    public var isDebug:Bool = false
    /// global http method `.get` by default
    open var method:HTTPMethod{.get}
    /// global retryer  `nil` by default
    open var retrier:HTTPRetrier?{ nil }
    /// global request encoder  `HTTP.JSONEncoder()` by default
    open var encoder:HTTPEncoder{ HTTP.JSONEncoder() }
    /// global http headers `[:]` by default
    open var headers:[String:String]{[:]}
    /// global timeout in secends `60` by default
    open var timeout:TimeInterval{ 60 }
    /// global response verifer @default map directly
    open func verify(_ old:Response<JSON>)->Response<JSON>{
        return old.map{.init($0)}
    }
    /// global error catched here
    open func oncatch (_ error:Error){
        
    }
    @discardableResult
    public func request<R:AMRequest>(_ req:R,completion:((Response<R.Model>)->Void)? = nil)->Request?{
        guard let baseURL = req.options?.baseURL ?? self.baseURL ,
              let url = URL(string:req.path,relativeTo:baseURL) else {
            let result:Result<R.Model,Swift.Error> = .failure(HTTPError.invalidURL)
            completion?(Response(result: result))
            return nil;
        }
        let method = req.options?.method ?? self.method
        let timeout = req.options?.timeout ?? self.timeout
        let encoder = req.options?.encoder ?? self.encoder
        let retrier = req.options?.retrier ?? self.retrier
        var headers = HTTPHeaders(self.headers)
        if let h = req.options?.headers {
            headers.merge(h)
        }
        return self.session.request(
            url,
            method: method,
            params: req.params,
            headers: headers,
            encoder: encoder,
            retrier: retrier,
            timeout: timeout) {resp in
            let result = resp.map{try req.convert($0)}
            DispatchQueue.main.async {
                completion?(result)
            }
        }
    }
    @discardableResult
    public func request(
        _  path:String,
        params:HTTPParams?=nil,
        options:Options?=nil,
        completion:((Response<JSON>)->Void)? = nil)->Request?{
        guard let baseURL = options?.baseURL ?? self.baseURL ,
              let url = URL(string:path,relativeTo:baseURL) else {
            let result:Result<JSON,Swift.Error> = .failure(HTTPError.invalidURL)
            completion?(.init(result: result))
            return nil;
        }
        let method = options?.method ?? self.method
        let timeout = options?.timeout ?? self.timeout
        let encoder = options?.encoder ?? self.encoder
        let retrier = options?.retrier ?? self.retrier
        var headers = HTTPHeaders(self.headers)
        if let h = options?.headers {
            headers.merge(h)
        }
        return self.session.request(
            url,
            method: method,
            params: params,
            headers: headers,
            encoder: encoder,
            retrier: retrier,
            timeout: timeout) {res in
            DispatchQueue.main.async {
                completion?(res)
            }
        }
    }
//    @discardableResult
//    public func upload<R:AMUploadRequest>(_ req:R,completion:((AMResponse<R.Model>)->Void)? = nil)->UploadTask?{
//        //Assert
//        guard let baseURL = req.options?.baseURL ?? self.baseURL ,
//              let url = URL(string:req.path,relativeTo:baseURL) else {
//            completion?(.init(DataResponse(
//                                request: nil,
//                                response: nil,
//                                data: nil,
//                                metrics:nil,
//                                serializationDuration:0 ,
//                                result: .failure(AFError.invalidURL(url:req.path)))))
//            return nil
//        }
//        var headers = HTTPHeaders(self.headers)
//        if let h = req.options?.headers {
//            h.forEach {
//                headers.add(name: $0.key, value: $0.value)
//            }
//        }
//        //Assert
//        guard let request = try? URLRequest(url: url, method: .post, headers: headers),
//              var newreq = try? URLEncoding.queryString.encode(request, with: req.params) else {
//            completion?(.init(DataResponse(request: nil, response: nil, data: nil,metrics:nil, serializationDuration:0 , result: .failure(AFError.parameterEncodingFailed(reason: .missingURL)))))
//            return nil
//        }
//        newreq.timeoutInterval = req.options?.timeout ?? self.timeout
//        //create task
//        let task = self.session.upload(multipartFormData: { (data) in
//            for object in req.uploads{
//                data.append(object: object)
//            }
//        }, with: newreq)
//        task.responseJSON(queue: .main) { (resp) in
//            let amres:AMResponse<Any> = .init(resp.mapError{$0})
//            var result:AMResponse<R.Model>! = nil
//            if let verifier = req.options?.verifier{
//                result = verifier(amres).tryMap{try req.convert($0)}
//            }else{
//                result = self.verify(amres).tryMap{try req.convert($0)}
//            }
//            if let error = result?.error {
//                self.oncatch(error)
//            }
//            completion?(result)
//        }
//        if isDebug{
//            task.responseJSON {
//                debugPrint($0)
//            }
//        }
//        return .init(task)
//    }
}

extension AMNetwork{
    public class func listen(host:String?=nil) {
        if let monitor = self.monitor {
            monitor.startListening { (stus) in
                self.status = status
            }
            return
        }
        if let host = host {
            self.monitor = AMMonitor(host: host)
        }else{
            self.monitor = AMMonitor()
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
extension AMNetwork{
    public typealias Verifier = (Response<JSON>) -> Response<JSON>
    public struct Options{
        /// overwrite the global method settings
        public var method:HTTPMethod?
        /// overwrite the global baseURL settings
        public var baseURL:URL?
        /// overwrite the global encoder settings
        public var encoder:HTTPEncoder?
        /// overwrite the global retrier settings
        public var retrier:HTTPRetrier?
        /// merge into global headers
        public var headers:[String:String]?
        /// overwrite global timeout settings
        public var timeout:TimeInterval?
        /// overwrite the network verify method
        public var verifier:Verifier?
        public init(
            _ method:HTTPMethod?=nil,
            baseURL:URL?=nil,
            encoder:HTTPEncoder?=nil,
            retrier:HTTPRetrier?=nil,
            headers:[String:String]?=nil,
            timeout:TimeInterval?=nil,
            verifier:Verifier? = nil) {
            self.method = method
            self.baseURL = baseURL
            self.encoder = encoder
            self.retrier = retrier
            self.headers = headers
            self.timeout = timeout
            self.verifier = verifier
        }
    }
}

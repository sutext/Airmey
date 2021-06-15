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
    open var retrier:Retrier?{ nil }
    /// global request encoder  `JSONEncoding()` by default
    open var encoder:HTTPEncoder{ JSNEncoder() }
    /// global http headers `[:]` by default
    open var headers:[String:String]{[:]}
    /// global timeout in secends `60` by default
    open var timeout:TimeInterval{ 60 }
    /// global default fileManager
    open var fileManager:FileManager{ .default }
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
            let result:Result<R.Model,Swift.Error> = .failure(HTTPError.invalidURL(url:req.path))
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
            timeout: timeout) {res in
            var resp:Response<R.Model>
            if let verify = req.options?.verifier{
                resp = verify(res).map{try req.convert($0)}
            }else{
                resp = self.verify(res).map{try req.convert($0)}
            }
            DispatchQueue.main.async {
                if let error = resp.error{
                    self.oncatch(error)
                }
                completion?(resp)
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
            let result:Result<JSON,Swift.Error> = .failure(HTTPError.invalidURL(url:path))
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
            var resp:Response<JSON>
            if let verify = options?.verifier{
                resp = verify(res)
            }else{
                resp = self.verify(res)
            }
            DispatchQueue.main.async {
                if let error = resp.error{
                    self.oncatch(error)
                }
                completion?(resp)
            }
        }
    }
    @discardableResult
    public func upload<R:AMFormUpload>(_ req:R,completion:((Response<R.Model>)->Void)? = nil)->Request?{
        guard let baseURL = req.options?.baseURL ?? self.baseURL ,
              let url = URL(string:req.path,relativeTo:baseURL) else {
            let result:Result<R.Model,Error> = .failure(HTTPError.invalidURL(url:req.path))
            completion?(Response(result: result))
            return nil;
        }
        var headers = HTTPHeaders(self.headers)
        if let h = req.options?.headers {
            headers.merge(h)
        }
        return self.session.upload(
            url,
            form: req.form,
            params: req.params,
            headers: headers,
            fileManager: fileManager) { res in
            var resp:Response<R.Model>
            if let verify = req.options?.verifier{
                resp = verify(res).map{try req.convert($0)}
            }else{
                resp = self.verify(res).map{try req.convert($0)}
            }
            DispatchQueue.main.async {
                if let error = resp.error{
                    self.oncatch(error)
                }
                completion?(resp)
            }
        }
    }
    @discardableResult
    public func upload<R:AMFileUpload>(_ req:R,completion:((Response<R.Model>)->Void)? = nil)->Request?{
        guard let baseURL = req.options?.baseURL ?? self.baseURL ,
              let url = URL(string:req.path,relativeTo:baseURL) else {
            let result:Result<R.Model,Error> = .failure(HTTPError.invalidURL(url:req.path))
            completion?(Response(result: result))
            return nil;
        }
        var headers = HTTPHeaders(self.headers)
        if let h = req.options?.headers {
            headers.merge(h)
        }
        return self.session.upload(
            url,
            file: req.file,
            params: req.params,
            headers: headers,
            fileManager: fileManager) { res in
            var resp:Response<R.Model>
            if let verify = req.options?.verifier{
                resp = verify(res).map{try req.convert($0)}
            }else{
                resp = self.verify(res).map{try req.convert($0)}
            }
            DispatchQueue.main.async {
                if let error = resp.error{
                    self.oncatch(error)
                }
                completion?(resp)
            }
        }
    }
    @discardableResult
    public func download<R:AMDownload>(_ req:R,completion:((Response<JSON>)->Void)?=nil)->Download?{
        guard let url = URL(string:req.url) else {
            let result:Result<JSON,Error> = .failure(HTTPError.invalidURL(url:req.url))
            completion?(Response(result: result))
            return nil;
        }
        return self.session.download(url, params: req.params, headers: HTTPHeaders(req.headers), fileManager: fileManager,transfer:{
            req.location(for: $0, and: $1)
        }) { resp in
            DispatchQueue.main.async {
                if let error = resp.error{
                    self.oncatch(error)
                }
                completion?(resp)
            }
        }
    }
    @discardableResult
    public func download(
        _ url:String,
        params:HTTPParams?=nil,
        headers:HTTPHeaders?=nil,
        transfer:@escaping Download.URLTransfer = Download.defaultTransfer,
        completion:((Response<JSON>)->Void)?=nil)->Download?{
        var aheaders = HTTPHeaders(self.headers)
        guard let url = URL(string:url) else {
            let result:Result<JSON,Error> = .failure(HTTPError.invalidURL(url:url))
            completion?(Response(result: result))
            return nil;
        }
        if let newh = headers {
            aheaders.merge(newh)
        }
        return self.session.download(url, params: params, headers: aheaders, fileManager: fileManager,transfer: transfer) { resp in
            if let error = resp.error{
                self.oncatch(error)
            }
            completion?(resp)
        }
    }
    @discardableResult
    public func download(
        resume:Data,
        transfer:@escaping Download.URLTransfer = Download.defaultTransfer,
        completion:((Response<JSON>)->Void)?=nil)->Download?{
        return self.session.download(resume: resume, fileManager: fileManager,transfer: transfer) { resp in
            if let error = resp.error{
                self.oncatch(error)
            }
            completion?(resp)
        }
    }
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
        public var retrier:Retrier?
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
            retrier:Retrier?=nil,
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

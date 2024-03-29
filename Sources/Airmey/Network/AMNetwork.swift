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
///
/// `AMNetwork` is network configure center.
///  Usually you can inherit from `AMNetwork` and override the configuration params .
///
open class AMNetwork {
    /// global network monitor
    public private(set) static var monitor:AMMonitor?
    /// global network status 
    public private(set) static var status:AMMonitor.Status = .unknown{
        didSet{
            if status != oldValue{
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .AMNetworkStatusChanged, object: self,userInfo: ["status":status])
                }
            }
        }
    }
    private lazy var session:Session = Session()
    public init(baseURL:String) {
        self.baseURL = URL(string:baseURL);
    }
    private var baseURL:URL?
    /// print debug log or not. override for custom
    open var debug:Bool{ false }
    /// global callback queue by default use main queue.
    open var queue:DispatchQueue { .main }
    /// global http method `.get` by default. override it in  options
    open var method:HTTPMethod{.get}
    /// global retryer  `nil` by default .override it in  options
    open var retrier:Retrier?{ nil }
    /// global request encoder. By default use  `HTTP.JSONEncoder()`. override it in  options
    open var encoder:HTTPEncoder{ HTTP.JSONEncoder() }
    /// global request decoder. By default use  `HTTP.JSONDecoder()`. override it in  options
    open var decoder:HTTPDecoder{ HTTP.JSONDecoder() }
    /// global http headers `[:]` by default, override it in  options
    open var headers:[String:String]{ [:] }
    /// global timeout in secends `60` by default. override it in  options
    open var timeout:TimeInterval{ 60 }
    /// global default fileManager. override for custom
    open var fileManager:FileManager{ .default }
    
    /// global response verifer.
    ///
    /// - Yout can `override` it by custom verifier in options.
    /// - You can change the response data by return .rewrite(data).
    /// - You can change the error by throws a new error.
    /// - You restart current task by retrun .restart(URLRequest).
    ///
    /// - Throws: A new Response Error
    /// - Parameters:
    ///    - resp: The input Response
    /// - Returns: A `VerifyResult` whtin none restart and rewrite.
    ///
    open func verify(_ resp:Response<JSON>)throws ->VerifyResult{ .none }
    ///
    /// Send an common data request
    /// 
    /// - Parameters:
    ///    - req: The `AMRequest` protocol instance
    ///    - completion: The data request completion call back
    /// - Returns: Thre request handler for task control and progress control
    ///
    @discardableResult
    public func request<R:AMRequest>(_ req:R,completion:((Response<R.Model>)->Void)? = nil)->HTTPTask?{
        guard let baseURL = req.options?.baseURL ?? self.baseURL ,
              let url = URL(string:req.path,relativeTo:baseURL) else {
            let result:Result<R.Model,Error> = .failure(HTTPError.invalidURL(url:req.path))
            completion?(Response(result: result))
            return nil;
        }
        let queue = req.options?.queue ?? self.queue
        let method = req.options?.method ?? self.method
        let timeout = req.options?.timeout ?? self.timeout
        let encoder = req.options?.encoder ?? self.encoder
        let decoder = req.options?.decoder ?? self.decoder
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
            decoder: decoder,
            retrier: retrier,
            timeout: timeout)
        {res in
            var resp:Response<R.Model>?
            do {
                var result:VerifyResult
                if let verify = req.options?.verifier{
                    result = try verify(res)
                }else{
                    result = try self.verify(res)
                }
                switch result {
                case .none:
                    resp = res.map{ try req.convert($0)}
                case .restart(let r):
                    res.task?.restart(req: r)
                case .rewrite(let json):
                    resp = res.map{_ in json}.map { try req.convert($0) }
                }
            }catch{
                resp = .init(data: res.data, task: res.task, result: .failure(error))
            }
            guard let resp = resp else {
                return
            }
            if self.debug{
                debugPrint(resp)
            }
            queue.async { completion?(resp) }
        }
    }
    ///
    /// Send a simple data request directly
    ///
    /// - Parameters:
    ///    - path: The request relative to th baseURL
    ///    - params: The request params
    ///    - options: The current request options
    ///    - completion: The data request completion call back
    /// - Returns: Thre request handler for task control and progress control
    ///
    @discardableResult
    public func request(
        _  path:String,
        params:Parameters?=nil,
        options:Options?=nil,
        completion:HTTPFinish? = nil)->HTTPTask?{
        guard let baseURL = options?.baseURL ?? self.baseURL ,
              let url = URL(string:path,relativeTo:baseURL) else {
            let result:Result<JSON,Error> = .failure(HTTPError.invalidURL(url:path))
            completion?(.init(result: result))
            return nil;
        }
        let queue = options?.queue ?? self.queue
        let method = options?.method ?? self.method
        let timeout = options?.timeout ?? self.timeout
        let encoder = options?.encoder ?? self.encoder
        let decoder = options?.decoder ?? self.decoder
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
            decoder: decoder,
            retrier: retrier,
            timeout: timeout)
        { res in
            var resp:Response<JSON>?
            do {
                var result:VerifyResult
                if let verify = options?.verifier{
                    result = try verify(res)
                }else{
                    result = try self.verify(res)
                }
                switch result {
                case .none:
                    resp = res
                case .restart(let r):
                    res.task?.restart(req: r)
                case .rewrite(let json):
                    resp = res.map{_ in json }
                }
            } catch {
                resp = .init(data: res.data, task: res.task, result: .failure(error))
            }
            guard let resp = resp else {
                return
            }
            if self.debug{
                debugPrint(resp)
            }
            queue.async { completion?(resp) }
        }
    }
    /// Send an `multipart/form-data` request
    ///
    /// - Parameters:
    ///    - req: The `AMFormUpload` protocol instance
    ///    - completion: The data request completion call back
    /// - Returns: Thre request handler for task control and progress control
    ///
    @discardableResult
    public func upload<R:AMFormUpload>(_ req:R,completion:((Response<R.Model>)->Void)? = nil)->HTTPTask?{
        guard let baseURL = req.options?.baseURL ?? self.baseURL ,
              let url = URL(string:req.path,relativeTo:baseURL) else {
            let result:Result<R.Model,Error> = .failure(HTTPError.invalidURL(url:req.path))
            completion?(Response(result: result))
            return nil;
        }
        let queue = req.options?.queue ?? self.queue
        let decoder = req.options?.decoder ?? self.decoder
        var headers = HTTPHeaders(self.headers)
        if let h = req.options?.headers {
            headers.merge(h)
        }
        return self.session.upload(
            url,
            form: req.form,
            params: req.params,
            decoder: decoder,
            headers: headers,
            fileManager: fileManager)
        { res in
            var resp:Response<R.Model>?
            do {
                var result:VerifyResult
                if let verify = req.options?.verifier{
                    result = try verify(res)
                }else{
                    result = try self.verify(res)
                }
                switch result {
                case .none:
                    resp = res.map{ try req.convert($0)}
                case .restart(let r):
                    res.task?.restart(req: r)
                case .rewrite(let json):
                    resp = res.map{_ in json}.map { try req.convert($0) }
                }
            }catch{
                resp = .init(data: res.data, task: res.task, result: .failure(error))
            }
            guard let resp = resp else {
                return
            }
            if self.debug{
                debugPrint(resp)
            }
            queue.async { completion?(resp) }
        }
    }
    /// Send an file upload  request
    ///
    /// - Parameters:
    ///    - req: The `AMFileUpload` protocol instance
    ///    - completion: The data request completion call back
    /// - Returns: Thre request handler for task control and progress control
    ///
    @discardableResult
    public func upload<R:AMFileUpload>(_ req:R,completion:((Response<R.Model>)->Void)? = nil)->HTTPTask?{
        guard let baseURL = req.options?.baseURL ?? self.baseURL ,
              let url = URL(string:req.path,relativeTo:baseURL) else {
            let result:Result<R.Model,Error> = .failure(HTTPError.invalidURL(url:req.path))
            completion?(Response(result: result))
            return nil;
        }
        let queue = req.options?.queue ?? self.queue
        let decoder = req.options?.decoder ?? self.decoder
        var headers = HTTPHeaders(self.headers)
        if let h = req.options?.headers {
            headers.merge(h)
        }
        if headers[.contentType] == nil{
            headers[.contentType] = "application/octet-stream"
        }
        return self.session.upload(
            url,
            file: req.file,
            params: req.params,
            headers: headers,
            decoder: decoder,
            fileManager: fileManager)
        { res in
            var resp:Response<R.Model>?
            do {
                var result:VerifyResult
                if let verify = req.options?.verifier{
                    result = try verify(res)
                }else{
                    result = try self.verify(res)
                }
                switch result {
                case .none:
                    resp = res.map{ try req.convert($0)}
                case .restart(let r):
                    res.task?.restart(req: r)
                case .rewrite(let json):
                    resp = res.map{_ in json}.map { try req.convert($0) }
                }
            }catch{
                resp = .init(data: res.data, task: res.task, result: .failure(error))
            }
            guard let resp = resp else {
                return
            }
            if self.debug{
                debugPrint(resp)
            }
            queue.async { completion?(resp) }
        }
    }
    /// Upload an local file to server.
    ///
    /// - Parameters:
    ///    - file: The fileURL to be upload
    ///    - to: The relative upload path
    ///    - parmas: The upload request params
    ///    - options: The upload request options
    ///    - completion: The data request completion call back
    /// - Returns: Thre request handler for task control and progress control
    ///
    @discardableResult
    public func upload(
        _ file:URL,
        to path:String,
        params:Parameters?=nil,
        options:Options?=nil,
        completion:HTTPFinish? = nil)->HTTPTask?{
        guard let baseURL = options?.baseURL ?? self.baseURL ,
              let url = URL(string:path,relativeTo:baseURL) else {
            let result:Result<JSON,Error> = .failure(HTTPError.invalidURL(url:path))
            completion?(Response(result: result))
            return nil;
        }
        let queue = options?.queue ?? self.queue
        let decoder = options?.decoder ?? self.decoder
        var headers = HTTPHeaders(self.headers)
        if let h = options?.headers {
            headers.merge(h)
        }
        return self.session.upload(
            url,
            file: file,
            params: params,
            headers: headers,
            decoder: decoder,
            fileManager: fileManager)
        { res in
            var resp:Response<JSON>?
            do {
                var result:VerifyResult
                if let verify = options?.verifier{
                    result = try verify(res)
                }else{
                    result = try self.verify(res)
                }
                switch result {
                case .none:
                    resp = res
                case .restart(let r):
                    res.task?.restart(req: r)
                case .rewrite(let json):
                    resp = res.map{_ in json }
                }
            } catch {
                resp = .init(data: res.data, task: res.task, result: .failure(error))
            }
            guard let resp = resp else {
                return
            }
            if self.debug{
                debugPrint(resp)
            }
            queue.async { completion?(resp) }
        }
    }
    /// Send an file download  request
    /// - Note: If `transfer` is not specified, The download file will not be deleted until the system purges the temporary files. And the temporary file will been returned.
    /// - Parameters:
    ///    - req: The `AMDownload` protocol instance
    ///    - completion: Call back the transfered file location.
    /// - Returns: Thre request handler for task control and progress control
    ///
    @discardableResult
    public func download<R:AMDownload>(_ req:R,completion:HTTPFinish?=nil)->DownloadTask?{
        guard let url = URL(string:req.url) else {
            let result:Result<JSON,Error> = .failure(HTTPError.invalidURL(url:req.url))
            completion?(Response(result: result))
            return nil;
        }
        let queue = req.queue ?? self.queue
        return self.session.download(
            url,
            params: req.params,
            headers: HTTPHeaders(req.headers),
            fileManager: fileManager,
            transfer:req.transfer) { resp in
            if self.debug{
                debugPrint(resp)
            }
            queue.async { completion?(resp) }
        }
    }
    /// Send a simple download  request
    ///
    /// - Parameters:
    ///    - url: A full resource url
    ///    - params: The download request parameters
    ///    - headers: The download request headers
    ///    - transfer: The download file transfer
    ///    - completion: Call back the temporary file location. At this time transfer not suport
    /// - Returns: Thre request handler for task control and progress control
    ///
    @discardableResult
    public func download(
        _ url:String,
        queue:DispatchQueue?=nil,
        params:Parameters?=nil,
        headers:[String:String]?=nil,
        transfer: DownloadTask.URLTransfer? = nil,
        completion:HTTPFinish?=nil)->DownloadTask?{
        let queue = queue ?? self.queue
        var aheaders = HTTPHeaders(self.headers)
        guard let url = URL(string:url) else {
            let result:Result<JSON,Error> = .failure(HTTPError.invalidURL(url:url))
            completion?(Response(result: result))
            return nil;
        }
        if let newh = headers {
            aheaders.merge(newh)
        }
        return self.session.download(
            url,
            params: params,
            headers: aheaders,
            fileManager: fileManager,
            transfer: transfer) { resp in
            if self.debug{
                debugPrint(resp)
            }
            queue.async { completion?(resp) }
        }
    }
    /// Send a resume download request
    /// - Note: If `transfer` is not specified, the download will be moved to a temporary location determined by Airmey. The file will not be deleted until the system purges the temporary files.
    /// - Parameters:
    ///    - data: The resume data from a previously cancelled download request
    ///    - transfer: A closure used to determine how and where the downloaded file should be moved.
    ///    - completion: The data request completion call back
    /// - Returns: Thre request handler for task control and progress control
    ///
    @discardableResult
    public func download(
        resume data:Data,
        queue:DispatchQueue?=nil,
        transfer: DownloadTask.URLTransfer? = nil,
        completion:HTTPFinish?=nil)->DownloadTask?{
        let queue = queue ?? self.queue
        return self.session.download(
            resume: data,
            fileManager: fileManager,
            transfer: transfer) { resp in
            if self.debug{
                debugPrint(resp)
            }
            queue.async { completion?(resp) }
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
    public enum VerifyResult{
        case none /// Do not do anything
        case restart(URLRequest?) /// Restart current task
        case rewrite(data:JSON) ///Rewrite  respones data
    }
    public typealias Verifier = (Response<JSON>)throws -> VerifyResult
    public struct Options{
        /// overwrite the global callback queue settings
        public var queue:DispatchQueue?
        /// overwrite the global method settings
        public var method:HTTPMethod?
        /// overwrite the global baseURL settings
        public var baseURL:URL?
        /// overwrite the global encoder settings
        public var encoder:HTTPEncoder?
        /// overwrite the global decoder settings
        public var decoder:HTTPDecoder?
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

//
//  Network.swift
//  
//
//  Created by supertext on 2021/6/6.
//

import Foundation

open class Network{
    private let session:URLSession
    private let rootQueue:DispatchQueue = .init(label: "com.airmey.network.rootQueue")
    public init() {
        let config = URLSessionConfiguration.default
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.underlyingQueue = rootQueue
        queue.name = "com.airmey.network.delegateQueue"
        queue.qualityOfService = .default
        session = URLSession(configuration: config,delegate: nil,delegateQueue: queue)
    }
    private var baseURL:URL?

    public var isDebug:Bool = false
    /// global http headers @default empty
    open var headers:[String:String]{[:]}
    /// global http method settings  @default .get
    open var method:Request.Method{.get}
    /// global timeout settings @default 60s
    open var timeout:TimeInterval{60 }
    /// global request encode @default .json
//    open var encoding:RequestEncoding{.json}
    /// global response verifer @default map directly
//    open func verify(_ old:Response<JSON>)->Response<JSON>{
//        return old.tryMap{.init($0)}
//    }
    /// global error catched here
    open func oncatch (_ error:Error){
        
    }
    
    public func request(_  req:Request,completion:((Response<JSON>)->Void)? = nil){
        
//        guard let baseURL = req.options?.baseURL ?? self.baseURL ,
//              let url = URL(string:req.path,relativeTo:baseURL) else {
//            completion?(.init(DataResponse(
//                                request: nil,
//                                response: nil,
//                                data: nil,
//                                metrics:nil,
//                                serializationDuration:0 ,
//                                result: .failure(AFError.invalidURL(url: path)))))
//            return nil;
//        }
//        let method = req.options?.method ?? self.method
//        let encoding = req.options?.encoding ?? self.encoding
//        let timeout = req.options?.timeout ?? self.timeout
//        var headers = Request.Headers(self.headers)
//        if let h = req.options?.headers {
//            h.forEach {
//                headers.add(name: $0.key, value: $0.value)
//            }
//        }
//        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: timeout)
//        request.httpBody = params.rawData
//        session.dataTask(with: request) { <#Data?#>, <#URLResponse?#>, <#Error?#> in
//
//        }
//        let task = self.session.request(
//            url,
//            method: method,
//            parameters: params,
//            encoding:encoding,
//            headers:headers,
//            requestModifier: {$0.timeoutInterval = timeout}
//        )
//        task.responseJSON(queue: .main) { (resp) in
//            let amres:AMResponse<Any> = .init(resp.mapError{$0})
//            var result:AMResponse<JSON>! = nil
//            if let verifier = options?.verifier{
//                result = verifier(amres)
//            }else{
//                result = self.verify(amres)
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
//        return .init(task);
    }
}
extension Network{
    public enum Error:Swift.Error{
        case unkown
    }
}


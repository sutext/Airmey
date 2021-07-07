//
//  Response.swift
//  Airmey
//
//  Created by supertext on 2021/6/09.
//  Copyright © 2021年 airmey. All rights reserved.
//

import Foundation
public struct Response<M>{
    public let data:Data?
    public private(set) var result:Result<M,Error>
    public let request: URLRequest?
    public let response: HTTPURLResponse?
    public let metrics: URLSessionTaskMetrics?
    public var value:M?{ result.value }
    public var error:Error?{ result.error }
    public var statusCode:Int?{ response?.statusCode }
    init(
        data:Data? = nil,
        result:Result<M,Error>,
        request:URLRequest? = nil,
        metrics:URLSessionTaskMetrics?=nil,
        response:URLResponse? = nil) {
        self.data = data
        self.result = result
        self.metrics = metrics
        self.request = request
        self.response = response as? HTTPURLResponse
    }
    public lazy var headers:HTTPHeaders? = {
        if let values = response?.allHeaderFields as? [String:String] {
            return HTTPHeaders(values)
        }
        return nil
    }()
    public var timestamp:TimeInterval{
        if let datestr = response?.allHeaderFields["Date"] as? String,
           let date = datestr.date(for: .rfc822){
            return date.timeIntervalSince1970
        }
        return Date().timeIntervalSince1970
    }
    public func map<NewModel>(_ transform: (M) throws -> NewModel) -> Response<NewModel> {
        let newres = result.flatMap({m -> Result<NewModel,Error> in
            do {
                let res = try transform(m)
                return .success(res)
            }catch{
                return .failure(error)
            }
        })
        return .init(data: data, result:newres , request: request,metrics: metrics, response: response)
    }
    mutating func setError(_ error:Error){
        self.result = .failure(error)
    }
}
extension Response:CustomStringConvertible, CustomDebugStringConvertible{
    public var description: String {"\(result)"}
    public var debugDescription: String {
        var body = ""
        if let contentType = request?.header(for: .contentType) {
            if contentType.contains("application/json") {
                body = JSON(parse: request?.httpBody).description
            }else if contentType.contains("form-data"){
                body = "multipart/form-data"
            }
        }
        return """
        -----------DEUBG START------------
        [\(request?.httpMethod ?? "") URL]:  \(request?.url?.absoluteString ?? "None")
        [Request Data]: \(body)
        [Request Headers]: \(JSON(request?.allHTTPHeaderFields))
        [Request Duration]: \(metrics?.taskInterval.duration ?? 0)s
        [Response Data]: \(result)
        [Response Status]: \(response?.statusCode ?? 0)
        [Response Headers]: \(JSON(response?.allHeaderFields))
        -----------DEUBG   END------------
        """
    }
}

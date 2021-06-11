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
    public let result:Result<M,Error>
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
                return .success(try transform(m))
            }catch{
                return .failure(error)
            }
        })
        return .init(data: data, result:newres , request: request, response: response)
    }
}
extension Response:CustomStringConvertible, CustomDebugStringConvertible{
    public var description: String {"\(result)"}
    public var debugDescription: String {
        guard let urlRequest = request else { return "[Request]: None\n[Result]: \(result)" }
        let responseDescription = "[Response]: \(response==nil ? "None" :  response!.debugDescription)"
        let networkDuration = metrics.map { "\($0.taskInterval.duration)s" } ?? "None"
        return """
        [Request]:\(urlRequest.description)
        \(responseDescription)
        [Network Duration]: \(networkDuration)
        [Result]: \(result)
        """
    }
}

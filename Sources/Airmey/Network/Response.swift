//
//  File.swift
//  
//
//  Created by supertext on 2021/6/6.
//

import Foundation
public struct Response<M>{
    public var data:Data?
    public var value:M?
    public var error:Error?
    public var result:Result<M,Error>?
    public var metrics:URLSessionTaskMetrics?
    public var request: URLRequest?
    public var response: HTTPURLResponse?
    public init(data:Data?,request:URLRequest?,response:HTTPURLResponse?,error:Error?) {
        self.data = data
        self.error = error
        self.response = response
        self.request = request
    }
    public var timestamp:TimeInterval{
        if let datestr = response?.allHeaderFields["Date"] as? String,
           let date = datestr.date(for: .rfc822){
            return date.timeIntervalSince1970
        }
        return Date().timeIntervalSince1970
    }
//    public func tryMap<NewModel>(_ transform: (M) throws -> NewModel) -> Response<NewModel> {
//
//    }
}
extension Response:CustomStringConvertible, CustomDebugStringConvertible{
    public var description: String{""}
    public var debugDescription: String{""}
}

//
//  File.swift
//  
//
//  Created by supertext on 2021/6/6.
//

import Foundation
public struct Response<M>{
    public let data:Data?
    public let result:Result<M,Error>
    public let request: URLRequest?
    public let response: HTTPURLResponse?
    public var value:M?{ result.value }
    public var error:Error?{ result.error }
    public var statusCode:Int?{ response?.statusCode }
    public init(
        data:Data? = nil,
        result:Result<M,Error>,
        request:URLRequest? = nil,
        response:URLResponse? = nil) {
        self.data = data
        self.result = result
        self.response = response as? HTTPURLResponse
        self.request = request
    }
    public lazy var headers:Headers? = {
        if let values = response?.allHeaderFields as? [String:String] {
            return Headers(values)
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
        let requestDescription = "[Request]:\(urlRequest.debugDescription)"
        let responseDescription = "[Response]: \(response==nil ? "None" :  response!.debugDescription)"
        return """
        \(requestDescription)
        \(responseDescription)
        [Result]: \(result)
        """
    }
}

//
//  Response.swift
//  Airmey
//
//  Created by supertext on 2021/6/09.
//  Copyright © 2021年 airmey. All rights reserved.
//

import Foundation
public struct Response<M>{
    public private(set) var result:Result<M,Error>
    ///The original serialized response data
    public private(set) var data:JSON
    public let task:HTTPTask?
    public var value:M?{ result.value }
    public var error:Error?{ result.error }
    public var statusCode:Int?{ task?.response?.statusCode }
    init(data:JSON = .null, task:HTTPTask? = nil, result:Result<M,Error>) {
        self.data = data
        self.task = task
        self.result = result
    }
    public lazy var headers:HTTPHeaders? = {
        if let values = task?.response?.allHeaderFields as? [String:String] {
            return HTTPHeaders(values)
        }
        return nil
    }()
    public var timestamp:TimeInterval{
        if let datestr = task?.response?.allHeaderFields["Date"] as? String,
           let date = datestr.date(for: .rfc822){
            return date.timeIntervalSince1970
        }
        return Date().timeIntervalSince1970
    }
    func map<NewModel>(_ transform: (M) throws -> NewModel) -> Response<NewModel> {
        let newres = result.flatMap({m -> Result<NewModel,Error> in
            do {
                let res = try transform(m)
                return .success(res)
            }catch{
                return .failure(error)
            }
        })
        return .init(data: data, task: task,result:newres)
    }
}
extension Response:CustomStringConvertible, CustomDebugStringConvertible{
    public var description: String {"\(result)"}
    public var debugDescription: String {
        var body = ""
        if let contentType = task?.request?.header(for: .contentType) {
            if contentType.contains("application/json") {
                body = JSON(parse: task?.request?.httpBody).description
            }else if contentType.contains("form-data"){
                body = "multipart/form-data"
            }
        }
        return """
        ---------------------DEUBG START----------------------
        [\(task?.request?.httpMethod ?? "") URL]:  \(task?.request?.url?.absoluteString ?? "None")
        [Request Data]: \(body)
        [Request Headers]: \(JSON(task?.request?.allHTTPHeaderFields))
        [Request Duration]: \(task?.metrics?.taskInterval.duration ?? 0)s
        [Response Result]: \(result)
        [Response Rriginal Data: \(data)]
        [Response Status]: \(task?.response?.statusCode ?? 0)
        [Response Headers]: \(JSON(task?.response?.allHeaderFields))
        ---------------------DEUBG   END----------------------
        """
    }
}

//
//  AMRequest.swift
//  Airmey
//
//  Created by supertext on 2020/6/24.
//  Copyright © 2020年 airmey. All rights reserved.
//

import Alamofire
import Foundation

public protocol AMModel{
    init(_ json:AMJson)throws
}
extension AMJson:AMModel{
    public init(_ json: AMJson) throws {
        self = json
    }
}
open class AMResponse<M>:CustomStringConvertible, CustomDebugStringConvertible{
    private let af:DataResponse<M,Error>
    init(_ af:DataResponse<M,Error>) {self.af = af}
    public var result:Result<M,Error>{af.result}
    public var data:Data?{af.data}
    public var value:M?{af.value}
    public var error:Error?{af.error}
    public var metrics:URLSessionTaskMetrics?{af.metrics}
    public var request: URLRequest?{af.request}
    public var response: HTTPURLResponse?{af.response}
    public var timestamp:TimeInterval{
        if let datestr = af.response?.allHeaderFields["Date"] as? String,
           let date = datestr.date(for: .rfc822){
            return date.timeIntervalSince1970
        }
        return Date().timeIntervalSince1970
    }
    public var description: String{af.description}
    public var debugDescription: String{af.debugDescription}
    public func tryMap<NewModel>(_ transform: (M) throws -> NewModel) -> AMResponse<NewModel> {
        .init(af.tryMap(transform))
    }
}
open class AMRequest<M>:ExpressibleByStringLiteral{
    public var path: String
    public var params: [String:Any]?
    public var options: AMNetwork.Options?
    public init(_ path:String){
        self.path = path
    }
    open func create(_ json:AMJson)throws ->M{
        throw AMError.network(.invalidURL)
    }
    public required init(stringLiteral value: StringLiteralType) {
        self.path = value
    }
}
extension AMRequest where M:AMModel{
    open func create(_ json: AMJson) throws -> M {
        return try M.init(json)
    }
}

extension AMRequest where M:RandomAccessCollection,
                          M:MutableCollection,
                          M.Element:AMModel{
    open func create(_ json: AMJson) throws -> M {
        guard case .array = json else{
            throw AMError.network(.invalidRespone(info: "Response of dictask must be array"))
        }
        let mod = try json.arrayValue.map{try M.Element.init($0)}
        return mod as! M
    }
}


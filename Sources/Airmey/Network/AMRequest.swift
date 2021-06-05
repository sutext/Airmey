//
//  AMRequest.swift
//  Airmey
//
//  Created by supertext on 2020/6/24.
//  Copyright © 2020年 airmey. All rights reserved.
//

import Alamofire
import Foundation

public protocol AMRequest{
    associatedtype Model
    var path: String{get}
    var params: [String:Any]?{get}
    var options: AMNetwork.Options?{get}
    func convert(_ json:JSON)throws ->Model
}

public struct AMResponse<M>:CustomStringConvertible, CustomDebugStringConvertible{
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


///
//  HTTP.swift
//  Airmey
//
//  Created by supertext on 2021/6/9.
//  Copyright © 2021年 airmey. All rights reserved.
//

import Foundation

///HTTP namespace
public enum HTTP{}
///HTTP finish callback
public typealias HTTPFinish = (Response<JSON>)->Void
///HTTP request Parameters
public typealias HTTPParams = [String:JSONValue]
///HTTP request Errors
public enum HTTPError:Error{
    case encode(Error)
    case download(info:String)
    case invalidURL(url:String)
    case invalidStatus(code:Int,info:JSON)
    case invalidResponse(resp:URLResponse?)
}
///HTTP request methods
public enum HTTPMethod:String{
    case get = "GET"
    case put = "PUT"
    case head = "HEAD"
    case post = "POST"
    case trace = "TRACE"
    case patch = "PATCH"
    case delete = "DELETE"
    case connect = "CONNECT"
    case options = "OPTIONS"
}


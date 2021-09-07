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

public typealias HTTPParams = [String:JSONValue]

public enum HTTPError:Error{
    case encode(Error)
    case download(info:String)
    case invalidURL(url:String)
    case invalidStatus(code:Int,info:JSON)
    case invalidResponse(resp:URLResponse?)
}
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


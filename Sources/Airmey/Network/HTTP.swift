///
//  HTTP.swift
//  Airmey
//
//  Created by supertext on 2021/6/9.
//  Copyright © 2021年 airmey. All rights reserved.
//

import Foundation

public typealias HTTPParams = [String:Any]

public enum HTTPError:Error{
    case status(Int?,info:JSON)
    case encode(Error)
    case system(Error)
    case download(Error)
    case invalidURL(String)
    case invalidData
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


//
//  Request.swift
//  
//
//  Created by supertext on 2021/6/6.
//

import Foundation

public struct Request{
    var path: String
    var params: JSON = nil
    var options: Options? = nil
}


extension Request{
    public typealias Parameters = JSON
    public typealias Verifier = (Response<JSON>) -> Response<JSON>
    public struct Options{
        /// overwrite the global method settings
        public var method:Method?
        /// overwrite the global baseURL settings
        public var baseURL:URL?
        /// merge into global headers
        public var headers:Headers?
        /// overwrite global timeout settings
        public var timeout:TimeInterval?
        /// overwrite the global params encoding settings
//        public var encoding:RequestEncoding?
        /// overwrite the network verify method
        public var verifier:Verifier?
        public init(_ method:Method?=nil,
                    base:URL?=nil,
                    headers:Headers?=nil,
                    timeout:TimeInterval?=nil,
//                    encoding:RequestEncoding?=nil,
                    verifier:Verifier? = nil) {
            self.method = method
            self.baseURL = base
            self.headers = headers
            self.timeout = timeout
            self.verifier = verifier
//            self.encoding = encoding
        }
    }
    public enum Method:String{
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
}

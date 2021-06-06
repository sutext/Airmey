/////
////  Encoding.swift
////  Airmey
////
////  Created by supertext on 2020/6/24.
////  Copyright © 2020年 airmey. All rights reserved.
////
//
//import Foundation
//
//// MARK: -
//
///// Creates a url-encoded query string to be set as or appended to any existing URL query string or set as the HTTP
///// body of the URL request. Whether the query string is set or appended to any existing URL query string or set as
///// the HTTP body depends on the destination of the encoding.
/////
///// The `Content-Type` HTTP header field of an encoded request with HTTP body is set to
///// `application/x-www-form-urlencoded; charset=utf-8`.
/////
///// There is no published specification for how to encode collection types. By default the convention of appending
///// `[]` to the key for array values (`foo[]=1&foo[]=2`), and appending the key surrounded by square brackets for
///// nested dictionary values (`foo[bar]=baz`) is used. Optionally, `ArrayEncoding` can be used to omit the
///// square brackets appended to array keys.
/////
///// `BoolEncoding` can be used to configure how boolean values are encoded. The default behavior is to encode
///// `true` as 1 and `false` as 0.
//public struct URLEncoding {
//    // MARK: Helper Types
//
//    /// Defines whether the url-encoded query string is applied to the existing query string or HTTP body of the
//    /// resulting URL request.
//    public enum Destination {
//        /// Applies encoded query string result to existing query string for `GET`, `HEAD` and `DELETE` requests and
//        /// sets as the HTTP body for requests with any other HTTP method.
//        case methodDependent
//        /// Sets or appends encoded query string result to existing query string.
//        case queryString
//        /// Sets encoded query string result as the HTTP body of the URL request.
//        case httpBody
//
//        func encodesParametersInURL(for method: Request.Method) -> Bool {
//            switch self {
//            case .methodDependent: return [.get, .head, .delete].contains(method)
//            case .queryString: return true
//            case .httpBody: return false
//            }
//        }
//    }
//
//    /// Configures how `Array` parameters are encoded.
//    public enum ArrayEncoding {
//        /// An empty set of square brackets is appended to the key for every value. This is the default behavior.
//        case brackets
//        /// No brackets are appended. The key is encoded as is.
//        case noBrackets
//
//        func encode(key: String) -> String {
//            switch self {
//            case .brackets:
//                return "\(key)[]"
//            case .noBrackets:
//                return key
//            }
//        }
//    }
//
//    /// Configures how `Bool` parameters are encoded.
//    public enum BoolEncoding {
//        /// Encode `true` as `1` and `false` as `0`. This is the default behavior.
//        case numeric
//        /// Encode `true` and `false` as string literals.
//        case literal
//
//        func encode(value: Bool) -> String {
//            switch self {
//            case .numeric:
//                return value ? "1" : "0"
//            case .literal:
//                return value ? "true" : "false"
//            }
//        }
//    }
//
//    // MARK: Properties
//
//    /// Returns a default `URLEncoding` instance with a `.methodDependent` destination.
//    public static var `default`: URLEncoding { URLEncoding() }
//
//    /// Returns a `URLEncoding` instance with a `.queryString` destination.
//    public static var queryString: URLEncoding { URLEncoding(destination: .queryString) }
//
//    /// Returns a `URLEncoding` instance with an `.httpBody` destination.
//    public static var httpBody: URLEncoding { URLEncoding(destination: .httpBody) }
//
//    /// The destination defining where the encoded query string is to be applied to the URL request.
//    public let destination: Destination
//
//    /// The encoding to use for `Array` parameters.
//    public let arrayEncoding: ArrayEncoding
//
//    /// The encoding to use for `Bool` parameters.
//    public let boolEncoding: BoolEncoding
//
//    // MARK: Initialization
//
//    /// Creates an instance using the specified parameters.
//    ///
//    /// - Parameters:
//    ///   - destination:   `Destination` defining where the encoded query string will be applied. `.methodDependent` by
//    ///                    default.
//    ///   - arrayEncoding: `ArrayEncoding` to use. `.brackets` by default.
//    ///   - boolEncoding:  `BoolEncoding` to use. `.numeric` by default.
//    public init(destination: Destination = .methodDependent,
//                arrayEncoding: ArrayEncoding = .brackets,
//                boolEncoding: BoolEncoding = .numeric) {
//        self.destination = destination
//        self.arrayEncoding = arrayEncoding
//        self.boolEncoding = boolEncoding
//    }
//
//    // MARK: Encoding
//
//    public func encode(_ req:Request,with parameters:[String:Any]) -> URLRequest? {
//        guard let base = req.options?.baseURL else {
//            return nil
//        }
//        guard let url = URL(string: req.path, relativeTo: base) else {
//            return nil
//        }
//        var urlRequest = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: req.options?.timeout ?? 60)
//        if case .null = req.params {
//            return urlRequest
//        }
//        if let method = req.options?.method, destination.encodesParametersInURL(for: method) {
//
//            if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) {
//                let percentEncodedQuery = (urlComponents.percentEncodedQuery.map { $0 + "&" } ?? "") + query(parameters)
//                urlComponents.percentEncodedQuery = percentEncodedQuery
//                urlRequest.url = urlComponents.url
//            }
//        } else {
//            if urlRequest.headers["Content-Type"] == nil {
//                urlRequest.headers.update(.contentType("application/x-www-form-urlencoded; charset=utf-8"))
//            }
//
//            urlRequest.httpBody = Data(query(parameters).utf8)
//        }
//
//        return urlRequest
//    }
//
//    /// Creates a percent-escaped, URL encoded query string components from the given key-value pair recursively.
//    ///
//    /// - Parameters:
//    ///   - key:   Key of the query component.
//    ///   - value: Value of the query component.
//    ///
//    /// - Returns: The percent-escaped, URL encoded query string components.
//    public func queryComponents(fromKey key:String ,value:Any) -> [(String, String)] {
//        var components: [(String, String)] = []
//        switch value {
//        case let dictionary as [String:Any]:
//            for (nestedKey, value) in dictionary {
//                components += queryComponents(fromKey: "\(key)[\(nestedKey)]", value: value)
//            }
//        case let array as [Any]:
//            for value in array {
//                components += queryComponents(fromKey: arrayEncoding.encode(key: key), value: value)
//            }
//        case let number as NSNumber:
//            if NSNumber.CType(number) == .bool {
//                components.append((escape(key), escape(boolEncoding.encode(value: number.boolValue))))
//            } else {
//                components.append((escape(key), escape("\(number)")))
//            }
//        case let bool as Bool:
//            components.append((escape(key), escape(boolEncoding.encode(value: bool))))
//        default:
//            components.append((escape(key), escape("\(value)")))
//        }
//        return components
//    }
//
//    /// Creates a percent-escaped string following RFC 3986 for a query string key or value.
//    ///
//    /// - Parameter string: `String` to be percent-escaped.
//    ///
//    /// - Returns:          The percent-escaped `String`.
//    public func escape(_ string: String) -> String {
//        let set: CharacterSet = {
//            let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
//            let subDelimitersToEncode = "!$&'()*+,;="
//            let encodableDelimiters = CharacterSet(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
//
//            return CharacterSet.urlQueryAllowed.subtracting(encodableDelimiters)
//        }()
//        return string.addingPercentEncoding(withAllowedCharacters: set) ?? string
//    }
//
//    private func query(_ parameters: [String: Any]) -> String {
//        var components: [(String, String)] = []
//
//        for key in parameters.keys.sorted(by: <) {
//            let value = parameters[key]!
//            components += queryComponents(fromKey: key, value: value)
//        }
//        return components.map { "\($0)=\($1)" }.joined(separator: "&")
//    }
//}

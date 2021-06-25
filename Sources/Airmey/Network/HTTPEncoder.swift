///
//  HTTPEncoder.swift
//  Airmey
//
//  Created by supertext on 2021/6/09.
//  Copyright © 2021年 airmey. All rights reserved.
//

import Foundation

public protocol HTTPEncoder{
    func encode(
        _ url:URL,
        method:HTTPMethod,
        params:HTTPParams?,
        headers:HTTPHeaders?,
        timeout:TimeInterval) -> Result<URLRequest,Error>
}
///
/// JSON body encoder.
///
/// - Note JSNEncoder will use URLEncoder.query when method = HTTPMethod.get
///
public struct JSNEncoder:HTTPEncoder{
    public init(){}
    public func encode(
        _ url: URL,
        method: HTTPMethod,
        params: HTTPParams?,
        headers:HTTPHeaders?,
        timeout: TimeInterval) -> Result<URLRequest,Error>{
        if case .get = method {
            return URLEncoder.query.encode(url, method: method, params: params, headers: headers, timeout: timeout)
        }
        var urlRequest = URLRequest(url:url , cachePolicy: .useProtocolCachePolicy, timeoutInterval: timeout)
        urlRequest.allHTTPHeaderFields = headers?.values
        urlRequest.httpMethod = method.rawValue
        urlRequest.setHeader("application/json", for: .contentType)
        guard let params = params, params.count>0 else {
            return .success(urlRequest)
        }
        return .init{
            let data = try JSONSerialization.data(withJSONObject: params, options: [])
            urlRequest.httpBody = data
            return urlRequest
        }
    }
}
// MARK: -

/// Creates a url-encoded query string to be set as or appended to any existing URL query string or set as the HTTP
/// body of the URL request. Whether the query string is set or appended to any existing URL query string or set as
/// the HTTP body depends on the destination of the encoding.
///
/// The `Content-Type` HTTP header field of an encoded request with HTTP body is set to
/// `application/x-www-form-urlencoded; charset=utf-8`.
///
/// There is no published specification for how to encode collection types. By default the convention of appending
/// `[]` to the key for array values (`foo[]=1&foo[]=2`), and appending the key surrounded by square brackets for
/// nested dictionary values (`foo[bar]=baz`) is used. Optionally, `ArrayEncoding` can be used to omit the
/// square brackets appended to array keys.
///
/// `BoolEncoding` can be used to configure how boolean values are encoded. The default behavior is to encode
/// `true` as 1 and `false` as 0.
public struct URLEncoder:HTTPEncoder {
    // MARK: Helper Types

    /// Defines whether the url-encoded query string is applied to the existing query string or HTTP body of the
    /// resulting URL request.
    public enum Destination {
        /// Applies encoded query string result to existing query string for `GET`, `HEAD` and `DELETE` requests and
        /// sets as the HTTP body for requests with any other HTTP method.
        case methodDependent
        /// Sets or appends encoded query string result to existing query string.
        case queryString
        /// Sets encoded query string result as the HTTP body of the URL request.
        case httpBody

        func needEncodeInURL(for method: HTTPMethod) -> Bool {
            switch self {
            case .methodDependent: return [.get, .head, .delete].contains(method)
            case .queryString: return true
            case .httpBody: return false
            }
        }
    }

    /// Configures how `Array` parameters are encoded.
    public enum ArrayEncoder {
        /// An empty set of square brackets is appended to the key for every value. This is the default behavior.
        case brackets
        /// No brackets are appended. The key is encoded as is.
        case noBrackets

        func encode(key: String) -> String {
            switch self {
            case .brackets:
                return "\(key)[]"
            case .noBrackets:
                return key
            }
        }
    }

    /// Configures how `Bool` parameters are encoded.
    public enum BoolEncoder {
        /// Encode `true` as `1` and `false` as `0`. This is the default behavior.
        case numeric
        /// Encode `true` and `false` as string literals.
        case literal

        func encode(value: Bool) -> String {
            switch self {
            case .numeric:
                return value ? "1" : "0"
            case .literal:
                return value ? "true" : "false"
            }
        }
    }

    // MARK: Properties

    /// Returns a default `URLEncoder` instance with a `.methodDependent` destination.
    public static var `default`: URLEncoder { URLEncoder() }

    /// Returns a `URLEncoder` instance with a `.queryString` destination.
    public static var query: URLEncoder { URLEncoder(destination: .queryString) }

    /// Returns a `URLEncoder` instance with an `.httpBody` destination.
    public static var body: URLEncoder { URLEncoder(destination: .httpBody) }

    /// The destination defining where the encoded query string is to be applied to the URL request.
    public let destination: Destination

    /// The encoding to use for `Array` parameters.
    public let arrayEncoder: ArrayEncoder

    /// The encoding to use for `Bool` parameters.
    public let boolEncoder: BoolEncoder
    /// Creates an instance using the specified parameters.
    ///
    /// - Parameters:
    ///   - destination:   `Destination` defining where the encoded query string will be applied. `.methodDependent` by default.
    ///   - arrayEncoder: `ArrayEncoder` to use. `.brackets` by default.
    ///   - boolEncoder:  `BoolEncoder` to use. `.numeric` by default.
    public init(
        destination: Destination = .methodDependent,
        arrayEncoder: ArrayEncoder = .brackets,
        boolEncoder: BoolEncoder = .numeric) {
        self.destination = destination
        self.arrayEncoder = arrayEncoder
        self.boolEncoder = boolEncoder
    }

    // MARK: Encoding
    public func encode(
        _ url:URL,
        method:HTTPMethod,
        params:HTTPParams?,
        headers:HTTPHeaders?,
        timeout:TimeInterval)-> Result<URLRequest,Error> {
        var urlRequest = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: timeout)
        urlRequest.httpMethod = method.rawValue
        urlRequest.allHTTPHeaderFields = headers?.values
        guard let params = params?.mapValues(JSON.init) else {
            return .success(urlRequest)
        }
        if destination.needEncodeInURL(for: method) {
            if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) {
                let percentEncodedQuery = (urlComponents.percentEncodedQuery.map { $0 + "&" } ?? "") + query(params)
                urlComponents.percentEncodedQuery = percentEncodedQuery
                urlRequest.url = urlComponents.url
            }
        } else {
            urlRequest.setHeader("application/x-www-form-urlencoded; charset=utf-8", for: .contentType)
            urlRequest.httpBody = Data(query(params).utf8)
        }
        return .success(urlRequest)
    }

    /// Creates a percent-escaped, URL encoded query string components from the given key-value pair recursively.
    ///
    /// - Parameters:
    ///   - key:   Key of the query component.
    ///   - value: Value of the query component.
    ///
    /// - Returns: The percent-escaped, URL encoded query string components.
    private func queryComponents(from key:String ,value:JSON) -> [(String, String)] {
        var components: [(String, String)] = []
        switch value {
        case .null:
            break
        case .bool(let bool):
            components.append((escape(key), escape(boolEncoder.encode(value: bool))))
        case .string(let string):
            components.append((escape(key), escape("\(string)")))
        case .number(let number):
            if number.isBool {
                components.append((escape(key), escape(boolEncoder.encode(value: number.boolValue))))
            } else {
                components.append((escape(key), escape("\(number)")))
            }
        case .object(let dictionary):
            for (nestedKey, value) in dictionary {
                components += queryComponents(from: "\(key)[\(nestedKey)]", value: value)
            }
        case .array(let array):
            for value in array {
                components += queryComponents(from: arrayEncoder.encode(key: key), value: value)
            }
        }
        return components
    }

    /// Creates a percent-escaped string following RFC 3986 for a query string key or value.
    ///
    /// - Parameter string: `String` to be percent-escaped.
    ///
    /// - Returns:          The percent-escaped `String`.
    private func escape(_ string: String) -> String {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        let encodableDelimiters = CharacterSet(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        let set = CharacterSet.urlQueryAllowed.subtracting(encodableDelimiters)
        return string.addingPercentEncoding(withAllowedCharacters: set) ?? string
    }

    private func query(_ parameters: [String: JSON]) -> String {
        var components: [(String, String)] = []

        for key in parameters.keys.sorted(by: <) {
            let value = parameters[key]!
            components += queryComponents(from: key, value: value)
        }
        return components.map { "\($0)=\($1)" }.joined(separator: "&")
    }
}

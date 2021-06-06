///
//  Headers.swift
//  Airmey
//
//  Created by supertext on 2020/6/24.
//  Copyright © 2020年 airmey. All rights reserved.
//

import Foundation
extension Request{
    /// An order-preserving and case-insensitive representation of HTTP headers.
    public struct Headers {
        private var headers: [Header] = []

        /// Creates an empty instance.
        public init() {}

        /// Creates an instance from an array of `HTTPHeader`s. Duplicate case-insensitive names are collapsed into the last
        /// name and value encountered.
        public init(_ headers: [Header]) {
            self.init()

            headers.forEach { update($0) }
        }

        /// Creates an instance from a `[String: String]`. Duplicate case-insensitive names are collapsed into the last name
        /// and value encountered.
        public init(_ dictionary: [String: String]) {
            self.init()

            dictionary.forEach { update(Header(name: $0.key, value: $0.value)) }
        }

        /// Case-insensitively updates or appends an `HTTPHeader` into the instance using the provided `name` and `value`.
        ///
        /// - Parameters:
        ///   - name:  The `HTTPHeader` name.
        ///   - value: The `HTTPHeader value.
        public mutating func add(name: String, value: String) {
            update(Header(name: name, value: value))
        }

        /// Case-insensitively updates or appends the provided `HTTPHeader` into the instance.
        ///
        /// - Parameter header: The `HTTPHeader` to update or append.
        public mutating func add(_ header: Header) {
            update(header)
        }

        /// Case-insensitively updates or appends an `HTTPHeader` into the instance using the provided `name` and `value`.
        ///
        /// - Parameters:
        ///   - name:  The `HTTPHeader` name.
        ///   - value: The `HTTPHeader value.
        public mutating func update(name: String, value: String) {
            update(Header(name: name, value: value))
        }

        /// Case-insensitively updates or appends the provided `HTTPHeader` into the instance.
        ///
        /// - Parameter header: The `HTTPHeader` to update or append.
        public mutating func update(_ header: Header) {
            guard let index = headers.index(of: header.name) else {
                headers.append(header)
                return
            }

            headers.replaceSubrange(index...index, with: [header])
        }

        /// Case-insensitively removes an `HTTPHeader`, if it exists, from the instance.
        ///
        /// - Parameter name: The name of the `HTTPHeader` to remove.
        public mutating func remove(name: String) {
            guard let index = headers.index(of: name) else { return }

            headers.remove(at: index)
        }

        /// Sort the current instance by header name, case insensitively.
        public mutating func sort() {
            headers.sort { $0.name.lowercased() < $1.name.lowercased() }
        }

        /// Returns an instance sorted by header name.
        ///
        /// - Returns: A copy of the current instance sorted by name.
        public func sorted() -> Headers {
            var headers = self
            headers.sort()

            return headers
        }

        /// Case-insensitively find a header's value by name.
        ///
        /// - Parameter name: The name of the header to search for, case-insensitively.
        ///
        /// - Returns:        The value of header, if it exists.
        public func value(for name: String) -> String? {
            guard let index = headers.index(of: name) else { return nil }

            return headers[index].value
        }

        /// Case-insensitively access the header with the given name.
        ///
        /// - Parameter name: The name of the header.
        public subscript(_ name: String) -> String? {
            get { value(for: name) }
            set {
                if let value = newValue {
                    update(name: name, value: value)
                } else {
                    remove(name: name)
                }
            }
        }

        /// The dictionary representation of all headers.
        ///
        /// This representation does not preserve the current order of the instance.
        public var dictionary: [String: String] {
            let namesAndValues = headers.map { ($0.name, $0.value) }

            return Dictionary(namesAndValues, uniquingKeysWith: { _, last in last })
        }
    }
}


extension Request.Headers: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, String)...) {
        self.init()

        elements.forEach { update(name: $0.0, value: $0.1) }
    }
}

extension Request.Headers: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Request.Header...) {
        self.init(elements)
    }
}

extension Request.Headers: Sequence {
    public func makeIterator() -> IndexingIterator<[Request.Header]> {
        headers.makeIterator()
    }
}

extension Request.Headers: Collection {
    public var startIndex: Int {
        headers.startIndex
    }

    public var endIndex: Int {
        headers.endIndex
    }

    public subscript(position: Int) -> Request.Header {
        headers[position]
    }

    public func index(after i: Int) -> Int {
        headers.index(after: i)
    }
}

extension Request.Headers: CustomStringConvertible {
    public var description: String {
        headers.map { $0.description }
            .joined(separator: "\n")
    }
}

extension Request{
    /// A representation of a single HTTP header's name / value pair.
    public struct Header: Hashable {
        /// Name of the header.
        public let name: String

        /// Value of the header.
        public let value: String

        /// Creates an instance from the given `name` and `value`.
        ///
        /// - Parameters:
        ///   - name:  The name of the header.
        ///   - value: The value of the header.
        public init(name: String, value: String) {
            self.name = name
            self.value = value
        }
    }
}

extension Request.Header: CustomStringConvertible {
    public var description: String {
        "\(name): \(value)"
    }
}

extension Request.Header {
    /// Returns an `Accept` header.
    ///
    /// - Parameter value: The `Accept` value.
    /// - Returns:         The header.
    public static func accept(_ value: String) -> Request.Header {
        Request.Header (name: "Accept", value: value)
    }

    /// Returns an `Accept-Charset` header.
    ///
    /// - Parameter value: The `Accept-Charset` value.
    /// - Returns:         The header.
    public static func acceptCharset(_ value: String) -> Request.Header {
        Request.Header (name: "Accept-Charset", value: value)
    }

    /// Returns an `Accept-Language` header.
    ///
    /// Alamofire offers a default Accept-Language header that accumulates and encodes the system's preferred languages.
    /// Use `HTTPHeader.defaultAcceptLanguage`.
    ///
    /// - Parameter value: The `Accept-Language` value.
    ///
    /// - Returns:         The header.
    public static func acceptLanguage(_ value: String) -> Request.Header {
        Request.Header (name: "Accept-Language", value: value)
    }

    /// Returns an `Accept-Encoding` header.
    ///
    /// Alamofire offers a default accept encoding value that provides the most common values. Use
    /// `HTTPHeader.defaultAcceptEncoding`.
    ///
    /// - Parameter value: The `Accept-Encoding` value.
    ///
    /// - Returns:         The header
    public static func acceptEncoding(_ value: String) -> Request.Header {
        Request.Header (name: "Accept-Encoding", value: value)
    }

    /// Returns a `Basic` `Authorization` header using the `username` and `password` provided.
    ///
    /// - Parameters:
    ///   - username: The username of the header.
    ///   - password: The password of the header.
    ///
    /// - Returns:    The header.
    public static func authorization(username: String, password: String) -> Request.Header {
        let credential = Data("\(username):\(password)".utf8).base64EncodedString()

        return authorization("Basic \(credential)")
    }

    /// Returns a `Bearer` `Authorization` header using the `bearerToken` provided
    ///
    /// - Parameter bearerToken: The bearer token.
    ///
    /// - Returns:               The header.
    public static func authorization(bearerToken: String) -> Request.Header {
        authorization("Bearer \(bearerToken)")
    }

    /// Returns an `Authorization` header.
    ///
    /// Alamofire provides built-in methods to produce `Authorization` headers. For a Basic `Authorization` header use
    /// `HTTPHeader.authorization(username:password:)`. For a Bearer `Authorization` header, use
    /// `HTTPHeader.authorization(bearerToken:)`.
    ///
    /// - Parameter value: The `Authorization` value.
    ///
    /// - Returns:         The header.
    public static func authorization(_ value: String) -> Request.Header {
        Request.Header (name: "Authorization", value: value)
    }

    /// Returns a `Content-Disposition` header.
    ///
    /// - Parameter value: The `Content-Disposition` value.
    ///
    /// - Returns:         The header.
    public static func contentDisposition(_ value: String) -> Request.Header {
        Request.Header (name: "Content-Disposition", value: value)
    }

    /// Returns a `Content-Type` header.
    ///
    /// All Alamofire `ParameterEncoding`s and `ParameterEncoder`s set the `Content-Type` of the request, so it may not be necessary to manually
    /// set this value.
    ///
    /// - Parameter value: The `Content-Type` value.
    ///
    /// - Returns:         The header.
    public static func contentType(_ value: String) -> Request.Header {
        Request.Header (name: "Content-Type", value: value)
    }

    /// Returns a `User-Agent` header.
    ///
    /// - Parameter value: The `User-Agent` value.
    ///
    /// - Returns:         The header.
    public static func userAgent(_ value: String) -> Request.Header {
        Request.Header (name: "User-Agent", value: value)
    }
}

extension Array where Element == Request.Header {
    /// Case-insensitively finds the index of an `HTTPHeader` with the provided name, if it exists.
    func index(of name: String) -> Int? {
        let lowercasedName = name.lowercased()
        return firstIndex { $0.name.lowercased() == lowercasedName }
    }
}

// MARK: - Defaults

extension Request.Headers {
    /// The default set of `HTTPHeaders` used by Alamofire. Includes `Accept-Encoding`, `Accept-Language`, and
    /// `User-Agent`.
    public static let `default`: Request.Headers = [.defaultAcceptEncoding,
                                                .defaultAcceptLanguage,
                                                .defaultUserAgent]
}

extension Request.Header {
    /// Returns Alamofire's default `Accept-Encoding` header, appropriate for the encodings supported by particular OS
    /// versions.
    ///
    /// See the [Accept-Encoding HTTP header documentation](https://tools.ietf.org/html/rfc7230#section-4.2.3) .
    public static let defaultAcceptEncoding: Request.Header = {
        let encodings: [String]
        if #available(iOS 11.0, macOS 10.13, tvOS 11.0, watchOS 4.0, *) {
            encodings = ["br", "gzip", "deflate"]
        } else {
            encodings = ["gzip", "deflate"]
        }

        return .acceptEncoding(encodings.qualityEncoded())
    }()

    /// Returns Alamofire's default `Accept-Language` header, generated by querying `Locale` for the user's
    /// `preferredLanguages`.
    ///
    /// See the [Accept-Language HTTP header documentation](https://tools.ietf.org/html/rfc7231#section-5.3.5).
    public static let defaultAcceptLanguage: Request.Header = {
        .acceptLanguage(Locale.preferredLanguages.prefix(6).qualityEncoded())
    }()

    /// Returns Alamofire's default `User-Agent` header.
    ///
    /// See the [User-Agent header documentation](https://tools.ietf.org/html/rfc7231#section-5.5.3).
    ///
    /// Example: `iOS Example/1.0 (org.alamofire.iOS-Example; build:1; iOS 13.0.0) Alamofire/5.0.0`
    public static let defaultUserAgent: Request.Header = {
        let info = Bundle.main.infoDictionary
        let executable = (info?[kCFBundleExecutableKey as String] as? String) ??
            (ProcessInfo.processInfo.arguments.first?.split(separator: "/").last.map(String.init)) ??
            "Unknown"
        let bundle = info?[kCFBundleIdentifierKey as String] as? String ?? "Unknown"
        let appVersion = info?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let appBuild = info?[kCFBundleVersionKey as String] as? String ?? "Unknown"
        let osNameVersion: String = {
            let version = ProcessInfo.processInfo.operatingSystemVersion
            let versionString = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
            return "iOS \(versionString)"
        }()
        let alamofireVersion = "Airmey/\(osNameVersion)"

        let userAgent = "\(executable)/\(appVersion) (\(bundle); build:\(appBuild); \(osNameVersion)) \(alamofireVersion)"
        return .userAgent(userAgent)
    }()
}

extension Collection where Element == String {
    func qualityEncoded() -> String {
        enumerated().map { index, encoding in
            let quality = 1.0 - (Double(index) * 0.1)
            return "\(encoding);q=\(quality)"
        }.joined(separator: ", ")
    }
}

// MARK: - System Type Extensions

//extension URLRequest {
//    /// Returns `allHTTPHeaderFields` as `HTTPHeaders`.
//    public var headers: Request.Headers {
//        get { allHTTPHeaderFields.map(Request.Headers.init) ?? Request.Headers() }
//        set { allHTTPHeaderFields = newValue.dictionary }
//    }
//}
//
//extension HTTPURLResponse {
//    /// Returns `allHeaderFields` as `HTTPHeaders`.
//    public var headers: Request.Headers {
//        (allHeaderFields as? [String: String]).map(Request.Headers.init) ?? Request.Headers()
//    }
//}
//
//extension URLSessionConfiguration {
//    /// Returns `httpAdditionalHeaders` as `HTTPHeaders`.
//    public var headers: Request.Headers {
//        get { (httpAdditionalHeaders as? [String: String]).map(Request.Headers.init) ?? Request.Headers() }
//        set { httpAdditionalHeaders = newValue.dictionary }
//    }
//}

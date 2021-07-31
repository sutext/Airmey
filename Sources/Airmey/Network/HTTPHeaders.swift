///
//  HTTPHeaders.swift
//  Airmey
//
//  Created by supertext on 2021/6/09.
//  Copyright © 2021年 airmey. All rights reserved.
//

import Foundation

public struct HTTPHeaders {
    public enum Field:String {
        case accept             = "Accept"
        case acceptCharset      = "Accept-Charset"
        case acceptLanguage     = "Accept-Language"
        case acceptEncoding     = "Accept-Encoding"
        case authorization      = "Authorization"
        case contentType        = "Content-Type"
        case contentDisposition = "Content-Disposition"
        case userAgent          = "User-Agent"
    }
    public private(set) var values: [String:String] = [:]
    public init(_ values:[String:String]? = nil) {
        self.values = values ?? [:]
    }
    public mutating func merge(_ other:Self){
        self.merge(other.values)
    }
    public mutating func merge(_ other:[String:String]){
        for item in other {
            self[item.key] = item.value
        }
    }
    public mutating func merge(_ other:[Field:String]){
        for item in other {
            self[item.key.rawValue] = item.value
        }
    }
    public mutating func authorization(basic username:String,password:String){
        let credential = Data("\(username):\(password)".utf8).base64EncodedString()
        self[.authorization] = "Basic \(credential)"
    }
    public mutating func authorization(bearer token:String){
        self[.authorization] = "Bearer \(token)"
    }
    public subscript(_ name: String) -> String? {
        get { values[name] }
        set {
            if let value = newValue {
                values[name] = value
            } else {
                values.removeValue(forKey: name)
            }
        }
    }
    public subscript(_ field: Field) -> String? {
        get { values[field.rawValue] }
        set {
            if let value = newValue {
                values[field.rawValue] = value
            } else {
                values.removeValue(forKey: field.rawValue)
            }
        }
    }
    public static var `default`:HTTPHeaders = [
        .userAgent:defaultUserAgent,
        .acceptEncoding:defaultAcceptEncoding,
        .acceptLanguage:defaultAcceptLanguage
    ]
    /// See the [Accept-Encoding HTTP header documentation](https://tools.ietf.org/html/rfc7230#section-4.2.3) .
    public static let defaultAcceptEncoding: String = {
        let encodings: [String]
        if #available(iOS 11.0, macOS 10.13, tvOS 11.0, watchOS 4.0, *) {
            encodings = ["br", "gzip", "deflate"]
        } else {
            encodings = ["gzip", "deflate"]
        }
        return encodings.qualityEncoded()
    }()

    /// See the [Accept-Language HTTP header documentation](https://tools.ietf.org/html/rfc7231#section-5.3.5).
    public static let defaultAcceptLanguage: String = {
        Locale.preferredLanguages.prefix(6).qualityEncoded()
    }()
    /// See the [User-Agent header documentation](https://tools.ietf.org/html/rfc7231#section-5.5.3).
    ///
    /// Example: `iOS Example/1.0 (com.airmey.network; build:1; iOS 13.0.0) Airmey/5.0.0`
    public static let defaultUserAgent: String = {
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
        let AirmeyVersion = "Airmey/\(osNameVersion)"

        return  "\(executable)/\(appVersion) (\(bundle); build:\(appBuild); \(osNameVersion)) \(AirmeyVersion)"
    }()
}
extension HTTPHeaders:ExpressibleByDictionaryLiteral{
    public init(dictionaryLiteral elements: (Field, String)...) {
        self.values = elements.reduce(into: [:]){$0[$1.0.rawValue]=$1.1}
    }
}
extension Collection where Element == String {
    fileprivate func qualityEncoded() -> String {
        enumerated().map { index, encoding in
            let quality = 1.0 - (Double(index) * 0.1)
            return "\(encoding);q=\(quality)"
        }.joined(separator: ", ")
    }
}

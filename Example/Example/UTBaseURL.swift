//
//  UTBaseURL.swift
//  
//
//  Created by supertext on 1/22/22.
//  Copyright © 2022 utown. All rights reserved.
//
///
/// BaseURL 枚举定义
///

import UIKit
import Airmey
let utenv  = UTENV()
class UTENV {
    var env:ENV = .PROD
    var isLogin = true
    var isProd = false
    var token:String?
    var refreshToken:String = "8cac3b140f34471eb9738b00da38d1a7"
    init() {
        self.token = "eyJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE2NjYxNjk2NTMsImV4cCI6MTY2ODc2MTY1Mywiand0X3VzZXIiOnsiZ3VpZCI6IjYxODRkNzQ5NzdjMDRmYzA4YjJlYWM4ZjlmNmQ1MjE3IiwidXNlcklkIjoxMDAwMDAyLCJpZGVudGlmaWVyIjoic3VwZXJ0ZXh0QGljbG91ZC5jb20iLCJuaWNrbmFtZSI6IlN1cGVydGV4dCIsImF2YXRhciI6Imh0dHBzOi8vY2RuLnV0b3duLmlvL2kvMjAyMjEwMDgvMS9hL2IvMWFiNTQ4NWZlYzZmNDQxOThlZWE2ODlkZjgxNjI4NWEucG5nIiwiZmFjZSI6Imh0dHBzOi8vY2RuLnV0b3duLmlvL2kvMjAyMjEwMDgvMC9mLzAvMGYwYzdkYWFjYTNhNDlmOGI3YjA3ODYwN2MzMGE2OWIucG5nIiwiYW5vbnltb3VzIjpmYWxzZSwibGFuZyI6InpoIn19.r60lJ8c3CCfuj_bNJAqPygN-7pS2iza63PUvayxOtQY"
    }
    enum ENV{
        case DEV
        case TEST
        case BETA
        case PROD
    }
}
public struct UTBaseURL:RawRepresentable,ExpressibleByStringLiteral,Equatable{
    public var rawValue: String
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    public init(stringLiteral value: StringLiteralType) {
        self.rawValue = value
    }
    public static let api:UTBaseURL = {
        switch utenv.env {
        case .DEV:
            return "https://api.dev.utown.io:3080"
        case .BETA:
            return "https://api.beta.utown.io"
        case .PROD:
            return "https://api.utown.io"
        case .TEST:
            return "https://api.test.utown.io:32080"
        }
    }()
    
    public static let h5:UTBaseURL = {
        switch utenv.env {
        case .DEV:
            return "https://www.dev.utown.io"
        case .BETA:
            return "https://www.beta.utown.io"
        case .PROD:
            return "https://www.utown.io"
        case .TEST:
            return "https://www.test.utown.io"
        }
    }()
    
    public static let im: UTBaseURL = {
        switch utenv.env {
            case .DEV:
                return "wss://api.dev.utown.io:3080/app/im/connector"
            case .TEST:
                return "wss://api.test.utown.io:32080/app/im/connector"
            case .BETA:
                return "wss://api.beta.utown.io/app/im/connector"
            case .PROD:
                // Note: 暂时没有PROD环境
                return "wss://api.beta.utown.io/app/im/connector"
        }
    }()
    
    public static let base: UTBaseURL = {
        switch utenv.env {
            case .DEV:
                return "https://api.dev.utown.io:3080"
            case .TEST:
                return "https://api.test.utown.io:32080"
            case .BETA:
                return "https://api.beta.utown.io"
            case .PROD:
                return "https://api.utown.io"
        }
    }()
    
    
    public static let colyseus: UTBaseURL = {
        switch utenv.env {
            case .DEV:
                return "scene.dev.utown.io:3080"
            case .TEST:
                return "scene.test.utown.io:32080"
            case .BETA:
                return "scene.beta.utown.io:443"
            case .PROD:
                return "scene.utown.io:443"
        }
    }()
    
    
    public static let source: UTBaseURL = {
        switch utenv.env {
            case .DEV:
                return "https://assets.dev.utown.io"
            case .TEST:
                return "https://assets.test.utown.io"
            case .BETA:
                return "https://assets.beta.utown.io"
            case .PROD:
                return "https://assets.utown.io"
        }
    }()
    
    
    public static let cdn: UTBaseURL = {
        switch utenv.env {
            case .DEV:
                return "https://cdn.dev.utown.io"
            case .TEST:
                return "https://cdn.test.utown.io"
            case .BETA:
                return "https://cdn.beta.utown.io"
            case .PROD:
                return "https://cdn.utown.io"
        }
    }()
}
extension UTBaseURL{
    public var url:URL?{URL(string: rawValue)}
    public var headers:[String:String]{
        let device = UIDevice.current
        let appver:String = "1.0.0"
        var result:[String:String] = [
            "ostype":"ios",
            "sysver":device.systemVersion,
            "apiver":"1",
            "appver":appver,
            "uuid":AMPhone.uuid,
            "lang":"zh"
        ]
        if utenv.isLogin, let token = utenv.token{
            result["Authorization"] = "Bearer \(token)"
        }
        return result
    }
}

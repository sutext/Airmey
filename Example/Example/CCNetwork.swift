//
//  CCNetwork.swift
//  Example
//
//  Created by supertext on 5/31/21.
//

import UIKit
import Airmey

let env  = ENV()
class ENV {
    var isLogin = false
    var isProd = false
    var token:String?
    init() {
        
    }
}
public let net = CCNetwork()
public enum CCLoginType :String,CaseIterable,AMTextConvertible{
    case apple
    case google
    case facebook
    public var text: String?{rawValue}
}
public class CCNetwork: AMNetwork {
    fileprivate init(){
        super.init(baseURL: BaseURL.api.rawValue)
    }
    public override var method: AMNetwork.Method{
        .post
    }
    public override func resolve(_ json: AMJson) throws -> AMJson {
        guard let code = json["code"].int,code==1 else {
            throw Error.invalidCode(code: json["code"].int)
        }
        let data = json["data"]
        if case .null = data{
            throw Error.invalidData
        }
        return data
    }
    public override var headers: [String : String]{
        let device = UIDevice.current
        let info = Bundle.main.infoDictionary
        var result:[String:String] = [
            "ostype":"ios",
            "sysver":device.systemVersion,
            "apiver":"1",
            "appver":(info?["CFBundleShortVersionString"] as? String) ?? "1.0.0",
            "uuid":AMPhone.uuid,
            "lang":"zh"
        ]
        if env.isLogin ,let token = env.token{
            result["token"] = token
        }
        return result
    }
    @discardableResult
    func request(_ req: CCRequest, completion: ((AMResponse<AMJson>) -> Void)? = nil) -> AMNetwork.Task? {
        return self.request(req.path, params: req.params, options: req.options, completion: completion)
    }
}
extension CCNetwork{
    public struct BaseURL:RawRepresentable,ExpressibleByStringLiteral{
        public var rawValue: String
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        public init(stringLiteral value: String) {
            self.rawValue = value
        }
        public var url:URL?{URL(string: rawValue)}
    }
    
}
extension CCNetwork.BaseURL{
    public static let api:Self = {
        if env.isProd{
            return "https://api.cc.lerjin.com"
        }else{
            return "https://api.ccdev.lerjin.com"
        }
    }()
    public static let ugc:Self = {
        if env.isProd{
            return "https://ugc.cc.lerjin.com"
        }else{
            return "https://ugc.ccdev.lerjin.com"
        }
    }()
    public static let core:Self = {
        if env.isProd{
            return "https://core.cc.lerjin.com"
        }else{
            return "https://core.ccdev.lerjin.com"
        }
    }()
    public static let feed:Self = {
        if env.isProd{
            return "https://feeds.cc.lerjin.com"
        }else{
            return "https://feeds.ccdev.lerjin.com"
        }
    }()
}
extension AMNetwork.Options{
    public static func post(_ base:CCNetwork.BaseURL)->AMNetwork.Options{
        .init(.post,base: base.url)
    }
    public static func get(_ base:CCNetwork.BaseURL)->AMNetwork.Options{
        .init(.get,base: base.url)
    }
}
extension CCNetwork{
    enum Error:Swift.Error {
        case invalidCode(code:Int?)
        case invalidData
    }
}
struct CCRequest :ExpressibleByStringLiteral{
    var path: String
    var params: [String:Any]?
    var options: AMNetwork.Options?
    init(stringLiteral value: StringLiteralType) {
        self.path = value
    }
}
extension CCRequest{
    static func login(_ token:String,type:String)->Self{
        var req:CCRequest = "account/thirdPartyLogin"
        req.params = ["type":type,"credential":token]
        req.options = .post(.api)
        return req
    }
}

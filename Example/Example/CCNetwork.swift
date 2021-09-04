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
    var isLogin = true
    var isProd = false
    var token:String?
    init() {
        self.token = "MTg5MzMwZjAtMWE1Ni00MGRkLWI1ZjItMjNhMWQxMmIxOWNl"
    }
}
public let net = CCNetwork()
public enum CCLoginType :String,CaseIterable,AMTextDisplayable{    
    case apple
    case google
    case facebook
    public var displayText: AMDisplayText{rawValue}
}
public class CCNetwork: AMNetwork {
    fileprivate init(){
        super.init(baseURL: BaseURL.api.rawValue)
    }
    public override var method: HTTPMethod{
        .post
    }
    public override var retrier: Retrier?{
        return Retrier(limit:1,policy:.immediately,methods:[.post],statusCodes: [404])
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
    public override func `catch`(_ error: Swift.Error) throws {
        throw Error.invalidData
    }
    public override func verify(_ old: Response<JSON>) -> Response<JSON> {
        old
    }
    @discardableResult
    func request(_ req: CCRequest, completion: ((Response<JSON>) -> Void)? = nil) -> HTTPTask? {
        return self.request(req.path, params: req.params, options: req.options) { resp in
            DispatchQueue.main.async {
                completion?(resp)
            }
        }
    }
}
extension CCNetwork{
    public struct BaseURL:RawRepresentable,ExpressibleByStringLiteral,Equatable{
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
            return "https://newfeeds.cc.lerjin.com"
        }else{
            return "https://newfeeds.ccdev.lerjin.com"
        }
    }()
}
extension AMNetwork.Options{
    public static func post(_ base:CCNetwork.BaseURL)->AMNetwork.Options{
        .init(.post,baseURL: base.url) { old in
            return old.map {
                let json = JSON($0)
                guard case .api = base else{
                    return json
                }
                guard let code = json["code"].int,code==1 else {
                    throw CCNetwork.Error.invalidCode(code: json["code"].intValue)
                }
                let data = json["data"]
                if case .null = data{
                    throw CCNetwork.Error.invalidData
                }
                return data
            }
        }
    }
    public static func get(_ base:CCNetwork.BaseURL)->AMNetwork.Options{
        .init(.get,baseURL: base.url,headers: ["test":"testxxx"]) { old in
            return old.map {
                let json = JSON($0)
                guard case .api = base else{
                    return json
                }
                guard let code = json["code"].int,code==1 else {
                    throw CCNetwork.Error.invalidCode(code: json["code"].intValue)
                }
                let data = json["data"]
                if case .null = data{
                    throw CCNetwork.Error.invalidData
                }
                return data
            }
        }
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
    var params: HTTPParams?
    var options: AMNetwork.Options?
    init(stringLiteral value: StringLiteralType) {
        self.path = value
    }
}
class UploadAvatar: AMFormUpload {
    var path: String
    var params: HTTPParams?
    var options: AMNetwork.Options?
    var form: FormData
    func convert(_ json: JSON) throws -> JSON {
        json
    }
    init(_ avatar:UIImage,token:String) {
        self.path = "file/upload/headpic"
        self.options = .post(.api)
        self.form = FormData()
        self.params = ["token":token,"extension":"jpg"]
        if let data = avatar.jpegData(compressionQuality: 1){
            self.form.append(data, withName: "headpic",fileName: "headpic.jpg",mimeType: "image/jpeg")
        }
    }
}
class DownloadImage: AMDownload {        
    var url: String
    var queue: DispatchQueue?
    var params: HTTPParams?
    var headers: [String:String]?
    var transfer: DownloadTask.URLTransfer?
    init(_ url:String) {
        self.url = url
//        self.transfer = { tempFile,response in
//            URL(fileURLWithPath: "\(AMPhone.cacheDir)/testfile1/\(tempFile.lastPathComponent)")
//        }
    }
}
extension CCRequest{
    static func login(_ token:String,type:String)->Self{
        var req:CCRequest = "account/thirdPartyLogin"
        req.params = ["type":type,"credential":token]
        req.options = .post(.api)
        return req
    }
    static func headerToken()->Self{
        var req:CCRequest = "file/upload/headpic/token"
        req.options = .post(.api)
        return req
    }
}

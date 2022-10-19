//
//  UTNetwork.swift
//  Global
//
//  Created by supertext on 1/22/22.
//  Copyright © 2022 utown. All rights reserved.
//

import Airmey
import UIKit



/// 全局网络控制句柄 用于调用网络请求
public let utnet = UTNetwork()
///网络请求基本配置中心
///提供默认网络请求参数设置
///提供网络全局异常捕获解析
public class UTNetwork: AMNetwork {
    fileprivate init(){
        super.init(baseURL: UTBaseURL.api.rawValue)
    }
    public override var method: HTTPMethod{.post}
    public override var debug: Bool{ false }
    public override var timeout: TimeInterval { 20 }
    public override func verify(_ resp: Response<JSON>) throws -> AMNetwork.VerifyResult {
        guard let error = resp.error as? HTTPError else{
            return .none
        }
        if case .invalidStatus(let code, _) = error {
            if code == 401  {
                print("401")
                if resp.isRefreshToken{
                    return .none
                }
                if refreshToken() {
                    var r = resp.task?.request
                    r?.setHeader("Bearer \(utenv.token!)", for: .authorization)
                    return .restart(r)
                }else{
                    return .none
                }
            }
        }
        return .none
    }
    private var refreshedRecently:Bool = false
    private let lock = AMLock()
    func refreshToken()->Bool{
        lock.lock()
        if self.refreshedRecently {
            return true
        }
        let semaphore = DispatchSemaphore(value: 0)
        var result:Bool = false
        print("refresh token")
        self.request("/public/user/refresh-token",params: ["refreshToken":utenv.refreshToken]){
            if let token = $0.value?["accessToken"].string,
               let rtoken = $0.value?["refreshToken"].string{
                utenv.token = token
                utenv.refreshToken = rtoken
                self.refreshedRecently  = true
                result = true
            }else{
                /// TODO jump login
            }
            semaphore.signal()
        }
        semaphore.wait()
        DispatchQueue.main.asyncAfter(deadline: .now()+60) {
            self.refreshedRecently = false
        }
        lock.unlock()
        return result
    }
}
extension Response{
    var isRefreshToken:Bool {
        return self.task?.request?.url?.absoluteString.contains( "/public/user/refresh-token") ?? false
    }
}
extension AMNetwork.Options{
    ///快捷构造get请求options
    public static func get(_ base:UTBaseURL,retry:Retrier?=nil)->AMNetwork.Options{
        .init(.get,baseURL: base.url,retrier: retry, headers: base.headers)
    }
    ///快捷构造post 请求options
    public static func post(_ base:UTBaseURL,retry:Retrier?=nil)->AMNetwork.Options{
        .init(.post,baseURL: base.url,retrier: retry, headers: base.headers)
    }
    ///快捷构造delete 请求options
    public static func delete(_ base:UTBaseURL,retry:Retrier?=nil)->AMNetwork.Options{
        .init(.delete,baseURL: base.url,retrier: retry, headers: base.headers)
    }
    public mutating func addHeaders(_ headers:[String:String]){
        guard var value = self.headers  else{
            self.headers = headers
            return
        }
        for item in headers {
            value[item.key] = item.value
        }
        self.headers = value
    }
}

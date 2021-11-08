//
//  AMRequest.swift
//  Airmey
//
//  Created by supertext on 2021/6/09.
//  Copyright © 2021年 airmey. All rights reserved.
//

import Foundation

/// Request Parameters protocol
/// Do not declare new conformances to this protocol
/// they will not work as expected.
public protocol Parameters{}
extension HTTPParams:Parameters{}
extension Array:Parameters where Element == HTTPParams{}

extension Parameters{
    public var json:JSON?{
        switch self {
        case let dic as HTTPParams:
            return dic.isEmpty ? nil : JSON(dic)
        case let ary as [HTTPParams]:
            return ary.isEmpty ? nil : JSON(ary)
        default:
            fatalError("The parameters must be HTTPParams or [HTTPParams] !")
        }
    }
}

public protocol AMRequest{
    associatedtype Model
    /// relative request url
    var path: String{get}
    /// request params
    var params: Parameters?{get}
    /// request options
    var options: AMNetwork.Options?{get}
    /// model convert method
    func convert(_ json:JSON)throws ->Model
}
public protocol AMFileUpload:AMRequest{
    /// upload file url
    var file:URL{ get }
}
public protocol AMFormUpload:AMRequest{
    /// upload form data
    var form:FormData{ get }
}

public protocol AMDownload{
    /// full download url
    var url: String{get}
    /// callback queue if nil use main
    var queue:DispatchQueue?{get}
    /// url params coding
    var params: Parameters?{get}
    /// http headers
    var headers: [String:String]?{get}
    /// resolve download file location
    var transfer:DownloadTask.URLTransfer?{get}
}

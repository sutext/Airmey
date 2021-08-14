//
//  AMRequest.swift
//  Airmey
//
//  Created by supertext on 2021/6/09.
//  Copyright © 2021年 airmey. All rights reserved.
//

import Foundation

public protocol AMRequest{
    associatedtype Model
    /// relative request url
    var path: String{get}
    /// request params
    var params: HTTPParams?{get}
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
    var params: HTTPParams?{get}
    /// http headers
    var headers: [String:String]?{get}
    /// resolve download file location
    var transfer:DownloadTask.URLTransfer?{get}
}

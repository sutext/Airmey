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
    var path: String{get}
    var params: HTTPParams?{get}
    var options: AMNetwork.Options?{get}
    func convert(_ json:JSON)throws ->Model
}
public protocol AMFileUpload:AMRequest{
    var file:URL{get}
}
public protocol AMFormUpload:AMRequest{
    var form:FormData{get}
}

public protocol AMDownload{
    var url: String{get}
    var params: HTTPParams?{get}
    var headers: [String:String]?{get}
    func location(for tempFile:URL,and response:HTTPURLResponse?)->URL
}

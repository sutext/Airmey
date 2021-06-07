//
//  Request.swift
//  
//
//  Created by supertext on 2021/6/6.
//

import UIKit

public protocol Request{
    associatedtype Model
    var path: String{get}
    var params: [String:Any]?{get}
    var options: AMNetwork.Options?{get}
    func convert(_ json:JSON)throws ->Model
}

public enum Uploadable {
    case image(image:UIImage)
    case file(url:URL,mimeType:String?=nil,fileName:String?=nil)
    case data(data:Data,mimeType:String?=nil,fileName:String?=nil)
}

//
//  AMUpload.swift
//  Airmey
//
//  Created by supertext on 2020/6/24.
//  Copyright © 2020年 airmey. All rights reserved.
//

import UIKit
import Alamofire

public class AMUpload {
    public enum DataType {
        case plain(text:String)
        case image(image:UIImage)
        case file(url:URL,mimeType:String?,fileName:String?)
        case data(data:Data,mimeType:String?,fileName:String?)
    }
    public private(set) var type:DataType
    public private(set) var name:String
    init(name:String,type:DataType){
        self.name = name
        self.type = type
    }
    public convenience init(name:String,image:UIImage) {
        self.init(name:name,type:.image(image:image))
    }
    public convenience init(name:String,value:String){
        self.init(name:name,type:.plain(text: value))
    }
    public convenience init(name:String,fileURL:URL,mimeType:String,fileName:String){
        self.init(name:name,type:.file(url: fileURL, mimeType: mimeType, fileName: fileName))
    }
    public convenience init(name:String,data:Data,mimeType:String,fileName:String){
        self.init(name:name,type:.data(data: data, mimeType: mimeType, fileName: fileName))
    }
}
public extension MultipartFormData{
    func append(object:AMUpload){
        switch object.type {
        case .data(let data, let mimeType, let fileName):
            guard let mimeType = mimeType else {
                self.append(data, withName: object.name)
                return
            }
            guard let fileName = fileName else {
                self.append(data, withName: object.name, mimeType: mimeType)
                return
            }
            self.append(data, withName: object.name, fileName: fileName, mimeType: mimeType)
        case .file(let url, let mimeType,let fileName):
            guard let type = mimeType,let fname = fileName else{
                self.append(url, withName: object.name)
                return
            }
            self.append(url, withName: object.name, fileName: fname, mimeType: type)
        case .image(let image):
            if let data = image.jpegData(compressionQuality: 0.9) {
                self.append(data, withName: object.name,fileName:"image.jpg", mimeType: "image/jpeg")
            }
        case .plain(let text):
            if let data = text.data(using: .utf8, allowLossyConversion: false) {
                self.append(data, withName: object.name)
            }
        }
    }
}
open class AMUploadRequest<M>:AMRequest<M>{
    public var uploads:[AMUpload] = []
}

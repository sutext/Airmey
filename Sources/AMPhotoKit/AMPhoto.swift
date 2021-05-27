//
//  AMPhoto.swift
//  
//
//  Created by supertext on 4/29/21.
//

import UIKit
import Photos
import Airmey

open class AMPhoto: NSObject {
    public enum SourceType {
        case local
        case album
        case remote
    }
    public private(set) var asset:PHAsset?
    public private(set) var thumb:UIImage?
    public private(set) var image:UIImage?
    public private(set) var thumbURL:String?
    public private(set) var imageURL:String?
    public private(set) var sourceType:SourceType
    public init(asset:PHAsset) {
        self.sourceType = .album
        self.asset = asset
        super.init()
    }
    public init(image:UIImage,thumb:UIImage) {
        self.sourceType = .local
        super.init()
        self.image = image
        self.thumb = thumb
    }
    public init (imageURL:String,thumbURL:String){
        self.sourceType = .remote
        super.init()
        self.imageURL = imageURL
        self.thumbURL = thumbURL
    }
}
extension UIImageView{
    @nonobjc public func setImage(with model:AMPhoto,placeholder:UIImage?  = nil,finish:AMImageCache.FinishLoadHandler? = nil){
        switch model.sourceType {
        case .local:
            self.image = model.image
        case .album:
            self.setImage(with: model.asset!, placeholder: placeholder, finish: finish)
        case .remote:
            self.setImage(with: model.imageURL!, placeholder: placeholder, finish: finish)
        }
    }
    @nonobjc public func setThumb(with model:AMPhoto,thumbSize:CGSize,placeholder:UIImage?  = nil,finish:AMImageCache.FinishLoadHandler? = nil){
        switch model.sourceType {
        case .local:
            self.image = model.thumb
        case .album:
            self.setThumb(with: model.asset!, thumbSize: thumbSize, placeholder: placeholder, finish: finish)
        case .remote:
            self.setImage(with: model.thumbURL!, placeholder: placeholder, finish: finish)
        }
    }
}

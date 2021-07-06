//
//  AMPhoto.swift
//  
//
//  Created by supertext on 4/29/21.
//

import UIKit
import Photos
import Airmey
public class AMPhoto:NSObject{
    public enum Source {
        case local(image:UIImage,thumb:UIImage)
        case album(asset:PHAsset)
        case remote(imageURL:String,thumbURL:String)
    }
    public let source:Source
    public init(asset:PHAsset) {
        self.source = .album(asset: asset)
        super.init()
    }
    public init(image:UIImage,thumb:UIImage) {
        self.source = .local(image: image, thumb: thumb)
        super.init()
    }
    public init (imageURL:String,thumbURL:String){
        self.source = .remote(imageURL: imageURL, thumbURL: thumbURL)
        super.init()
    }
}

extension UIImageView{
    @nonobjc public func setImage(with model:AMPhoto,placeholder:UIImage?  = nil,finish:((UIImageView,Result<UIImage,Error>)->Void)? = nil){
        switch model.source {
        case .local(let image,_):
            self.image = image
        case .album(let asset):
            self.setImage(with: asset, placeholder: placeholder, finish: finish)
        case .remote(let imageURL,_):
            self.setImage(with: imageURL, placeholder: placeholder, finish: finish)
        }
    }
    @nonobjc public func setThumb(with model:AMPhoto,size:CGSize,placeholder:UIImage?  = nil,finish:((UIImageView,Result<UIImage,Error>)->Void)? = nil){
        switch model.source {
        case .local(_,let thumb):
            self.image = thumb
        case .album(let asset):
            self.setThumb(with: asset, size: size, placeholder: placeholder, finish: finish)
        case .remote(_,let thumbURL):
            self.setImage(with: thumbURL, placeholder: placeholder, finish: finish)
        }
    }
}

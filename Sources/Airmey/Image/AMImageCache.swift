//
//  AMImageCache.swift
//  Airmey
//
//  Created by supertext on 2020/9/7.
//  Copyright © 2020年 airmey. All rights reserved.
//

import UIKit
import Alamofire
import Photos

public class AMImageCache {
    public static let shared = AMImageCache()
    public typealias FinishLoadHandler = (Result<UIImage,Error>)->Void
    private let fetchQueue = OperationQueue()//phasset fetch queue
    private let imageCache = NSCache<NSString,UIImage>()//phasset image cache
    private let thumbCache = NSCache<NSString,UIImage>()//phasset thumb cache
    private let memeryCache = NSCache<NSString,NSData>()
    private let diskCache = URLCache(memoryCapacity: 50*1024*1024, diskCapacity: 500*1024*1024, diskPath: "com.airmey.image.downloader")
    private lazy var downloader:Session = {
        return Session(configuration: self.sessionConfig)
    }()
    private init(){
        self.thumbCache.countLimit = 50
        self.imageCache.countLimit = 5
        self.fetchQueue.maxConcurrentOperationCount = 3
    }
    private var sessionConfig:URLSessionConfiguration{
        let config = URLSessionConfiguration.default
        config.headers = HTTPHeaders.default
        config.urlCache = self.diskCache
        config.httpShouldSetCookies = true;
        config.httpShouldUsePipelining = false
        config.requestCachePolicy = .useProtocolCachePolicy
        config.allowsCellularAccess = true;
        config.timeoutIntervalForRequest = 60;
    
        return config;
    }
    private func image(with asset:PHAsset,imageSize:CGSize)throws ->UIImage{
        let options = PHImageRequestOptions()
        options.isSynchronous = true;
        var image:UIImage?
        var userInfo:[AnyHashable:Any]?
        PHImageManager.default().requestImage(for: asset, targetSize: imageSize, contentMode: .default, options: options) { (img, info) in
            image = img
            userInfo = info
        }
        guard let img = image else {
            throw AMError.image(.system(info: userInfo))
        }
        return img;
    }
}
extension AMImageCache{
    public var diskUseage:Int{
        return self.diskCache.currentDiskUsage
    }
    public func clearDisk(){
        self.diskCache.removeAllCachedResponses()
    }
    public func image(with url:String,scale:CGFloat = 3,finish: FinishLoadHandler?) {
        self.data(with: url) { result in
            switch result{
            case .failure(let err):
                finish?(.failure(err))
            case .success(let data):
                guard let image = AMImage(data: data, scale: scale) else{
                    let error = AMError.image(.invalidData)
                    finish?(.failure(error))
                    return
                }
                finish?(.success(image.value))
            }
        }
    }
    public func data(with url:String,finish:((Result<Data,Error>)->Void)?) {
        let key = url as NSString
        if let data = self.memeryCache.object(forKey: key) {
            finish?(.success(data as Data))
            return
        }
        self.downloader.request(url, method: .get,headers: ["Accept":"image/*"]).responseData { (resp) in
            switch resp.result{
            case .failure(let err):
                finish?(.failure(err))
            case .success(let data):
                self.memeryCache.setObject(data as NSData, forKey: key);
                finish?(.success(data))
            }
        }
    }
}
extension AMImageCache{
    public func image(with asset:PHAsset)throws -> UIImage{
        let maxlen = max(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
        return try self.image(with: asset, imageSize: CGSize(width:maxlen,height:maxlen));
    }
    public func thumb(with asset:PHAsset,thumSize:CGSize)throws -> UIImage{
        return try self.image(with: asset, imageSize: thumSize);
    }
    @discardableResult
    public func data(with asset:PHAsset,finish:@escaping ((Data?,Error?)->Void))->Operation?{
        let operation = BlockOperation()
        operation.addExecutionBlock {
            let options = PHImageRequestOptions()
            options.isSynchronous = true;
            var imageData:Data?
            var userInfo:[AnyHashable:Any]?
            PHImageManager.default().requestImageData(for: asset, options: options, resultHandler: { (data, dataUTI, imageOrientation, info) in
                imageData = data;
                userInfo = info
            })
            DispatchQueue.main.async {
                if(!operation.isCancelled){
                    var error:Error?
                    if imageData == nil {
                        error = AMError.image(.system(info: userInfo))
                    }
                    finish(imageData,error)
                }
            }
        }
        self.fetchQueue.addOperation(operation);
        return operation;
    }
    @discardableResult
    public func image(with asset:PHAsset,finish:@escaping FinishLoadHandler) -> Operation?{
        let key = asset.localIdentifier as NSString
        if let image = self.imageCache.object(forKey: key) {
            finish(.success(image))
            return nil;
        }
        let operation = BlockOperation()
        operation.addExecutionBlock {
            do{
                let image = try self.image(with: asset)
                self.imageCache.setObject(image, forKey: key)
                DispatchQueue.main.async {
                    if(!operation.isCancelled){
                        finish(.success(image))
                    }
                }
            }catch{
                DispatchQueue.main.async {
                    if(!operation.isCancelled){
                        finish(.failure(error))
                    }
                }
            }
        }
        self.fetchQueue.addOperation(operation);
        return operation;
    }
    
    @discardableResult
    public func thumb(with asset:PHAsset,thumbSize:CGSize,finish:@escaping FinishLoadHandler) -> Operation?{
        let key = (asset.localIdentifier+"_mini") as NSString
        if let image = self.thumbCache.object(forKey: key) {
            finish(.success(image))
            return nil;
        }
        let operation = BlockOperation()
        operation.addExecutionBlock {
            do{
                let image = try self.image(with: asset,imageSize:thumbSize)
                self.thumbCache.setObject(image, forKey: key)
                DispatchQueue.main.async {
                    if(!operation.isCancelled){
                        finish(.success(image))
                    }
                }
            }catch{
                DispatchQueue.main.async {
                    if(!operation.isCancelled){
                        finish(.failure(error))
                    }
                }
            }
        }
        self.fetchQueue.addOperation(operation);
        return operation;
    }
}
extension UIImageView{
    @nonobjc public func setImage(with url:String,scale:CGFloat = 3,placeholder:UIImage? = nil,finish:AMImageCache.FinishLoadHandler? = nil)  {
        if let placeholder = placeholder {
            self.image = placeholder;
        }
        AMImageCache.shared.image(with: url,scale:scale) { result in
            switch result{
            case .failure(let err):
                finish?(.failure(err))
            case .success(let image):
                UIView.transition(with: self, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    self.image = image
                }, completion: nil)
            }
        }
    }
    @nonobjc public func setImage(with asset:PHAsset,placeholder:UIImage? = nil,finish:AMImageCache.FinishLoadHandler? = nil){
        if let placeholder = placeholder {
            self.image = placeholder;
        }
        AMImageCache.shared.image(with: asset) { result in
            switch result{
            case .failure(let err):
                finish?(.failure(err))
            case .success(let image):
                UIView.transition(with: self, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    self.image = image
                }, completion: nil)
            }
        }
    }
    @nonobjc public func setThumb(with asset:PHAsset,thumbSize:CGSize,placeholder:UIImage?  = nil,finish:AMImageCache.FinishLoadHandler? = nil){
        if let placeholder = placeholder {
            self.image = placeholder;
        }
        AMImageCache.shared.thumb(with: asset,thumbSize:thumbSize) { result in
            switch result{
            case .failure(let err):
                finish?(.failure(err))
            case .success(let image):
                UIView.transition(with: self, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    self.image = image
                }, completion: nil)
            }
        }
    }
}
extension UIButton{
    @nonobjc public func setImage(with url:String,scale:CGFloat = 3,placeholder:UIImage? = nil,for state:UIControl.State = .normal,finish:AMImageCache.FinishLoadHandler? = nil)  {
        if let placeholder = placeholder {
            self.setImage(placeholder, for: state)
        }
        AMImageCache.shared.image(with: url,scale:scale) { result in
            switch result{
            case .failure(let err):
                finish?(.failure(err))
            case .success(let image):
                UIView.transition(with: self, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    self.setImage(image, for: .normal)
                }, completion: nil)
            }
        }
    }
}

//
//  AMImageCache.swift
//  Airmey
//
//  Created by supertext on 2020/9/7.
//  Copyright © 2020年 airmey. All rights reserved.
//

import UIKit
import Photos

/// image cache controller
public class AMImageCache {
    public static let shared = AMImageCache()
    private let rootQueue = DispatchQueue(label: "com.airmey.imageQueue")
    private let imageCache = NSCache<NSString,UIImage>()//big image cache
    private let thumbCache = NSCache<NSString,UIImage>()//thumb image cache
    private let diskCache = URLCache(memoryCapacity: 50*1024*1024, diskCapacity: 500*1024*1024, diskPath: "com.airmey.image.downloader")
    private let queue = DispatchQueue.main
    private lazy var downloader:URLSession = {
        
        let config = URLSessionConfiguration.default
        config.urlCache = self.diskCache
        config.httpShouldSetCookies = true
        config.httpShouldUsePipelining = false
        config.requestCachePolicy = .useProtocolCachePolicy
        config.allowsCellularAccess = true
        config.timeoutIntervalForRequest = 60
        
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 3
        queue.underlyingQueue = rootQueue
        queue.name = "com.airmey.imageQueue.session"
        queue.qualityOfService = .default
        return URLSession(configuration: config,delegate: nil,delegateQueue: queue)
    }()

    private init(){
        self.thumbCache.countLimit = 50
        self.imageCache.countLimit = 20
    }
}
extension AMImageCache{
    public var diskUseage:Int{
        return self.diskCache.currentDiskUsage
    }
    public func clearDisk(){
        self.diskCache.removeAllCachedResponses()
    }
    public func image(with url:String,scale:CGFloat = 3,finish: ONResult<UIImage>?) {
        let key = url as NSString
        if let image = self.imageCache.object(forKey: key) {
            self.queue.async { finish?(.success(image)) }
            return
        }
        guard let url = URL(string: url) else {
            self.queue.async { finish?(.failure(AMError.invalidURL(url: url))) }
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("image/*", forHTTPHeaderField: "Accept")
        self.downloader.dataTask(with: request) { data, resp, error in
            guard let data = data else{
                let error = error ?? AMError.invalidData(data: data)
                self.queue.async { finish?(.failure(error)) }
                return
            }
            guard let image:UIImage = .data(data, scale: scale) else{
                let error = AMError.invalidData(data: data)
                self.queue.async { finish?(.failure(error)) }
                return
            }
            self.imageCache.setObject(image, forKey: key)
            self.queue.async { finish?(.success(image)) }
        }.resume()
    }
}
extension AMImageCache{
    private func image(with asset:PHAsset,size:CGSize) ->Result<UIImage,AMError>{
        let options = PHImageRequestOptions()
        options.isSynchronous = true;
        var image:UIImage?
        var userInfo:[AnyHashable:Any]?
        PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .default, options: options) { (img, info) in
            image = img
            userInfo = info
        }
        guard let img = image else {
            return .failure(AMError.imageAsset(info: userInfo))
        }
        return .success(img);
    }
    public func image(with asset:PHAsset) -> Result<UIImage,AMError>{
        let maxlen = max(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
        return self.image(with: asset, size: CGSize(width:maxlen,height:maxlen))
    }
    public func thumb(with asset:PHAsset,size:CGSize) -> Result<UIImage,AMError>{
        return self.image(with: asset, size: size)
    }
    private func data(with asset:PHAsset,finish:ONResult<Data>?){
        rootQueue.async {
            let options = PHImageRequestOptions()
            options.isSynchronous = true;
            var imageData:Data?
            var userInfo:[AnyHashable:Any]?
            PHImageManager.default().requestImageData(for: asset, options: options, resultHandler: { (data, dataUTI, imageOrientation, info) in
                imageData = data;
                userInfo = info
            })
            self.queue.async {
                guard let data = imageData else{
                    finish?(.failure(AMError.imageAsset(info: userInfo)))
                    return
                }
                finish?(.success(data))
            }
        }
    }
    public func image(with asset:PHAsset,finish: ONResult<UIImage>?){
        rootQueue.async {
            let key = asset.localIdentifier as NSString
            if let image = self.imageCache.object(forKey: key) {
                self.queue.async { finish?(.success(image)) }
            }
            let result = self.image(with: asset)
            self.queue.async {
                guard let image = result.value else{
                    finish?(.failure(result.error!))
                    return
                }
                self.imageCache.setObject(image, forKey: key)
                finish?(.success(image))
            }
        }
    }
    
    public func thumb(with asset:PHAsset,size:CGSize,finish: ONResult<UIImage>?){
        rootQueue.async {
            let key = (asset.localIdentifier+"_mini") as NSString
            if let image = self.thumbCache.object(forKey: key) {
                self.queue.async { finish?(.success(image)) }
                return;
            }
            let result = self.image(with: asset,size: size)
            self.queue.async {
                guard let image = result.value else{
                    finish?(.failure(result.error!))
                    return
                }
                self.thumbCache.setObject(image, forKey: key)
                finish?(.success(image))
            }
        }
    }
}
extension UIImageView{
    public func setImage(with url:String,scale:CGFloat = 3,placeholder:UIImage? = nil,finish:((UIImageView,Result<UIImage,Error>)->Void)? = nil)  {
        if let placeholder = placeholder,self.image == nil {
            self.image = placeholder;
        }
        AMImageCache.shared.image(with: url,scale:scale) { result in
            guard case .success(let image) = result else{
                finish?(self,result)
                return
            }
            UIView.transition(
                with: self,
                duration: 0.5,
                options: .transitionCrossDissolve,
                animations: { self.image = image }) { _ in
                finish?(self,result)
            }
        }
    }
    public func setImage(with asset:PHAsset,placeholder:UIImage? = nil,finish:((UIImageView,Result<UIImage,Error>)->Void)? = nil){
        if let placeholder = placeholder ,self.image == nil{
            self.image = placeholder;
        }
        AMImageCache.shared.image(with: asset) { result in
            guard case .success(let image) = result else{
                finish?(self,result)
                return
            }
            UIView.transition(
                with: self,
                duration: 0.5,
                options: .transitionCrossDissolve,
                animations: { self.image = image }) { _ in
                finish?(self,result)
            }
        }
    }
    public func setThumb(with asset:PHAsset,size:CGSize,placeholder:UIImage?  = nil,finish:((UIImageView,Result<UIImage,Error>)->Void)? = nil){
        if let placeholder = placeholder ,self.image == nil{
            self.image = placeholder;
        }
        AMImageCache.shared.thumb(with: asset,size:size) { result in
            guard case .success(let image) = result else{
                finish?(self,result)
                return
            }
            UIView.transition(
                with: self,
                duration: 0.5,
                options: .transitionCrossDissolve,
                animations: { self.image = image }) { _ in
                finish?(self,result)
            }
        }
    }
}
extension UIButton{
    public func setImage(with url:String,scale:CGFloat = 3,placeholder:UIImage? = nil,for state:UIControl.State = .normal,finish:((UIButton,Result<UIImage,Error>)->Void)? = nil)  {
        if let placeholder = placeholder,self.image(for: state) == nil {
            self.setImage(placeholder, for: state)
        }
        AMImageCache.shared.image(with: url,scale:scale) { result in
            guard case .success(let image) = result else{
                finish?(self,result)
                return
            }
            UIView.transition(
                with: self,
                duration: 0.5,
                options: .transitionCrossDissolve,
                animations: { self.setImage(image, for: .normal) }) { _ in
                finish?(self,result)
            }
        }
    }
}

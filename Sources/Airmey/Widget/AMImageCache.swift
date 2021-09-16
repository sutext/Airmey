//
//  AMImageCache.swift
//  Airmey
//
//  Created by supertext on 2020/9/7.
//  Copyright © 2020年 airmey. All rights reserved.
//

import UIKit
import Photos

/// image cache control
public class AMImageCache {
    public static let shared = AMImageCache()
    private let rootQueue = DispatchQueue(label: "com.airmey.imageQueue")
    private let imageCache = NSCache<NSString,UIImage>()//big image cache
    private let thumbCache = NSCache<NSString,UIImage>()//thumb image cache
    private let diskCache = URLCache(memoryCapacity: 80*1024*1024, diskCapacity: 500*1024*1024, diskPath: "com.airmey.imageCache")
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
    /// remove image for url
    public func remove(image url:String){
        if let u = URL(string: url){
            imageCache.removeObject(forKey: url as NSString)
            diskCache.removeCachedResponse(for: URLRequest(url: u))
        }
    }
    /// clear all memery and disk cahce
    public func clear(){
        self.diskCache.removeAllCachedResponses()
        self.imageCache.removeAllObjects()
        self.thumbCache.removeAllObjects()
    }
    /// total cached size of image cache
    public var diskUseage:Int{
        return self.diskCache.currentDiskUsage
    }
    /// remove all the disk image cache
    public func clearDisk(){
        self.diskCache.removeAllCachedResponses()
    }
    /// remove all the memery image cache
    public func clearMemery(){
        self.imageCache.removeAllObjects()
        self.thumbCache.removeAllObjects()
    }
    
    /// request a remote image sync
    public func image(with url:String,scale:CGFloat = 3,finish: ONResult<UIImage>?) {
        guard let requrl = URL(string: url) else {
            finish?(.failure(AMError.invalidURL(url: url)))
            return
        }
        var request = URLRequest(url: requrl)
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
            self.imageCache.setObject(image, forKey: url as NSString)
            self.queue.async { finish?(.success(image)) }
        }.resume()
    }
}
extension AMImageCache{
    /// get cached image if exsit
    public func image(for url:String)->UIImage?{
        if let image = self.imageCache.object(forKey: url as NSString) {
            return image
        }
        if let url = URL(string: url),
           let data = diskCache.cachedResponse(for: URLRequest(url: url))?.data {
            return .data(data)
        }
        return nil
    }
    /// get cached image from PHAsset if exsit
    public func image(for asset:PHAsset)->UIImage?{
        if let image = self.imageCache.object(forKey: asset.localIdentifier as NSString) {
            return image
        }
        return nil
    }
    /// get cached thumb image from PHAsset if exsit
    public func thumb(for asset:PHAsset,size:CGSize)->UIImage?{
        let key = "\(asset.localIdentifier)_w\(size.width)_h\(size.height)" as NSString
        if let image = self.thumbCache.object(forKey: key) {
            return image
        }
        return nil
    }
    
}
extension AMImageCache{
    /// get image form PHAsset sync
    public func image(with asset:PHAsset) -> Result<UIImage,AMError>{
        let maxlen = max(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
        return self.image(with: asset, size: CGSize(width:maxlen,height:maxlen))
    }
    /// get image form PHAsset sync
    public func image(with asset:PHAsset,size:CGSize) ->Result<UIImage,AMError>{
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
    /// get an image from PHAsset async
    public func image(with asset:PHAsset,finish: ONResult<UIImage>?){
        rootQueue.async {
            let result = self.image(with: asset)
            self.queue.async {
                guard let image = result.value else{
                    finish?(.failure(result.error!))
                    return
                }
                self.imageCache.setObject(image, forKey: asset.localIdentifier as NSString)
                finish?(.success(image))
            }
        }
    }
    /// get an thumb image from PHAsset async.
    public func thumb(with asset:PHAsset,size:CGSize,finish: ONResult<UIImage>?){
        let key = "\(asset.localIdentifier)_w\(size.width)_h\(size.height)" as NSString
        rootQueue.async {
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
    public func setImage(
        with url:String,
        scale:CGFloat = 3,
        placeholder:UIImage? = nil,
        finish:((UIImageView,Result<UIImage,Error>)->Void)? = nil)  {
        if let image = AMImageCache.shared.image(for: url) {
            self.image = image
            finish?(self,.success(image))
            return
        }
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
        if let image = AMImageCache.shared.image(for: asset) {
            self.image = image
            finish?(self,.success(image))
            return
        }
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
        if let image = AMImageCache.shared.thumb(for: asset,size: size) {
            self.image = image
            finish?(self,.success(image))
            return
        }
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
        if let image = AMImageCache.shared.image(for: url) {
            self.setImage(image, for: state)
            finish?(self,.success(image))
            return
        }
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

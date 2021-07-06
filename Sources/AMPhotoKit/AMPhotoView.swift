//
//  AMPhotoView.swift
//  Airmey
//
//  Created by supertext on 2020/6/24.
//  Copyright © 2020年 airmey. All rights reserved.
//

import UIKit
@objc public protocol AMPhotoViewDelegate:NSObjectProtocol {
    @objc optional func photoView(_ photoView:AMPhotoView,willAppear zoomView:UIImageView, isAnimator:Bool)
    @objc optional func photoView(_ photoView:AMPhotoView,didAppear zoomView:UIImageView, error:Error?,isAnimator:Bool)
    @objc optional func photoView(_ photoView:AMPhotoView,willDisappear zoomView:UIImageView)
    @objc optional func photoView(_ photoView:AMPhotoView,didDisappear zoomView:UIImageView)
    @objc optional func photoView(_ photoView:AMPhotoView,longPressedAt point:CGPoint)
    @objc optional func photoView(_ photoView:AMPhotoView,clickedAt point:CGPoint)
    @objc optional func photoView(_ photoView:AMPhotoView,scaleAcrossCritical increasing:Bool)
    @objc optional func photoView(_ photoView:AMPhotoView,zoomFinishedAt scale:CGFloat)
    @objc optional func photoView(_ photoView:AMPhotoView,zoomingAt scale:CGFloat,increasing:Bool)
    @objc optional func photoView(_ photoView:AMPhotoView,originRectFor model:AMPhoto)->CGRect
}
public class AMPhotoView: UIView {
    public let model:AMPhoto
    public let config:AMPhotoConfig
    public var autoShrink:Bool = true
    public internal(set) weak var delegate:AMPhotoViewDelegate?
    
    
    private let imageView:UIImageView = UIImageView()
    private let thumbView:UIImageView = UIImageView()
    private let scorllView:UIScrollView = UIScrollView()
    
    private var zoomEnable:Bool = true
    private var perfaceScale:CGFloat = 1
    private var lastScale:CGFloat = 1
    private var zoomScale:CGFloat = 1
    private var callThroughOnce:Bool = false
    private var isAnimator:Bool = false
    internal var animatingStatusChanged:((AMPhotoView,Bool)->Void)?
    
    private var animating:Bool = false{
        didSet{
            guard animating != oldValue else {
                return
            }
            self.isUserInteractionEnabled = !animating
            self.animatingStatusChanged?(self,animating)
        }
    }
    public var singleTapEnable:Bool = false {
        didSet{
            guard singleTapEnable != oldValue else {
                return
            }
            if singleTapEnable {
                self.addGestureRecognizer(self.singleTapGesture)
            }else{
                self.removeGestureRecognizer(self.singleTapGesture)
            }
        }
    }
    public var longPressEnable:Bool = false {
        didSet{
            guard longPressEnable != oldValue else {
                return
            }
            if longPressEnable {
                self.addGestureRecognizer(self.longPressGesture)
            }else{
                self.removeGestureRecognizer(self.longPressGesture)
            }
        }
    }
    public var isZooming:Bool {
        return self.scorllView.isZooming
    }
    public var image:UIImage?{
        return self.imageView.image
    }
    private lazy var longPressGesture:UILongPressGestureRecognizer = {
        return UILongPressGestureRecognizer(target: self, action: #selector(AMPhotoView.longPressAction(sender:)))
    }()
    private lazy var singleTapGesture:UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(AMPhotoView.singleTapAction(sender:)))
        gesture.numberOfTapsRequired = 1
        return gesture
    }()
    private lazy var doubleTapGesture:UITapGestureRecognizer = {
        let gestrue = UITapGestureRecognizer(target: self, action: #selector(AMPhotoView.doubleTapAction(sender:)))
        gestrue.numberOfTapsRequired = 2
        return gestrue
    }()
    private lazy var indicator:UIActivityIndicatorView = {
        let indic = UIActivityIndicatorView(style: .whiteLarge)
        self.blurView.addSubview(indic)
        return indic
    }()
    private lazy var blurView:UIView = {
        let blur = UIView(frame: .zero)
        blur.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        blur.backgroundColor = UIColor(white: 0, alpha: 0.3)
        return blur
    }()
    public init(model:AMPhoto,config:AMPhotoConfig = .default){
        self.model = model
        self.config = config
        super.init(frame: UIScreen.main.bounds)
        self.backgroundColor = .clear
        self.thumbView.contentMode = .scaleAspectFill
        self.thumbView.backgroundColor = .clear
        self.thumbView.clipsToBounds = true
        self.thumbView.frame = self.config.defaultThumbRect
        self.addSubview(self.thumbView)
        
        self.scorllView.delegate = self
        self.scorllView.minimumZoomScale = 0.5
        self.scorllView.maximumZoomScale = self.config.maximumZoomScale
        self.scorllView.showsVerticalScrollIndicator = false
        self.scorllView.showsHorizontalScrollIndicator = false
        self.scorllView.backgroundColor = .clear
        self.scorllView.frame = self.bounds
        if #available(iOS 11.0, *) {
            self.scorllView.contentInsetAdjustmentBehavior = .never
        }
        self.addSubview(self.scorllView)
        
        self.imageView.contentMode = .scaleAspectFill
        self.imageView.clipsToBounds = true
        self.imageView.backgroundColor = .clear
        self.scorllView.addSubview(self.imageView)
        
        self.addGestureRecognizer(self.doubleTapGesture)
        
        if case .local(let image,let thumb) = self.model.source {
            self.thumbView.image = thumb
            self.imageView.image = image
            self.resize(with: image)
            self.setImageView(hidden: false)
            self.thumbView.frame = self.imageView.frame
        }else{
            self.setImageView(hidden: true)
            self.thumbView.setThumb(with: self.model, size: self.thumbView.frame.size)
        }
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension AMPhotoView{
    public func preloadImage(){
        self.imageView.setImage(with: self.model) {[weak self] (view, result) in
            if let img = result.value{
                guard let wself = self else{
                    return
                }
                wself.resize(with: img)
                wself.setImageView(hidden: false)
                wself.thumbView.frame = wself.imageView.frame
            }
        }
    }
    public func restore(animated:Bool){
        self.scorllView.setZoomScale(1, animated: animated)
    }
    public func setZoom(enable:Bool,restore:Bool = false,animated:Bool = false){
        self.zoomEnable = enable
        if !enable && restore {
            self.restore(animated: animated)
        }
    }
    public func showZoomView(){
        guard !self.animating else {
            return
        }
        self.animating = true
        if self.image == nil{
            self.startAnimating()
            self.imageView.setImage(with: self.model, placeholder: nil) {[weak self] (view, result) in
                self?.stopAnimating()
                switch result{
                case .success(let image):
                    self?.resize(with: image)
                    self?.startZoomAnimating()
                case .failure(let err):
                    self?.zoomviewDidAppear(error: err)
                }
            }
        }else{
            if self.isAnimator{
                self.startZoomAnimating()
            }
            else{
                self.zoomviewDidAppear(error: nil)
            }
        }
    }
    public func hideZoomView(){
        guard !self.animating else {
            return
        }
        self.zoomViewWillDisappear()
        self.restore(animated: false)
        self.setImageView(hidden: true)
        let rect = self.photoOriginRect()
        UIView.animate(withDuration: self.config.animationDuration, animations: { 
            self.thumbView.frame = rect
        }) { (finished) in
            self.zoomViewDidDisappear()
        }
    }
}
extension AMPhotoView{
    internal func becomeAnimator(){
        self.isAnimator = true
        self.thumbView.frame = self.photoOriginRect()
        self.setImageView(hidden: true)
    }
}
extension AMPhotoView{
    private func startZoomAnimating(){
        self.zoomViewWillAppear()
        let rect = self.imageView.frame
        self.thumbView.frame = self.photoOriginRect()
        self.setImageView(hidden: true)
        UIView.animate(withDuration: self.config.animationDuration, animations: { 
            self.thumbView.frame = rect
        }) { (finished) in
            self.setImageView(hidden: false)
            self.zoomviewDidAppear(error: nil)
        }
    }
    private func startAnimating(){
        self.blurView.addSubview(self.indicator)
        self.thumbView.addSubview(self.blurView)
        self.blurView.frame = self.thumbView.bounds
        self.indicator.center = self.blurView.center
        self.indicator.startAnimating()
    }
    private func stopAnimating(){
        self.indicator.stopAnimating()
        self.blurView.removeFromSuperview()
    }
    private func resize(with image:UIImage) {
        let imageBounds = self.bounds.inset(by: self.config.imageInsets)
        let width = imageBounds.size.width
        let height = imageBounds.size.height
        let top = imageBounds.origin.y
        let left = imageBounds.origin.x
        let imageSize = image.size
        let imageWidth = imageSize.width
        let imageHeight = imageSize.height
        var rect:CGRect = .zero
        if imageHeight/imageWidth <= height/width{
            let newheight = imageHeight*width/imageWidth
            self.perfaceScale = height/newheight
            rect = CGRect(x: left, y: abs(height-newheight)/2+top, width: width, height: newheight)
        }else{
            let newWidth = imageWidth*height/imageHeight
            self.perfaceScale = width/newWidth
            rect = CGRect(x: abs(width-newWidth)/2+left, y: top, width: newWidth, height: height)
        }
        self.imageView.frame = rect
    }
    private func setImageView(hidden:Bool){
        self.imageView.isHidden = hidden
        self.thumbView.isHidden = !hidden
    }
    private func photoOriginRect()->CGRect
    {
        if let rect = self.delegate?.photoView?(self, originRectFor: self.model){
            return rect
        }
        return self.config.defaultThumbRect
    }
}
extension AMPhotoView{
    private func zoomViewWillAppear(){
        self.animating = true
        self.delegate?.photoView?(self, willAppear: self.imageView, isAnimator: self.isAnimator)
    }
    private func zoomviewDidAppear(error:Error?){
        self.delegate?.photoView?(self, didAppear: self.imageView, error: error, isAnimator: self.isAnimator)
        self.isAnimator = false
        self.animating = false
    }
    private func zoomViewWillDisappear(){
        self.animating = true
        self.delegate?.photoView?(self, willDisappear: self.imageView)
    }
    private func zoomViewDidDisappear(){
        self.delegate?.photoView?(self, didDisappear: self.imageView)
        self.animating = false
    }
}
extension AMPhotoView{
    @objc private func singleTapAction(sender:UITapGestureRecognizer){
        guard let delegate = self.delegate else {
            return
        }
        guard  delegate.responds(to: #selector(AMPhotoViewDelegate.photoView(_:clickedAt:))) else {
            return
        }
        self.perform(#selector(AMPhotoView.handleSingleTap(sender:)), with: sender, afterDelay: 0.2)
    }
    @objc private func doubleTapAction(sender:UITapGestureRecognizer){
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        let point = sender.location(in: self)
        if self.scorllView.zoomScale == self.scorllView.maximumZoomScale{
            self.scorllView.setZoomScale(1, animated: true)
        }else{
            self.scorllView.zoom(to: CGRect(x:point.x,y:point.y,width:1,height:1), animated: true)
        }
    }
    @objc private func longPressAction(sender:UILongPressGestureRecognizer){
        if case .began = sender.state {
            self.delegate?.photoView?(self, longPressedAt: sender.location(in: self))
        }
    }
    @objc private func handleSingleTap(sender:UITapGestureRecognizer){
        self.delegate?.photoView?(self, clickedAt: sender.location(in: self))
    }
}
extension AMPhotoView:UIScrollViewDelegate
{
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        if self.zoomEnable{
            return self.imageView
        }
        return nil
    }
    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        self.callThroughOnce = true
    }
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        guard scale < 1 else {
            self.delegate?.photoView?(self, zoomFinishedAt: scale)
            return
        }
        guard self.autoShrink && self.zoomScale < self.lastScale else{
            self.restore(animated: true)
            return
        }
        guard !self.animating else {
            return
        }
        self.zoomViewWillDisappear()
        let rect = self.photoOriginRect()
        UIView.animate(withDuration: self.config.animationDuration, animations: {
            self.imageView.frame = rect
        }, completion: { (finish) in
            self.zoomViewDidDisappear()
        })
    }
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        var xcenter = self.scorllView.center.x
        var ycenter = self.scorllView.center.y
        let contentWidth = self.scorllView.contentSize.width
        let contentHeight = self.scorllView.contentSize.height
        if contentWidth > self.scorllView.frame.size.width{
            xcenter = contentWidth/2
        }
        if contentHeight > self.scorllView.frame.size.height{
            ycenter = contentHeight/2
        }
        self.imageView.center = CGPoint(x: xcenter, y: ycenter)
        let newscale = self.scorllView.zoomScale
        let increasing = self.zoomScale < newscale
        self.lastScale = self.zoomScale
        self.zoomScale = newscale
        self.delegate?.photoView?(self, zoomingAt: newscale, increasing: increasing)
        if self.zoomScale<1 && self.callThroughOnce{
            self.callThroughOnce = false
            self.delegate?.photoView?(self, scaleAcrossCritical: false)
        }else if self.zoomScale>1 && !self.callThroughOnce{
            self.callThroughOnce = true
            self.delegate?.photoView?(self, scaleAcrossCritical: true)
        }
    }
}

//
//  AMPhotoBrowserController.swift
//  Airmey
//
//  Created by supertext on 2020/9/8.
//  Copyright © 2020年 airmey. All rights reserved.
//

import UIKit

open class AMPhotoBrowserController: AMPhotoListController {
    public var dismissBlock:(()->Void)?
    public var modelOrginRect:((AMPhoto)->CGRect)?
    public override init(models: [AMPhoto], startIndex: Int) throws {
        try super.init(models: models, startIndex: startIndex)
        self.transitioningDelegate = self
        self.modalPresentationStyle = .custom
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.backgroundColor = .black
        self.currentChild.photoView.becomeAnimator()
        self.backgroundView.alpha = 0
    }
    
}
extension AMPhotoBrowserController{
    open override func prepare(for child: AMPhotoViewController) {
        child.photoView.autoShrink = true
        child.photoView.singleTapEnable = true
    }
}
//MARK:AMPhotoViewDelegate impls 
/*
 * if subclass overwrite these methods must call super
 */
extension AMPhotoBrowserController{
    open func photoView(_ photoView: AMPhotoView, willAppear zoomView: UIImageView, isAnimator: Bool) {
        if isAnimator {
            UIView.animate(withDuration: 0.35){
                self.navigationController?.navigationBar.alpha = 1
                self.backgroundView.alpha = 1
            }
        }
    }
    public func photoView(_ photoView: AMPhotoView, didAppear zoomView: UIImageView, error: Error?, isAnimator: Bool) {
        if error != nil ,isAnimator{
            self.currentChild.photoView.hideZoomView()
        }
    }
    open func photoView(_ photoView: AMPhotoView, willDisappear zoomView: UIImageView) {
        UIView.animate(withDuration: photoView.config.animationDuration) { 
            self.navigationController?.navigationBar.alpha = 0
            self.backgroundView.alpha = 0
        }
    }
    open func photoView(_ photoView: AMPhotoView, didDisappear zoomView: UIImageView) {
        self.dismiss(animated: false, completion: nil)
        self.dismissBlock?()
    }
    open func photoView(_ photoView: AMPhotoView, zoomingAt scale: CGFloat, increasing: Bool) {
        if scale <= 1{
            if !self.isFullscreen{
                self.navigationController?.navigationBar.alpha = scale
            }
            self.backgroundView.alpha = scale
        }
    }
    open func photoView(_ photoView: AMPhotoView, clickedAt point: CGPoint) {
        self.isFullscreen = !self.isFullscreen
    }
    open func photoView(_ photoView: AMPhotoView, originRectFor model: AMPhoto) -> CGRect {
        if let rect = self.modelOrginRect?(model){
            return rect
        }
        return photoView.config.defaultThumbRect
    }
}
extension AMPhotoBrowserController:UIViewControllerTransitioningDelegate{
    private class PresentationController:UIPresentationController{
        override func presentationTransitionWillBegin() {
            self.containerView?.addSubview(self.presentedView!)
        }
    }
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return PresentationController(presentedViewController: presented, presenting: presenting)
    }
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
}
extension AMPhotoBrowserController:UIViewControllerAnimatedTransitioning{
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.0
    }
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        transitionContext.completeTransition(true)
    }
}

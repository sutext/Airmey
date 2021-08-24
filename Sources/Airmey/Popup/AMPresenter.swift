//
//  AMPresenter.swift
//  Airmey
//
//  Created by supertext on 2020/11/8.
//  Copyright © 2020年 airmey. All rights reserved.
//

import UIKit

/// The base class  for all presenter
/// This is an abstract class
/// You must override the hock method to provide your implmention
open class AMPresenter: NSObject {
    /// config presented block
    public var onshow:AMBlock?
    /// config dismiss call back
    public var onhide:AMBlock?
    /// config mask click action
    public var onMaskClick:AMBlock?
    /// config transition duration
    public var transitionDuration:TimeInterval = 0.25
    /// The dimming rate of black background view by default `0.4`
    ///- Note: You must set this value before present. Otherwise it doesn't work
    public var dimming:CGFloat = 0.4
    ///override method
    ///empty implemention by default
    open func presentWillBegin(in pc:UIPresentationController){
        
    }
    ///override method
    ///call self.onshow?() by defualt
    open func presentDidEnd(in pc:UIPresentationController,completed: Bool){
        self.onshow?()
    }
    ///override method
    ///empty implemention by default
    open func dismissWillBegin(in pc:UIPresentationController){
        
    }
    ///override method
    ///call self.onhide?() by defualt
    open func dismissDidEnd(in pc:UIPresentationController,completed: Bool){
        self.onhide?()
    }
    class PresentationController:UIPresentationController{
        weak var presenter:AMPresenter?
        override func presentationTransitionWillBegin() {
            self.presenter?.presentWillBegin(in: self)
        }
        override func presentationTransitionDidEnd(_ completed: Bool) {
            self.presenter?.presentDidEnd(in: self,completed: completed)
        }
        override func dismissalTransitionWillBegin() {
            self.presenter?.dismissWillBegin(in: self)
        }
        override func dismissalTransitionDidEnd(_ completed: Bool) {
            self.presenter?.dismissDidEnd(in: self,completed: completed)
        }
    }
}
extension AMPresenter:UIViewControllerTransitioningDelegate{
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let present =  PresentationController(presentedViewController: presented, presenting: presenting)
        present.presenter = self
        return present
    }
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self
    }
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self
    }
    
}
extension AMPresenter:UIViewControllerAnimatedTransitioning{
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        self.transitionDuration
    }
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        UIView.animate(withDuration: self.transitionDuration, animations: {
        }) { (finished) in
            transitionContext.completeTransition(finished)
        }
    }
}
///
/// Rect animation presenter
///
public class AMFramePresenter: AMPresenter {
    private let initialFrame:CGRect
    private let finalFrame:CGRect
    private lazy var dimmingView:AMView = {
        let view = AMView()
        view.onclick = {[weak self] _ in
            self?.onMaskClick?()
        }
        view.backgroundColor = UIColor(white: 0, alpha: dimming)
        view.alpha = 0
        return view;
    }()
    public init(initial:CGRect,final:CGRect) {
        self.initialFrame = initial
        self.finalFrame = final
    }
    /// present from bottom
    public convenience init(bottom height:CGFloat){
        let initial = CGRect(x: 0, y: .screenHeight, width: .screenWidth, height: height)
        let final = CGRect(x: 0, y: .screenHeight - height, width: .screenWidth, height: height)
        self.init(initial:initial,final:final)
    }
    /// present from top
    public convenience init(top height:CGFloat){
        let initial = CGRect(x: 0, y: -height, width: .screenWidth, height: height)
        let final = CGRect(x: 0, y: 0 , width: .screenWidth, height: height)
        self.init(initial:initial,final:final)
    }
    /// present from left
    public convenience init(left width:CGFloat){
        let initial = CGRect(x: -width, y: 0, width: width, height: .screenHeight)
        let final = CGRect(x: 0, y: 0 , width: width, height: .screenHeight)
        self.init(initial:initial,final:final)
    }
    /// present from right
    public convenience init(right width:CGFloat){
        let initial = CGRect(x: .screenWidth, y: 0, width: width, height: .screenHeight)
        let final = CGRect(x: .screenWidth - width, y: 0 , width: width, height: .screenHeight)
        self.init(initial:initial,final:final)
    }
    public override func presentWillBegin(in pc:UIPresentationController) {
        guard let container = pc.containerView else {
            return
        }
        guard let coordinator = pc.presentedViewController.transitionCoordinator else {
            return
        }
        container.addSubview(pc.presentedView!)
        pc.presentedViewController.view.frame = self.initialFrame
        container.insertSubview(self.dimmingView, at: 0)
        self.dimmingView.frame = .screen
        coordinator.animate{_ in
            self.dimmingView.alpha = 1
            pc.presentedViewController.view.frame = self.finalFrame
        }
    }
    public override func dismissWillBegin(in pc: UIPresentationController) {
        guard let coordinator = pc.presentedViewController.transitionCoordinator else {
            return
        }
        pc.presentedViewController.view.frame = self.finalFrame
        coordinator.animate{ _ in
            self.dimmingView.alpha = 0
            self.dimmingView.frame = .screen
            pc.presentedViewController.view.frame = self.initialFrame
        }
    }
}


/// Add auto dimming background view to the target view controller
public class AMDimmingPresenter: AMPresenter {
    private lazy var dimmingView:AMView = {
        let view = AMView()
        view.onclick = {[weak self] _ in
            self?.onMaskClick?()
        }
        view.backgroundColor = UIColor(white: 0, alpha: dimming)
        view.alpha = 0
        return view;
    }()
    public override func presentWillBegin(in pc: UIPresentationController) {
        guard let container = pc.containerView else {
            return
        }
        guard let presentView = pc.presentedView else {
            return
        }
        guard let coordinator = pc.presentedViewController.transitionCoordinator else {
            return
        }
        self.dimmingView.frame = presentView.bounds
        presentView.insertSubview(self.dimmingView, at: 0)
        container.addSubview(presentView)
        presentView.alpha = 0
        coordinator.animate{ _ in
            self.dimmingView.alpha = 1
            presentView.alpha = 1
        }
    }
    public override func dismissWillBegin(in pc: UIPresentationController) {
        guard let coordinator = pc.presentedViewController.transitionCoordinator else {
            return
        }
        coordinator.animate{ _ in
            self.dimmingView.alpha = 0
            pc.presentedView?.alpha = 0
        }
    }
}

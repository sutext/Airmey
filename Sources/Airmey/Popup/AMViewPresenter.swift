//
//  AMViewPresenter.swift
//  Airmey
//
//  Created by supertext on 2020/11/8.
//  Copyright © 2020年 airmey. All rights reserved.
//

import UIKit

public class AMFramePresenter: NSObject {
    public var initialFrame:CGRect = .zero
    public var finalFrame:CGRect = .zero
    public var dimmingFrame:CGRect = .zero
    public convenience init(_ sheetHeight:CGFloat){
        self.init()
        self.setup(with: sheetHeight)
    }
    func setup(with sheetHeight:CGFloat){
        self.initialFrame = CGRect(x: 0, y: .screenHeight, width: .screenWidth, height: sheetHeight)
        self.finalFrame = CGRect(x: 0, y: .screenHeight - sheetHeight, width: .screenWidth, height: sheetHeight)
        self.dimmingFrame = CGRect(x: 0, y:0, width: .screenWidth, height: .screenHeight - sheetHeight)
    }
    class PresentationController:UIPresentationController{
        weak var presenter:AMFramePresenter?
        private lazy var dimmingView:AMView = {
            let view = AMView()
            view.onclick = {[weak self] sender in
                self?.presentingViewController.dismiss(animated: true)
            }
            view.backgroundColor = UIColor(white: 0, alpha: 0.4)
            view.alpha = 0
            return view;
        }()
        override func presentationTransitionWillBegin() {
            guard let container = self.containerView else {
                return
            }
            guard let coordinator = self.presentedViewController.transitionCoordinator else {
                return
            }
            guard let adapter = self.presenter else {
                return
            }
            container.addSubview(self.dimmingView)
            container.addSubview(self.presentedView!)
            self.dimmingView.frame = .screen
            self.presentedViewController.view.frame = adapter.initialFrame
            coordinator.animate(alongsideTransition: { (ctx) in
                self.dimmingView.alpha = 1
                self.presentedViewController.view.frame = adapter.finalFrame
                self.dimmingView.frame = adapter.dimmingFrame
            })
        }
        override func dismissalTransitionWillBegin() {
            guard let coordinator = self.presentedViewController.transitionCoordinator else {
                return
            }
            guard let adapter = self.presenter else {
                return
            }
            self.presentedViewController.view.frame = adapter.finalFrame
            coordinator.animate(alongsideTransition: { (ctx) in
                self.dimmingView.alpha = 0
                self.dimmingView.frame = .screen
                self.presentedViewController.view.frame = adapter.initialFrame
            })
        }
    }
}
extension AMFramePresenter:UIViewControllerTransitioningDelegate{
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let present =  PresentationController(presentedViewController: presented, presenting: presenting)
        present.presenter = self
        return present
    }
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
}
extension AMFramePresenter:UIViewControllerAnimatedTransitioning{
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        UIView.animate(withDuration: 0.25, animations: {
            
        }) { (finished) in
            transitionContext.completeTransition(finished)
        }
    }
}
public class AMDimmingPresenter: NSObject {
    public var appearedBlock:(()->Void)?
    public var dismissBlock:(()->Void)?
    public var isDimmingClickable:Bool = false
    class PresentationController:UIPresentationController{
        weak var presenter:AMDimmingPresenter?
        private lazy var dimmingView:AMView = {
            let view = AMView()
            if let enable = self.presenter?.isDimmingClickable,enable{
                view.onclick = {[weak self] sender in
                    self?.presentingViewController.dismiss(animated: true)
                }
            }
            view.backgroundColor = UIColor(white: 0, alpha: 0.4)
            view.alpha = 0
            return view;
        }()
        override func presentationTransitionWillBegin() {
            guard let container = self.containerView else {
                return
            }
            guard let presentView = self.presentedView else {
                return
            }
            guard let coordinator = self.presentedViewController.transitionCoordinator else {
                return
            }
            self.dimmingView.frame = presentView.bounds
            presentView.insertSubview(self.dimmingView, at: 0)
            container.addSubview(presentView)
            presentView.alpha = 0
            coordinator.animate(alongsideTransition: { (ctx) in
                self.dimmingView.alpha = 1
                presentView.alpha = 1
            })
        }
        override func presentationTransitionDidEnd(_ completed: Bool) {
            self.presenter?.appearedBlock?()
        }
        override func dismissalTransitionWillBegin() {
            guard let coordinator = self.presentedViewController.transitionCoordinator else {
                return
            }
            coordinator.animate(alongsideTransition: { (ctx) in
                self.dimmingView.alpha = 0
                self.presentedView?.alpha = 0
            })
        }
        override func dismissalTransitionDidEnd(_ completed: Bool) {
            self.presenter?.dismissBlock?()
        }
    }
}
extension AMDimmingPresenter:UIViewControllerTransitioningDelegate{
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let present =  PresentationController(presentedViewController: presented, presenting: presenting)
        present.presenter = self
        return present
    }
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
}
extension AMDimmingPresenter:UIViewControllerAnimatedTransitioning{
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        UIView.animate(withDuration: 0.25, animations: {
            
        }) { (finished) in
            transitionContext.completeTransition(finished)
        }
    }
}

public class AMFadeinPresenter: NSObject {
    public var dismissBlock:(()->Void)?
    public var duration:CGFloat = 0.5
    class PresentationController: UIPresentationController {
        weak var presenter:AMFadeinPresenter?
        override func presentationTransitionWillBegin() {
            guard let container = self.containerView else {
                return
            }
            container.addSubview(self.presentedView!)
            guard let coordinator = self.presentedViewController.transitionCoordinator else {
                return
            }
            self.presentedView?.alpha = 0
            coordinator.animate(alongsideTransition: { (ctx) in
                self.presentedView?.alpha = 1
            })
        }
        override func dismissalTransitionWillBegin() {
            guard let coordinator = self.presentedViewController.transitionCoordinator else {
                return
            }
            coordinator.animate(alongsideTransition: { (ctx) in
                self.presentedView?.alpha = 0
            })
        }
        override func presentationTransitionDidEnd(_ completed: Bool) {
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                self.presentedViewController.dismiss(animated: true, completion: nil)
            }
        }
        override func dismissalTransitionDidEnd(_ completed: Bool) {
            self.presenter?.dismissBlock?()
        }
    }
}
extension AMFadeinPresenter:UIViewControllerTransitioningDelegate{
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let present =  PresentationController(presentedViewController: presented, presenting: presenting)
        present.presenter = self
        return present
    }
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
}
extension AMFadeinPresenter:UIViewControllerAnimatedTransitioning{
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        UIView.animate(withDuration: 0.25, animations: {
            
        }) { (finished) in
            transitionContext.completeTransition(finished)
        }
    }
}


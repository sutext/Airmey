//
//  AMSwiper.swift
//  Airmey
//
//  Created by supertext on 2020/10/18.
//  Copyright © 2020年 airmey. All rights reserved.
//

import UIKit
public protocol AMSwiperChild:UIViewController,Comparable{
    
}
/// user must provide the dataSource impl for the swiper
/// the data structure of swiper is double side linked list
public protocol AMSwiperDataSource:AnyObject {
    ///the head node
    func headNode(for swiper:AMSwiper)->UIViewController?
    ///the next node for current
    func swiper(_ swiper:AMSwiper,nodeAfter node:UIViewController)->UIViewController?
    ///the prev node for current
    func swiper(_ swiper:AMSwiper,nodeBefore node:UIViewController)->UIViewController?
}
///the swiper view's notify
@objc public protocol AMSwiperDelegate:AnyObject {
    @objc optional func swiper(_ swiper:AMSwiper ,indexOf node:UIViewController)->Int
    /// called when a new swiper node did show
    @objc optional func swiper(_ swiper:AMSwiper ,didDisplay node:UIViewController)
    /// called when a swiper node did disappear
    @objc optional func swiper(_ swiper:AMSwiper ,didDismiss node:UIViewController)
}
///define an horizontal scorll view
///
///implement pageable cacheable in controller level
///so you may use auto layout when using this widget
public class AMSwiper: UIView {
    private let pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    private var isDraging = false //the draging state of the swiper
    private var currNode:UIViewController?// the current swiper
    private var nextNode:UIViewController?// the next swiper if exsit
    private var prevNode:UIViewController?// the prev swiper if exsit
    public weak var dataSource:AMSwiperDataSource?
    public weak var delegate:AMSwiperDelegate?
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.pageController.delegate = self
        self.pageController.dataSource = self
        self.addSubview(self.pageController.view)
        self.pageController.view.am.edge.equal(to: 0)
        self.setDelayTouches(false)
    }
    ///
    ///jump to the dataSource head directly
    public func reload() {
        self.jump(to: self.dataSource?.headNode(for: self),animated: false)
    }
    /// default is true. if false, we immediately call -touchesShouldBegin:withEvent:inContentView:. this has no effect on presses
    public var delaysContentTouches:Bool = false{
        didSet{
            guard delaysContentTouches != oldValue else {
                return
            }
            self.setDelayTouches(delaysContentTouches)
        }
    }
    private func setDelayTouches(_ delay:Bool){
        for subview in self.pageController.view.subviews{
            if let scview = subview as? UIScrollView{
                scview.delaysContentTouches = delay
            }
        }
    }
    required public init?(coder aDecoder: NSCoder) {
        return nil
    }
}
///the swiper implement by UIPageViewController
extension AMSwiper:UIPageViewControllerDelegate,UIPageViewControllerDataSource{
    /// jump to any node directly
    ///
    /// - return action successful or not
    @discardableResult
    public func jump(to controller:UIViewController?,animated:Bool = true) ->Bool{
        guard let controller = controller else {
            return false
        }
        guard self.isDraging == false else {
            return false
        }
        var direction:UIPageViewController.NavigationDirection? = nil
        if animated,let current = self.currNode,
           let from = self.delegate?.swiper?(self, indexOf: current),
           let to = self.delegate?.swiper?(self, indexOf: controller){
            if to > from {
                direction = .forward
            }else if to < from {
                direction = .reverse
            }
        }
        self.isDraging = true
        self.pageController.setViewControllers([controller], direction: direction ?? .forward, animated: direction != nil) { _ in
            self.isDraging = false
        };
        self.rebuild(with: controller)
        return true
    }
    /// show next node if possible
    ///
    /// - return action successful or not
    @discardableResult
    public func goNext() ->Bool {
        guard self.isDraging == false else {
            return false
        }
        guard let nextone = self.nextNode else {
            return false
        }
        self.isDraging = true
        self.pageController.setViewControllers([nextone], direction: .forward, animated: true) { _ in
            self.isDraging = false
        };
        self.rebuild(with: nextone)
        return true
    }
    /// show prev node if possible
    ///
    /// - return action successful or not
    @discardableResult
    public func goPrev()  ->Bool{
        guard self.isDraging == false else {
            return false
        }
        guard let prevone = self.prevNode else {
            return false
        }
        self.isDraging = true
        self.pageController.setViewControllers([prevone], direction: .reverse, animated: true) { _ in
            self.isDraging = false
        };
        self.rebuild(with: prevone)
        return true
    }
    
    private func rebuild(with newNode:UIViewController)  {
        if newNode === self.nextNode {
            self.prevNode = self.currNode
            self.nextNode = self.dataSource?.swiper(self, nodeAfter: newNode)
        } else if newNode === self.prevNode{
            self.nextNode = self.currNode
            self.prevNode = self.dataSource?.swiper(self, nodeBefore: newNode)
        } else{
            self.nextNode = self.dataSource?.swiper(self, nodeAfter: newNode)
            self.prevNode = self.dataSource?.swiper(self, nodeBefore: newNode)
        }
        if let oldone = self.currNode {
            self.delegate?.swiper?(self, didDismiss: oldone)
        }
        self.currNode = newNode;
        self.delegate?.swiper?(self, didDisplay: newNode)
    }
    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        self.isDraging = true;
    }
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return self.nextNode
    }
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return self.prevNode
    }
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard finished else {
            return
        }
        if completed, let newcard = pageViewController.viewControllers?.first{
            self.rebuild(with: newcard);
        }
        self.isDraging = false
    }
}

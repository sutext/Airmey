//
//  AMSwiper.swift
//  Airmey
//
//  Created by supertext on 2020/10/18.
//  Copyright © 2020年 airmey. All rights reserved.
//

import UIKit
/// user must provide the dataSource impl for the swiper
/// the data structure of swiper is double side linked list
public protocol AMSwiperDataSource:AnyObject {
    ///the head node
    func head()->UIViewController?
    ///the next node for current
    func next(for current:UIViewController)->UIViewController?
    ///the prev node for current
    func prev(for current:UIViewController)->UIViewController?
}
///the swiper view's notify
@objc public protocol AMSwiperDelegate:AnyObject {
    /// called when a new swiper card did show
    @objc optional func swiper(_ swiper:AMSwiper ,didDisplay controller:UIViewController)
    /// called when a swiper card did disappear
    @objc optional func swiper(_ swiper:AMSwiper ,didDismiss controller:UIViewController)
}
///define an horizontal scorll view
///
///implement pageable cacheable in controller level
///so you may use auto layout when using this widget
public class AMSwiper: UIView {
    public let pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    public private(set) var isDraging = false //the draging state of the swiper
    public private(set) var currCard:UIViewController?// the current swiper
    public private(set) var nextCard:UIViewController?// the next swiper if exsit
    public private(set) var prevCard:UIViewController?// the prev swiper if exsit
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
        self.jump(to: self.dataSource?.head())
    }
    /// default is YES. if NO, we immediately call -touchesShouldBegin:withEvent:inContentView:. this has no effect on presses
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
    public func jump(to controller:UIViewController?) ->Bool{
        guard let current = controller else {
            return false
        }
        guard self.isDraging == false else {
            return false
        }
        self.pageController.setViewControllers([current], direction: .forward, animated: false, completion: nil);
        self.rebuild(with: current)
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
        guard let nextone = self.nextCard else {
            return false
        }
        self.pageController.setViewControllers([nextone], direction: .forward, animated: true, completion: nil);
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
        guard let prevone = self.prevCard else {
            return false
        }
        self.pageController.setViewControllers([prevone], direction: .reverse, animated: true, completion: nil);
        self.rebuild(with: prevone)
        return true
    }
    private func rebuild(with newCard:UIViewController)  {
        if newCard === self.nextCard {
            self.prevCard = self.currCard
            self.nextCard = self.dataSource?.next(for: newCard)
        } else if newCard === self.prevCard{
            self.nextCard = self.currCard
            self.prevCard = self.dataSource?.prev(for: newCard)
        } else{
            self.nextCard = self.dataSource?.next(for: newCard)
            self.prevCard = self.dataSource?.prev(for: newCard)
        }
        if let oldone = self.currCard {
            self.delegate?.swiper?(self, didDismiss: oldone)
        }
        self.currCard = newCard;
        self.delegate?.swiper?(self, didDisplay: newCard)
    }
    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        self.isDraging = true;
    }
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return self.nextCard
    }
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return self.prevCard
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

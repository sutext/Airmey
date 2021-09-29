//
//  AMSwiper.swift
//  Airmey
//
//  Created by supertext on 2020/10/18.
//  Copyright © 2020年 airmey. All rights reserved.
//

import UIKit

/// swiper indicator eg: UIPageControl UISegmentedControl ...
@objc public protocol AMSwiperIndicator where Self:UIView{
    /// set swiper handler if need
    @objc optional func setup(swiper:AMSwiper)
    /// Callback when scroll to special index
    /// Update appearance if need
    @objc optional func scrollIndex(_ index:Int, swiper:AMSwiper)
    /// Callback when dragging
    /// Update appearance if need
    /// - Parameters:
    ///     - percent: The percent offset value [-1,itemCount]
    @objc optional func scrollOffset(_ percent:CGFloat, swiper:AMSwiper)
}
extension UIPageControl:AMSwiperIndicator{
    public func scrollIndex(_ index: Int, swiper: AMSwiper) {
        currentPage = index
    }
}
/// user must provide the require data for the swiper
/// the data structure of swiper is double side linked list
@objc public protocol AMSwiperDelegate:NSObjectProtocol {
    ///the head node
    func headNode(for swiper:AMSwiper)->UIViewController?
    ///the next node for current
    func swiper(_ swiper:AMSwiper,nodeAfter node:UIViewController)->UIViewController?
    ///the prev node for current
    func swiper(_ swiper:AMSwiper,nodeBefore node:UIViewController)->UIViewController?
    /// provide a node at special index
    @objc optional func swiper(_ swiper:AMSwiper ,nodeAtIndex index:Int)->UIViewController
    /// provide index map of node
    @objc optional func swiper(_ swiper:AMSwiper ,indexOfNode node:UIViewController)->Int
    /// called when a swiper node did display
    @objc optional func swiper(_ swiper:AMSwiper ,didDisplayNode node:UIViewController)
    /// called when a swiper node did dismiss
    @objc optional func swiper(_ swiper:AMSwiper ,didDismissNode node:UIViewController)
}
///define an horizontal scorll view
///
///implement pageable cacheable in controller level
///so you may use auto layout when using this widget
public class AMSwiper: UIView {
    private let pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    private var isTransfering = false
    private var observe:NSKeyValueObservation?
    /// the current node index
    /// - Note: AMSwiperDelegate.swiper(_:nodeAtIndex:)) must be provide!
    public private(set) var currentIndex:Int?
    /// the current node
    public private(set) var currNode:UIViewController?
    /// the next node if exsit
    public private(set) var nextNode:UIViewController?
    /// the prev node if exsit
    public private(set) var prevNode:UIViewController?
    /// The swiper delegate and datasource
    public weak var delegate:AMSwiperDelegate?
    /// The swiper indicator eg: UIPageControl
    public weak var indicator:AMSwiperIndicator?{
        didSet{
            self.observe?.invalidate()
            guard let indicator = indicator else {
                return
            }
            indicator.setup?(swiper: self)
            self.observe = self.scrollView?.observe(\.contentOffset,options: [.new], changeHandler: { scview, changed in
                let width = self.bounds.width
                guard scview.isDragging||scview.isDecelerating,
                      width>0, let offset = changed.newValue?.x else{
                    return
                }
                guard let idx = self.currentIndex else{
                    print("⚠️ AMSwiperDelegate.swiper(_:indexOfNode:)) must be implement when indicator mode")
                    return
                }
                let percent = (offset-width)/width + CGFloat(idx)
                indicator.scrollOffset?(percent, swiper: self)
            })
        }
    }
    private lazy var scrollView:UIScrollView? = {
       let scview =  self.pageController.view.subviews.first{$0.isKind(of: UIScrollView.self)}
        return scview as? UIScrollView
    }()
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.pageController.delegate = self
        self.pageController.dataSource = self
        self.addSubview(self.pageController.view)
        self.pageController.view.am.edge.equal(to: 0)
        self.scrollView?.delaysContentTouches = false
    }
    ///
    ///jump to the dataSource head directly
    public func reload() {
        self.jump(to: self.delegate?.headNode(for: self),animated: false)
    }
    /// default is true. if false, we immediately call -touchesShouldBegin:withEvent:inContentView:. this has no effect on presses
    public var delaysContentTouches:Bool = false{
        didSet{
            guard delaysContentTouches != oldValue else {
                return
            }
            self.scrollView?.delaysContentTouches = delaysContentTouches
        }
    }
    required public init?(coder aDecoder: NSCoder) {
        return nil
    }
}
///the swiper implement by UIPageViewController
extension AMSwiper:UIPageViewControllerDelegate,UIPageViewControllerDataSource{
    /// jump to any index
    ///
    /// - Parameters:
    ///     - index: traget index to be jump
    ///     - animated: use animation or not
    /// - Note: AMSwiperDelegate.swiper(_:nodeAtIndex:)) must be provide!
    /// - Returns action successful or not
    @discardableResult
    public func jump(to index:Int, animated:Bool = true)->Bool{
        if let node = self.delegate?.swiper?(self, nodeAtIndex: index){
            return self.jump(to: node,animated: animated)
        }
        return false
    }
    /// jump to any node directly
    ///
    /// - Parameters:
    ///     - controller: traget node to be jump
    ///     - animated: use animation or not
    /// - Returns action successful or not
    @discardableResult
    public func jump(to controller:UIViewController?,animated:Bool = true) ->Bool{
        guard let controller = controller else {
            return false
        }
        guard self.isTransfering == false else {
            return false
        }
        var direction:UIPageViewController.NavigationDirection? = nil
        if animated,let current = self.currNode,
           let from = self.delegate?.swiper?(self, indexOfNode: current),
           let to = self.delegate?.swiper?(self, indexOfNode: controller){
            if to > from {
                direction = .forward
            }else if to < from {
                direction = .reverse
            }
        }
        self.isTransfering = true
        self.pageController.setViewControllers([controller], direction: direction ?? .forward, animated: direction != nil) { _ in
            self.rebuild(with: controller)
            self.isTransfering = false
        };
        return true
    }
    /// show next node if possible
    ///
    /// - return action successful or not
    @discardableResult
    public func goNext() ->Bool {
        guard self.isTransfering == false else {
            return false
        }
        guard let nextone = self.nextNode else {
            return false
        }
        self.isTransfering = true
        self.pageController.setViewControllers([nextone], direction: .forward, animated: true) { _ in
            self.rebuild(with: nextone)
            self.isTransfering = false
        };
        return true
    }
    /// show prev node if possible
    ///
    /// - return action successful or not
    @discardableResult
    public func goPrev()  ->Bool{
        guard self.isTransfering == false else {
            return false
        }
        guard let prevone = self.prevNode else {
            return false
        }
        self.isTransfering = true
        self.pageController.setViewControllers([prevone], direction: .reverse, animated: true) { _ in
            self.rebuild(with: prevone)
            self.isTransfering = false
        };
        return true
    }
    
    private func rebuild(with newNode:UIViewController)  {
        if newNode === self.nextNode {
            self.prevNode = self.currNode
            self.nextNode = self.delegate?.swiper(self, nodeAfter: newNode)
        } else if newNode === self.prevNode{
            self.nextNode = self.currNode
            self.prevNode = self.delegate?.swiper(self, nodeBefore: newNode)
        } else{
            self.nextNode = self.delegate?.swiper(self, nodeAfter: newNode)
            self.prevNode = self.delegate?.swiper(self, nodeBefore: newNode)
        }
        if let oldone = self.currNode {
            self.delegate?.swiper?(self, didDismissNode: oldone)
        }
        self.currNode = newNode;
        if let idx = self.delegate?.swiper?(self, indexOfNode: newNode){
            self.currentIndex = idx
            self.indicator?.scrollIndex?(idx, swiper: self)
        }
        self.delegate?.swiper?(self, didDisplayNode: newNode)
    }
    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        self.isTransfering = true
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
        self.isTransfering = false
    }
}

//
//  AMPhotoListController.swift
//  Airmey
//
//  Created by supertext on 2020/9/7.
//  Copyright © 2020年 airmey. All rights reserved.
//

import UIKit

open class AMPhotoListController: UIViewController {
    private var photoModels:NSMutableOrderedSet
    private var nextChild:AMPhotoViewController?
    private var prevChild:AMPhotoViewController?
    private var config:AMPhotoConfig
    private var childType:AMPhotoViewController.Type
    private var draging:Bool = false
    private var startIndex:Int
    private let pageController:UIPageViewController
    internal var backgroundView:UIView!
    
    public private(set) var currentChild:AMPhotoViewController!
    public private(set) var currentIndex:Int
    public var backgroundColor:UIColor = .white{
        didSet{
            self.backgroundView.backgroundColor = backgroundColor
        }
    }
    public var isFullscreen:Bool = false{
        didSet{
            if isFullscreen != oldValue {
                let alpha:CGFloat = isFullscreen ? 0 : 1
                let color:UIColor = isFullscreen ? .black : self.backgroundColor
                UIView.animate(withDuration: 0.25, animations: { 
                    self.backgroundView.backgroundColor = color
                    self.navigationController?.navigationBar.alpha = alpha
                })
            }
        }
    }
    public var photos:NSOrderedSet{
        return self.photoModels
    }
    public init(models:[AMPhoto],startIndex:Int)throws{
        self.currentIndex = startIndex
        self.startIndex = startIndex
        self.config = AMPhotoListController.config
        self.childType = AMPhotoListController.childType
        self.photoModels = NSMutableOrderedSet(array: models)
        self.pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        super.init(nibName: nil, bundle: nil)
        guard let beginChild = self.createChild(index: startIndex) else {
            fatalError("startIndex = \(startIndex) in models is out of range")
        }
        self.currentChild = beginChild
        self.pageController.delegate = self
        self.pageController.dataSource = self
        self.extendedLayoutIncludesOpaqueBars = true
        self.pageController.extendedLayoutIncludesOpaqueBars = true
        self.addChild(self.pageController)
    }
    open override func loadView() {
        super.loadView()
        self.backgroundView = UIView(frame: self.view.bounds)
        self.backgroundView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        self.view.addSubview(self.backgroundView)
        self.view.addSubview(self.pageController.view)
    }
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        self.backgroundView.backgroundColor = self.backgroundColor
        for subiew in pageController.view.subviews {
            if let scview = subiew as? UIScrollView{
                scview.contentInsetAdjustmentBehavior = .never
            }
        }
        self.show(child: self.currentChild, at: self.currentIndex, direction: .forward, animated: false)
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension AMPhotoListController{
    public func removeCurrent(){
        self.photoModels.removeObject(at: self.currentIndex)
        guard self.photoModels.count > 0 else {
            self.dismiss(animated: false, completion: nil)
            return
        }
        let idx = self.currentIndex
        if idx >= self.photoModels.count - 1 {
            self.show(index: 0)
        }
        else{
            self.currentIndex = idx
            self.currentChild = self.createChild(index: self.currentIndex)
            self.show(child: self.currentChild, at: self.currentIndex, direction: .forward, animated: true)
        }
    }
}
extension AMPhotoListController{
    //reload the show stack and show startIndex photo
    public func reloadData(){
        guard !draging else {
            return
        }
        guard self.currentIndex != self.startIndex else {
            return
        }
        guard let newChild = self.createChild(index: self.startIndex) else {
            return
        }
        self.currentIndex = self.startIndex
        self.currentChild = newChild
        self.show(child: newChild, at: self.currentIndex, direction: .forward, animated: false)
    }
    //scorll to next one by user
    public func showNext(){
        guard  !draging else {
            return
        }
        guard let nextone = self.nextChild else {
            return
        }
        self.show(child: nextone, at: self.currentIndex+1, direction: .forward, animated: true)
    }
    //scorll to prev one by user
    public func showPrev(){
        guard !draging else {
            return
        }
        guard let prveone = self.prevChild else {
            return
        }
        self.show(child: prveone, at: self.currentIndex-1, direction: .reverse, animated: true)
    }
    // scorll any one at the index
    // if index==currentIndex nothing happend
    // if index out of rang nothing happend
    public func show(index:Int){
        guard index != self.currentIndex else {
            return
        }
        guard index >= 0 , index < self.photoModels.count else {
            return
        }
        switch index {
        case self.currentIndex - 1:
            self.showPrev()
        case self.currentIndex + 1:
            self.showNext()
        default:
            if let newChild = self.createChild(index: index){
                let direction:UIPageViewController.NavigationDirection = index>self.currentIndex ? .forward : .reverse
                self.show(child: newChild, at: index, direction: direction, animated: true)
            }
        }
    }
    private func show(child:AMPhotoViewController,at index:Int,direction:UIPageViewController.NavigationDirection,animated:Bool)
    {
        self.willTransition(from: self.currentChild, fromIndex: self.currentIndex, to: child, toIndex: index)
        self.pageController.setViewControllers([child], direction: direction, animated: animated) {[weak self] (finished) in
            self?.rebuild(with: child, at: index)
        }
    }
    
}
//MARK: overwrite points
extension AMPhotoListController
{
    //provide the config
    @objc open class var config:AMPhotoConfig{
        return AMPhotoConfig()
    }
    //provide the custom subclass of AMPhotoViewController
    @objc open class var childType:AMPhotoViewController.Type{
        return AMPhotoViewController.self
    }
    //this method will be call affter it has been init
    @objc open func prepare(for child:AMPhotoViewController){
        
    }
    //the transition may happen
    @objc open func willTransition(from:AMPhotoViewController,fromIndex:Int,to:AMPhotoViewController,toIndex:Int){
    }
    //the transition did happen
    @objc open func didTransition(from:AMPhotoViewController,fromIndex:Int,to:AMPhotoViewController,toIndex:Int){
    }
}
extension AMPhotoListController{
    private func rebuild(with newChild:AMPhotoViewController,at newIndex:Int){
        let fromIndex = self.currentIndex
        let fromChild = self.currentChild
        if newChild === self.nextChild{
            self.prevChild = fromChild
            self.nextChild = self.createChild(index: newIndex+1)
        }else if newChild === self.prevChild{
            self.nextChild = fromChild
            self.prevChild = self.createChild(index: newIndex-1)
        }
        else{
            self.prevChild = self.createChild(index: newIndex-1)
            self.nextChild = self.createChild(index: newIndex+1)
        }
        self.currentChild = newChild
        self.currentIndex = newIndex
        self.didTransition(from: fromChild!, fromIndex: fromIndex, to: newChild, toIndex: newIndex)
    }
    private func createChild(index:Int)-> AMPhotoViewController?{
        guard index >= 0 ,index < self.photoModels.count else {
            return nil
        }
        let child = self.childType.init(model: self.photoModels[index] as! AMPhoto, config: self.config)
        child.listController = self
        child.photoView.preloadImage()
        self.prepare(for: child)
        return child
    }
}
extension AMPhotoListController:UIPageViewControllerDelegate,UIPageViewControllerDataSource{
    
    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        self.draging = true
    }
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if finished{
            if completed {
                if let newcard = pageViewController.viewControllers?.first as? AMPhotoViewController
                {
                    let index = self.photoModels.index(of: newcard.photoView.model)
                    self.rebuild(with: newcard, at: index)
                }
            }
            self.draging = false
        }
    }
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return self.prevChild
    }
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return self.nextChild
    }
}
extension AMPhotoListController:AMPhotoViewDelegate{
    
}

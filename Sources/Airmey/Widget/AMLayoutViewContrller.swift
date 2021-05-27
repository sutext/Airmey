//
//  AMLayoutViewContrller.swift
//  Airmey
//
//  Created by supertext on 2020/6/24.
//  Copyright © 2020年 airmey. All rights reserved.
//

import UIKit

@available(iOS 10.0, *)
open class AMLayoutViewContrller: UIViewController {
    private weak var rootView:UIView!
    private weak var animationView:UIView?
    private var startPoint = CGPoint.zero;
    private var movingRight = false;
    public private(set) var status:Status = .normal{
        didSet{
            if self.status == .normal {
                self.setShadow(hidden: true)
                self.coverView.removeFromSuperview()
                self.leftViewController?.view.removeFromSuperview()
                self.rightViewController?.view.removeFromSuperview()
                self.animationView = nil
            }else{
                self.setShadow(hidden: false)
                if self.coverView.superview == nil {
                    self.rootView.addSubview(self.coverView)
                }
            }
        }
    }
    private lazy var guesture:UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(AMLayoutViewContrller.panAction(pan:)))
        pan.delegate = self;
        return pan
    }()
    private lazy var coverView:UIControl = {
        let control:UIControl = UIControl(frame: self.rootView.bounds);
        control.backgroundColor = .black
        control.alpha = 0
        control.addTarget(self, action: #selector(AMLayoutViewContrller.coverClicked), for: .touchUpInside)
        return control;
    }()
    public var leftViewController:UIViewController?{
        didSet{
            oldValue?.removeFromParent();
            if let leftvc = self.leftViewController {
                self.addChild(leftvc)
            }
        }
    }
    public var rightViewController:UIViewController?{
        didSet{
            oldValue?.removeFromParent();
            if let rightvc = self.rightViewController {
                self.addChild(rightvc)
            }
        }
    }
    public private(set) var rootViewController:UIViewController{
        didSet{
            oldValue.removeFromParent()
            self.addChild(rootViewController)
            if self.isViewLoaded {
                self.rootView.removeFromSuperview()
                self.rootView = rootViewController.view
                self.rootView.frame = self.view.bounds
                self.view.addSubview(self.rootView)
            }
        }
    }
    public var leftDisplayMode:DisplayMode = .default
    public var rightDisplayMode:DisplayMode = .default
    public var enableShadow:Bool = true;
    public var leftDisplayVector:CGVector = CGVector(dx: 240, dy: 64)
    public var rightDisplayVector:CGVector = CGVector(dx: 80, dy: 64)
    public var animationDuration:TimeInterval = 0.35
    public var dimming:CGFloat = 0.3//the alpha of dimming cover view default=0.4
    public init(rootViewController:UIViewController) {
        self.rootViewController = rootViewController
        super.init(nibName: nil, bundle: nil)
        self.addChild(rootViewController)
        self.extendedLayoutIncludesOpaqueBars = true
    }
    required public init?(coder aDecoder: NSCoder) {
        return nil
    }
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.rootView = self.rootViewController.view
        self.rootView.frame = self.view.bounds
        self.view.addSubview(self.rootView)
        self.setPanGesture(enable: true)
    }
}
//MARK: publish methods
public extension AMLayoutViewContrller{
    func setPanGesture(enable:Bool) {
        if enable {
            self.view.addGestureRecognizer(self.guesture);
        }
        else{
            self.view.removeGestureRecognizer(self.guesture);
        }
    }
    func showLeftController(animated:Bool) {
        if let _ = self.leftViewController, self.status == .normal{
            self.willShowLeftController();
            self.showLeftController(duration: animated ? self.animationDuration : 0)
        }
    }
    func showRightController(animated:Bool) {
        if let _ = self.rightViewController,self.status == .normal {
            self.willShowRightController()
            self.showRightController(duration: animated ? self.animationDuration : 0)
        }
    }
    /**
     * dismiss current showed controller. and show the root view controller
     */
    func dismissCurrentController(animated:Bool)  {
        let duration = animated ? self.animationDuration : 0;
        switch self.status {
        case .leftShowed:
            self.status = .leftHiding;
            self.hideViewController(duration: duration);
        case .rightShowed:
            self.status = .rightHiding;
            self.hideViewController(duration: duration);
        default:
            break;
        }
    }
    
}
///MARK: overwrite point for custom animation addtion
///if this has been overwrite super must be call
extension AMLayoutViewContrller{
    @objc dynamic open func layoutSubviews(offset:CGFloat,maxOffset:CGFloat,atView view:UIView,status:Status) {
        self.coverView.alpha = self.dimming * offset/maxOffset
    }
}
//MARK: core logic
extension AMLayoutViewContrller{
    var leftMaxOffset:CGFloat{
        return self.leftDisplayVector.dx;
    }
    var rightMaxOffset:CGFloat{
        return self.rightDisplayVector.dx;
    }
    func willShowLeftController() {
        guard let leftvc = self.leftViewController else {
            return;
        }
        if self.status == .normal {
            leftvc.view.frame = self.view.bounds
            if self.leftDisplayMode == .background {
                self.view.insertSubview(leftvc.view, belowSubview: self.rootView)
                self.animationView = self.rootView
            }else{
                leftvc.view.frame.origin.x = -leftvc.view.frame.width
                self.view.addSubview(leftvc.view)
                self.animationView = leftvc.view;
            }
            self.status = .leftShowing
        }
    }
    func willShowRightController() {
        guard let rightvc = self.rightViewController else {
            return
        }
        if self.status == .normal {
            self.rightViewController?.view.frame = self.view.bounds
            if self.rightDisplayMode == .background {
                self.view.insertSubview(rightvc.view, belowSubview: self.rootView)
                self.animationView = self.rootView
            }else{
                self.rightViewController?.view.frame.origin.x = self.rootView.frame.width
                self.view.addSubview(rightvc.view)
                self.animationView = rightvc.view;
            }
            self.status = .rightShowing
        }
    }
    func showLeftController(duration:TimeInterval) {
        let offset = self.leftMaxOffset
        UIView.animate(withDuration: duration, animations: { 
            self.layoutSubviews(offset: offset);
        }) { (finished) in
            self.status = .leftShowed;
        }
    }
    func showRightController(duration:TimeInterval) {
        let offset = self.rightMaxOffset
        UIView.animate(withDuration: duration, animations: {
            self.layoutSubviews(offset: offset);
        }) { (finished) in
            self.status = .rightShowed;
        }
    }
    func hideViewController(duration:TimeInterval) {
        UIView.animate(withDuration: duration, animations: {
            self.layoutSubviews(offset: 0);
        }) { (finished) in
            self.status = .normal;
        }
    }
    
    @objc func coverClicked()  {
        self.dismissCurrentController(animated: true);
    }
    @objc func panAction(pan:UIPanGestureRecognizer)  {
        switch pan.state {
        case .began:
            self.begin(panGesture: pan);
        case .ended:
            self.ended(panGesture: pan);
        case .changed:
            self.during(panGesture: pan);
        default:
            break;
        }
    }
    func setShadow(hidden:Bool) {
        guard let aniview = self.animationView else {
            return;
        }
        if !hidden && self.enableShadow {
            aniview.layer.shadowOffset = CGSize.zero
            aniview.layer.shadowRadius = 4.0;
            aniview.layer.shadowPath   = UIBezierPath(rect: aniview.bounds).cgPath
            aniview.layer.shadowOpacity    = 0.8;
        }else{
            aniview.layer.shadowOpacity = 0;
        }
    }
    func layoutSubviews(offset:CGFloat)  {
        guard let aniview = self.animationView else {
            return;
        }
        switch self.status {
        case .leftShowing,.leftHiding:
            let height = self.view.frame.height
            let maxOffset = self.leftMaxOffset
            if self.leftDisplayMode == .background {
                let minscale = (height - self.leftDisplayVector.dy*2)/height
                let scale = 1 - (1-minscale)*offset/maxOffset
                aniview.transform = CGAffineTransform(scaleX: scale, y: scale);
                aniview.frame.origin.x = offset
            }else{
                aniview.frame.origin.x = (offset - aniview.frame.width)
            }
            self.layoutSubviews(offset: offset, maxOffset: maxOffset, atView: aniview, status: self.status)
        case .rightShowing,.rightHiding:
            let width = self.view.frame.width
            let height = self.view.frame.height
            let maxOffset = self.rightMaxOffset
            if self.rightDisplayMode == .background {
                let minscale = (height - self.rightDisplayVector.dy*2)/height
                let scale = 1 - (1-minscale)*offset/maxOffset
                aniview.transform = CGAffineTransform(scaleX: scale, y: scale);
                aniview.frame.origin.x = (width - offset - aniview.frame.width)
            }else{
                aniview.frame.origin.x = width - offset
            }
            self.layoutSubviews(offset: offset, maxOffset: maxOffset, atView: aniview, status: self.status)
        default:
            break;
        }
    }
    func begin(panGesture:UIPanGestureRecognizer) {
        let velocity = panGesture.velocity(in: self.view);
        if velocity.x > 0 {
            if self.status == .normal , let _ = self.leftViewController{
                self.willShowLeftController();
                self.startPoint = self.leftStartPoint;
            }else if self.status == .rightShowed{
                self.startPoint = self.rightStartPoint
                self.status = .rightHiding;
            }
        }
        else if velocity.x < 0
        {
            if self.status == .normal,let _ = self.rightViewController{
                self.willShowRightController();
                self.startPoint = self.rightStartPoint;
            }else if self.status == .leftShowed{
                self.startPoint = self.leftStartPoint;
                self.status = .leftHiding;
            }
        }
    }
    func during(panGesture:UIPanGestureRecognizer) {
        switch self.status {
        case .leftShowing,.leftHiding:
            self.layout(in: panGesture, isLeft: true);
        case .rightShowing,.rightHiding:
            self.layout(in: panGesture, isLeft: false);
        default:
            break;
        }
    }
    func ended(panGesture:UIPanGestureRecognizer) {
        switch self.status {
        case .leftShowing,.leftHiding:
            let currentOffset = panGesture.translation(in: self.view);
            var xoffset = self.startPoint.x + currentOffset.x
            xoffset = self.transition(xoffset: xoffset, isLeft: true);
            let maxOffset = self.leftMaxOffset
            if self.movingRight {
                self.showLeftController(duration: self.animationDuration*TimeInterval((maxOffset - xoffset)/maxOffset))
            }else{
                self.hideViewController(duration: self.animationDuration*TimeInterval(xoffset/maxOffset))
            }
        case .rightShowing,.rightHiding:
            let currentOffset = panGesture.translation(in: self.view);
            var xoffset = self.startPoint.x + currentOffset.x
            xoffset = self.transition(xoffset: xoffset, isLeft: false);
            let maxOffset = self.rightMaxOffset
            if self.movingRight {
                self.hideViewController(duration: self.animationDuration*TimeInterval(xoffset/maxOffset))
            }else{
                self.showRightController(duration: self.animationDuration*TimeInterval((maxOffset - xoffset)/maxOffset))
            }
        default:
            break;
        }
    }
    func layout(in gesture :UIPanGestureRecognizer,isLeft:Bool) {
        let currentOffset = gesture.translation(in: self.view);
        var xoffset = self.startPoint.x + currentOffset.x
        xoffset = self.transition(xoffset: xoffset, isLeft: isLeft);
        let velocity = gesture.velocity(in: self.view);
        self.movingRight = velocity.x>0
        self.layoutSubviews(offset: xoffset);
    }
    func transition(xoffset:CGFloat, isLeft:Bool) -> CGFloat {
        var result = xoffset;
        var maxOffset:CGFloat = 0
        if isLeft {
            maxOffset = self.leftMaxOffset;
        }else{
            maxOffset = self.rightMaxOffset
            result = self.view.frame.width - result;
        }
        if result > maxOffset {
            result = maxOffset;
        }
        if result < 0  {
            result = 0
        }
        return result;
    }
    var leftStartPoint:CGPoint {
        guard let left = self.leftViewController else {
            return CGPoint.zero
        }
        if self.leftDisplayMode == .background {
            return self.rootView.frame.origin;
        } else {
            let frame = left.view.frame;
            return CGPoint(x: frame.origin.x + frame.width, y: frame.origin.y)
        }
    }
    var rightStartPoint:CGPoint{
        guard let right = self.rightViewController else {
            return CGPoint.zero
        }
        if self.rightDisplayMode == .background {
            return CGPoint(x: self.rootView.frame.origin.x + self.rootView.frame.width, y: self.rootView.frame.origin.y);
        }else {
            return right.view.frame.origin
        }
    }
}
extension AMLayoutViewContrller:UIGestureRecognizerDelegate
{
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let offset = self.guesture.translation(in: self.view)
        let velocity = self.guesture.velocity(in: self.view);
        if velocity.x < 600 && abs(offset.x/offset.y) > 1.1 {
            if self.leftViewController != nil || self.rightViewController != nil {
                return true;
            }
        }
        return false;
    }
}
extension AMLayoutViewContrller{
    @objc public enum Status:UInt {
        case normal
        case leftShowing
        case leftShowed
        case leftHiding
        case rightShowing
        case rightShowed
        case rightHiding
    }
    @objc public enum DisplayMode:UInt {
        case background
        case cover
        static let `default`:DisplayMode = .background;
    }
}

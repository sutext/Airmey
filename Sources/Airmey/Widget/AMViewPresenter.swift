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

open class AMWaitingController: UIViewController {
    private lazy var blurView:UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor(white: 0, alpha: 0.6)
        view.layer.cornerRadius = 5
        return view;
    }()
    private lazy var titleLabel:AMLabel = {
        let label = AMLabel()
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    private lazy var indicator:UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .whiteLarge)
        view.startAnimating()
        return view
    }()
    private lazy var stackView:UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .center
        view.distribution = .equalSpacing
        view.spacing = 10
        return view
    }()
    public let presenter: AMDimmingPresenter = AMDimmingPresenter()
    public init(_ message:String?) {
        super.init(nibName: nil, bundle: nil)
        self.titleLabel.text = message
        self.transitioningDelegate = self.presenter
        self.modalPresentationStyle = .custom
    }
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        self.view.addSubview(self.blurView)
        self.blurView.addSubview(self.stackView)
        self.stackView.addArrangedSubview(self.indicator)
        self.stackView.addArrangedSubview(self.titleLabel)
        self.blurView.amake { (am) in
            am.size.equal(to: (170,100))
            am.center.equal(to: 0)
        }
        self.stackView.am.center.equal(to: 0)
    }
}
open class AMRemindController: UIViewController {
    private lazy var blurView:UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor(white: 0, alpha: 0.6)
        view.layer.cornerRadius = 5
        return view;
    }()
    private lazy var messageLabel:AMLabel = {
        let label = AMLabel()
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    public let presenter = AMFadeinPresenter()
    public init(_ message:String?) {
        super.init(nibName: nil, bundle: nil)
        self.messageLabel.text = message
        self.transitioningDelegate = self.presenter
        self.modalPresentationStyle = .custom
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        self.view.addSubview(self.blurView)
        self.blurView.addSubview(self.messageLabel)
        self.messageLabel.am.center.equal(to: 0)
        self.blurView.amake{
            $0.size.equal(to: (200,80))
            $0.center.equal(to: 0)
        }
    }
}
open class AMActionController<ActionItem:AMTextConvertible>:UIViewController,
    UITableViewDataSource,UITableViewDelegate{
    private var finishBlock:((AMActionController,ActionItem,Int)->Void)?
    private let effectView = AMEffectView()
    private var items:[ActionItem]
    private let presenter:AMFramePresenter
    private let cancelBar = CancelBar()
    private let tableView = UITableView()
    private let rowHeight:CGFloat = 50
    public init(_ items:[ActionItem],finish:((AMActionController,ActionItem,Int)->Void)?=nil) {
        let count = items.count <> 1...5
        self.items = items
        self.presenter = AMFramePresenter(CGFloat(count)*self.rowHeight + .tabbarHeight)
        self.finishBlock = finish
        super.init(nibName: nil, bundle: nil)
        self.tableView.isScrollEnabled = (items.count > 5)
        self.transitioningDelegate = self.presenter
        self.modalPresentationStyle = .custom
    }
    ///dos't implement NSCoding protocol
    required public init?(coder aDecoder: NSCoder) {
        return nil
    }
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.effectView)
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.cancelBar)
        self.effectView.am.edge.equal(to: 0)
        self.tableView.contentInsetAdjustmentBehavior = .never
        self.tableView.delaysContentTouches = false
        self.tableView.separatorStyle = .singleLine
        self.tableView.estimatedRowHeight = 0
        self.tableView.estimatedSectionFooterHeight = 0
        self.tableView.estimatedSectionHeaderHeight = 0
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.rowHeight = self.rowHeight
        self.tableView.backgroundColor = .clear
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.amake { am in
            am.edge.equal(top: 0, left: 0, right: 0)
            am.height.equal(to: CGFloat((self.items.count <> 1...5)*50))
        }
        self.cancelBar.control.addTarget(self, action: #selector(AMActionController.cancelAction(sender:)), for: .touchUpInside)
    }
    @objc dynamic func cancelAction(sender:UIControl){
        self.hide()
    }
    private func hide(_ index:Int? = nil){
        self.dismiss(animated: true) {
            if let idx = index{
                self.finishBlock?(self, self.items[idx],idx);
            }
        }
    }
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "actionCell")
        if cell == nil{
            cell = UITableViewCell(style: .default, reuseIdentifier: "actionCell");
            cell?.accessoryType = .none;
            cell?.textLabel?.textAlignment = .center;
            cell?.separatorInset = UIEdgeInsets.zero
            cell?.backgroundColor = .clear
        }
        cell!.textLabel?.text = self.items[indexPath.row].text;
        return cell!;
    }
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.hide(indexPath.row)
    }
}
extension AMActionController{
    class CancelBar:AMToolBar{
        let label = UILabel()
        let control = UIControl()
        init(){
            super.init(style:.normal)
            self.shadowLine.isHidden = true
            self.label.translatesAutoresizingMaskIntoConstraints = false
            self.control.translatesAutoresizingMaskIntoConstraints = false
            self.contentView.addSubview(self.label)
            self.addSubview(self.control)
            self.label.text = "取消"
            self.label.font = .systemFont(ofSize: 18)
            self.label.textColor = .darkText
            self.label.am.center.equal(to: 0)
            self.control.am.edge.equal(to: 0)
            self.control.addTarget(self, action: #selector(CancelBar.touchDown), for: .touchDown)
            self.control.addTarget(self, action: #selector(CancelBar.touchUp), for: .touchUpInside)
            self.control.addTarget(self, action: #selector(CancelBar.touchUp), for: .touchUpOutside)
        }
        @objc func touchDown(){
            self.backgroundColor = .lightGray
        }
        @objc func touchUp(){
            self.backgroundColor = .clear
        }
        required init?(coder aDecoder: NSCoder) {
            return nil
        }
    }
}

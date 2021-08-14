//
//  AMPopup.swift
//  Airmey
//
//  Created by supertext on 5/28/21.
//

import UIKit

///Add an  popup operation queue
open class AMPopupCenter {
    /// default Wait controller  override it for custom
    open class var Wait:AMWaitable.Type{AMWaitController.self}
    /// default Alert controller  override it for custom. By defualt use system Impl
    open class var Alert:AMAlertable.Type{UIAlert.self}
    /// default Remind controller  override it for custom
    open class var Remind:AMRemindable.Type{AMRemindController.self}
    /// default Action controller  override it for custom By defualt use system Impl
    open class var Action:AMActionable.Type{UIAlert.self}
    private var queue:[Operation] = []
    private var current:Operation?
    private var waiter:AMWaitable?
    public init(){}
}
extension AMPopupCenter{
    /// dismiss any UIViewController
    public func dismiss(_ vc:UIViewController,animated:Bool=true,completion:AMBlock?=nil){
        self.add(.dismiss(vc: vc, animated: animated, finish: completion))
    }
    /// present any UIViewController
    public func present(_ vc:UIViewController,animated:Bool=true,completion:AMBlock?=nil){
        self.add(.present(vc: vc, animated: animated, finish: completion))
    }
    /// presnet a remindable controller
    public func remind(_ msg:String,
                title:String?=nil,
                duration:TimeInterval?=nil,
                meta:AMRemindable.Type?=nil,
                onhide:AMBlock?=nil) {
        let vc = (meta ?? Self.Remind).init(msg, title: title)
        vc.pop = self
        self.add(.remind(vc,duration:duration))
    }
    /// presnet an actionable controller
    public func action(_ items:[AMTextConvertible],meta:AMActionable.Type?=nil,onhide:ActionHide?=nil){
        let vc = (meta ?? Self.Action).init(items,onhide:onhide)
        self.add(.action(vc))
    }
    /// present an alertable controller
    public func alert(
        _ msg:String,
        title:String? = nil,
        confirm:String? = nil,
        cancel:String? = nil,
        meta:AMAlertable.Type? = nil,
        onhide:AlertHide? = nil)  {
        let vc = (meta ?? Self.Alert).init(msg, title: title,confirm: confirm,cancel: cancel, onhide: onhide)
        self.add(.alert(vc))
    }
    /// present a waitable controller
    public func wait(_ msg:String? = nil,meta:AMWaitable.Type?=nil)  {
        let vc = (meta ?? Self.Wait).init(msg)
        vc.pop = self
        self.add(.wait(vc))
    }
    /// dismiss current wating controller
    public func idle() {
        self.add(.idle)
    }
    /// Clear all the presented controller base on keyWindow'rootViewController
    public func clear() {
        self.add(.clear)
    }
    /// current top controller from the key window
    public var top:UIViewController?{
        var next:UIViewController? = UIApplication.shared.keyWindow?.rootViewController
        while next?.presentedViewController != nil {
            next = next?.presentedViewController
        }
        return next
    }
}
extension AMPopupCenter{
    private func add(_ op:Operation) {
        DispatchQueue.main.async {
            self.queue.append(op)
            self.next()
        }        
    }
    private func delayNext(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.next()
        }
    }
    private func next() {
        guard self.current == nil,!self.queue.isEmpty else {
            return
        }
        self.current = self.queue.removeFirst()
        guard let current = self.current else {
            return
        }
        switch current {
        case .wait(let vc):
            self._wait(vc)
        case .idle:
            self._idle()
        case .clear:
            self._clear()
        case .remind(let vc,let duration):
            self._remind(vc,duration: duration)
        case .alert(let vc):
            self._present(vc, animated: true, finish: nil)
        case .action(let vc):
            self._present(vc, animated: true, finish: nil)
        case .present(let vc, let animated,let finish):
            self._present(vc,animated: animated,finish: finish)
        case .dismiss(let popup,let animated,let finish):
            self._dismiss(popup,animated:animated,finish: finish)
        }
    }
    private func _clear() {
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: false)
        self.current = nil
        self.delayNext()
    }
    private func _dismiss(_ vc:UIViewController, animated:Bool,finish:AMBlock?){
        let block = {
            finish?()
            self.current = nil
            self.delayNext()
        }
        if let popup = vc as? AMPopupController {
            popup._dismiss(animated: animated,completion: block)
        }else{
            vc.dismiss(animated: animated,completion: block)
        }
    }
    private func _present(_ vc:UIViewController,animated:Bool,finish:AMBlock?) {
        if let nvc = vc as? AMPopupController {
            nvc.pop = self
        }
        self.show(vc,animated: animated) {
            finish?()
            self.current = nil
            self.delayNext()
        }
    }
    private func _remind(_ vc:AMRemindable,duration:TimeInterval?) {
        self.show(vc)
        DispatchQueue.main.asyncAfter(deadline: .now()+(duration ?? 1)) {
            vc._dismiss(animated: true){
                self.current = nil
                self.delayNext()
            }
        }
    }
    private func _wait(_ vc:AMWaitable)  {
        guard self.waiter == nil else {
            self.current = nil
            self.delayNext()
            return
        }
        self.waiter = vc
        self.show(vc) {
            self.current = nil
            self.delayNext()
        }
    }
    private func _idle() {
        guard let vc = self.waiter else {
            self.current = nil
            self.delayNext()
            return
        }
        vc._dismiss(animated: true){
            self.waiter = nil
            self.current = nil
            self.delayNext()
        }
    }
    private func show(_ vc: UIViewController,animated: Bool=true, completion: AMBlock? = nil){
        guard let top = self.top else {
            fatalError("rootViewController not found in keywindow!")
        }
        top.present(vc, animated: animated, completion: completion)
    }
}
extension AMPopupCenter{
    public typealias AlertHide = (Int)->Void
    public typealias ActionHide = (AMTextConvertible?,Int?)->Void
    enum Operation{
        case idle
        case clear
        case wait(_ vc:AMWaitable)
        case alert(_ vc:AMAlertable)
        case action(_ vc:AMActionable)
        case remind(_ vc:AMRemindable,duration:TimeInterval?)
        case present(
                vc:UIViewController,
                animated:Bool,
                finish:AMBlock?)
        case dismiss(
                vc:UIViewController,
                animated:Bool,
                finish:AMBlock?)
    }
}
extension AMPopupCenter{
    /// system implemention for AMAlertable AMActionable
    open class UIAlert:UIAlertController,AMAlertable,AMActionable{
        public required convenience init(_ msg: String, title: String?, confirm: String?, cancel: String?, onhide: AlertHide?) {
            self.init(title: title, message: msg, preferredStyle: .alert)
            self.addAction(.init(title: confirm ?? "Confirm", style: .default, handler: { act in
                onhide?(0)
            }))
            if let cancel = cancel {
                self.addAction(.init(title: cancel, style: .default, handler: { act in
                    onhide?(1)
                }))
            }
        }
        public required convenience init(_ items: [AMTextConvertible], onhide: ActionHide?) {
            self.init(title: nil, message: nil, preferredStyle: .actionSheet)
            for idx in (0..<items.count) {
                self.addAction(.init(title: items[idx].text, style: .default, handler: { act in
                    onhide?(items[idx],idx)
                }))
            }
            self.addAction(.init(title: "Cancel", style: .destructive, handler: { act in
                onhide?(nil,nil)
            }))
        }
    }
}

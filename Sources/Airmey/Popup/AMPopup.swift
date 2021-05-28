//
//  AMPopup.swift
//  Airmey
//
//  Created by supertext on 5/28/21.
//

import UIKit

public protocol AMWaitable:UIViewController{
    init(_ msg:String?)
}
public protocol AMAlertable:UIViewController{
    init(_ msg:String,title:String?,cancel:String?,confirm:String?,onhide:AMPopup.AlertBlock?)
}
public protocol AMRemindable:UIViewController{
    init(_ msg:String,title:String?)
}
public protocol AMActionable:UIViewController{
    init(_ items:[AMTextConvertible],onhide:AMPopup.ActionBlock?)
}
public protocol AMPresentable:UIViewController{
    init(_ params:[String:Any]?)
}
open class AMAlertController:UIAlertController,AMAlertable{
    public required convenience init(_ msg:String,title:String?,cancel:String?,confirm:String?,onhide:AMPopup.AlertBlock?) {
        self.init(title: title, message: msg, preferredStyle: .alert)
        self.addAction(UIAlertAction(title: confirm ?? "Confirm", style: .default, handler: {(action) in
            onhide?(0)
        }))
        if let cancel = cancel{
            self.addAction(UIAlertAction(title: cancel, style: .default, handler: {(action) in
                onhide?(1)
            }))
        }
    }
    required convenience public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
open class AMPopup {
    open class var Alert:AMAlertable.Type{AMAlertController.self}
    private var queue:[Operation] = []
    private var current:Operation?
    private var showed:[String:UIViewController] = [:]
    public init(){
        
    }
    func add(_ op:Operation) {
        self.queue.append(op)
        self.next()
    }
    func next() {
        if self.current != nil {
            return
        }
        if queue.isEmpty {
            return
        }
        self.current = self.queue.removeFirst()
        guard let current = self.current else {
            return
        }
        switch current {
        case .wait(let msg,let meta):
            self._wait(msg,meta: meta)
        case .idle:
            self._idle()
        case .alert(let msg,let title,let cancel,let confirm,let meta,let onhide):
            self._alert(msg, title: title, cancel: cancel, confirm: confirm, meta: meta, onhide: onhide)
        case .clear:
            self._clear()
        case .action(let items, let meta, let onhide):
            self._action(items, meta: meta, onhide: onhide)
        case .remind(let msg, let title,let meta):
            self._remind(msg, title: title, meta: meta)
        case .dismiss(let name, let finish):
            self._dismiss(name,finish: finish)
        case .present(let meta, let params):
            self._present(meta,params: params)
        }
    }
}
public extension AMPopup{
    func present(_ meta:AMPresentable.Type,params:[String:Any]?=nil) {
        self.add(.present(meta: meta, params: params))
    }
    func dismiss(_ meta:UIViewController.Type,finish:(()->Void)? = nil){
        self.add(.dismiss(name: NSStringFromClass(meta), finish: finish))
    }
    func remind(_ msg:String,title:String?=nil,meta:AMRemindable.Type?=nil) {
        self.add(.remind(msg: msg, title: title,meta:meta))
    }
    func action(_ items:[AMTextConvertible],meta:AMActionable.Type?=nil,onhide:ActionBlock?=nil)  {
        self.add(.action(items: items,meta:meta,onhide: onhide))
    }
    func clear() {
        self.add(.clear)
    }
    func alert(_ msg:String,
               title:String? = nil,
               cancel:String? = nil,
               confirm:String? = nil,
               meta:AMAlertable.Type? = nil,
               onhide:AlertBlock? = nil)  {
        self.add(.alert(msg: msg, title: title, cancel: cancel, confirm: confirm
                        , meta: meta, onhide: onhide))
    }
    func wait(_ msg:String?,meta:AMWaitable.Type?=nil)  {
        self.add(.wait(msg: msg,meta:meta))
    }
    func idle() {
        self.add(.idle)
    }
}
extension AMPopup{
    func _present(_ meta:AMPresentable.Type,params:[String:Any]?=nil) {
        let name = NSStringFromClass(meta)
        guard self.showed[name] == nil else {
            self.current = nil
            self.next()
            return
        }
        let vc = meta.init(params)
        self.showed[name] = vc
        self.show(vc) {
            self.current = nil
            self.next()
        }
    }
    func _dismiss(_ name:String,finish:(()->Void)? = nil){
        guard let vc = self.showed[name]  else {
            finish?()
            self.current = nil
            self.next()
            return
        }
        vc.dismiss(animated: true) {
            finish?()
            self.current = nil
            self.next()
        }
    }
    func _remind(_ msg:String,title:String?,meta:AMRemindable.Type?) {
        let cls = meta ?? AMRemindController.self
        let name = NSStringFromClass(cls)
        guard self.showed[name] == nil else {
            self.current = nil
            self.next()
            return
        }
        let vc = cls.init(msg, title: title)
        self.showed[name] = vc
        self.show(vc) {
            self.current = nil
            self.next()
        }
    }
    
    func _action(_ items:[AMTextConvertible],meta:AMActionable.Type?,onhide:ActionBlock?)  {
        let cls = meta ?? AMActionController.self
        let name = NSStringFromClass(cls)
        guard self.showed[name] == nil else {
            self.current = nil
            self.next()
            return
        }
        let vc = cls.init(items, onhide: onhide)
        self.showed[name] = vc
        self.show(vc) {
            self.current = nil
            self.next()
        }
    }
    func _clear() {
    }
    func _alert(_ msg:String,
               title:String?,
               cancel:String?,
               confirm:String?,
               meta:AMAlertable.Type?,
               onhide:AlertBlock?)  {
        let cls = meta ?? AMAlertController.self
        let name = NSStringFromClass(cls)
        guard self.showed[name] == nil else {
            self.current = nil
            self.next()
            return
        }
        let vc = cls.init(msg, title: title, cancel: cancel, confirm: confirm, onhide: onhide)
        self.showed[name] = vc
        self.show(vc) {
            self.current = nil
            self.next()
        }
    }
    func _wait(_ msg:String?,meta:AMWaitable.Type?)  {
        let cls = meta ?? AMWaitingController.self
        let name = NSStringFromClass(cls)
        guard self.showed[name] == nil else {
            self.current = nil
            self.next()
            return
        }
        let vc = cls.init(msg)
        self.showed[name] = vc
        self.show(vc) {
            self.current = nil
            self.next()
        }
    }
    func _idle() {
    }
    private var topController:UIViewController?{
        var next:UIViewController? = UIApplication.shared.keyWindow?.rootViewController
        while next?.presentedViewController != nil {
            next = next?.presentedViewController
        }
        return next
    }
    private func show(_ vc: UIViewController, completion: (() -> Void)?){
        self.topController?.present(vc, animated: true, completion: completion)
    }
}
extension AMPopup{
    public typealias AlertBlock = (Int)->Void
    public typealias ActionBlock = (AMTextConvertible?,Int?)->Void
    enum Operation{
        case wait(msg:String?,meta:AMWaitable.Type?)
        case idle
        case clear
        case alert(msg:String,title:String?,cancel:String?,confirm:String?,meta:AMAlertable.Type?,onhide:AlertBlock?)
        case action(items:[AMTextConvertible],meta:AMActionable.Type?,onhide:ActionBlock?)
        case remind(msg:String,title:String?,meta:AMRemindable.Type?)
        case present(meta:AMPresentable.Type,params:[String:Any]?)
        case dismiss(name:String,finish:(()->Void)?)
    }
}

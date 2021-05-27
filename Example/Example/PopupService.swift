//
//  PopupService.swift
//  Example
//
//  Created by supertext on 5/27/21.
//

import UIKit
import Airmey

public let pop = PopupService()

open class PopupService {
    fileprivate init(){}
    private weak var waiter:UIViewController?
    private weak var alert:UIAlertController?
    public func alert(title:String?="提示",_ message:String?,ensure:String = "确定",cancel:String?=nil,dismissIndex:((Int)->Void)?=nil){
        guard self.alert == nil else { return }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: ensure, style: .default, handler: {[weak self] (action) in
            self?.alert = nil
            dismissIndex?(0)
        }))
        if let cancel = cancel{
            alert.addAction(UIAlertAction(title: cancel, style: .default, handler: {[weak self] (action) in
                self?.alert = nil
                dismissIndex?(1)
            }))
        }
        self.alert = alert
        self.present(alert, animated: true, completion: nil)
    }
    public func wait(_ message:String?=nil,appeared:(()->Void)?=nil) {
        guard self.waiter == nil else { return }
        let controller = AMWaitingController(message)
        controller.presenter.appearedBlock = appeared
        self.waiter = controller
        self.present(controller, animated: true, completion: nil)
    }
    public func idle(finished:(()->Void)?=nil) {
        guard let current = self.waiter  else {
            return
        }
        self.waiter = nil
        current.dismiss(animated: true, completion: {
            DispatchQueue.main.async {
                finished?()
            }
        })
    }
    public func remind(_ type:RemindType,dismissed:(()->Void)?=nil) {
        var message:String?
        switch type {
        case .succeed(let info):
            message = info
        case .failure(let info):
            message = info
        case .error(let err):
            message = "err\(err)"
        }
        let remind = AMRemindController(message)
        remind.presenter.dismissBlock = dismissed
        self.present(remind, animated: true, completion: nil)
    }
    public func action<ActionItem:AMTextConvertible>(_ items:[ActionItem],style:ActionStyle = .plain,dismissIndex:((ActionItem,Int)->Void)?){
        guard items.count > 0 else {
            return
        }
        var vc:UIViewController?
        switch style {
        case .system:
            let action = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            for item in items.enumerated() {
                action.addAction(UIAlertAction(title: item.element.text, style: .default, handler: { (action) in
                    dismissIndex?(item.element,item.offset)
                }))
            }
            action.addAction(UIAlertAction(title: "取消", style: .cancel))
            vc = action
        case .plain:
            let plain = AMActionController(items){sender,item,index in
                dismissIndex?(item,index)
            }
            vc = plain
        }
        self.present(vc!, animated: true, completion: nil)
    }
    private var topController:UIViewController?{
        var next:UIViewController? = UIApplication.shared.keyWindow?.rootViewController
        while next?.presentedViewController != nil {
            next = next?.presentedViewController
        }
        return next
    }
    open func present(_ vc: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil){
        self.topController?.present(vc, animated: animated, completion: completion)
    }
    public func dismiss(animated: Bool = true, completion: (() -> Void)? = nil){
        guard let top = self.topController else {
            return
        }
        guard top != UIApplication.shared.keyWindow?.rootViewController else {
            return
        }
        top.dismiss(animated: animated, completion: completion)
    }
}
extension PopupService{
    public enum RemindType {
        case succeed(String)
        case failure(String)
        case error(Error)
    }
    public enum ActionStyle {
        case system
        case plain
    }
}

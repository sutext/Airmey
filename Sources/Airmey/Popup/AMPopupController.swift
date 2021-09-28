//
//  AMPopupController.swift
//  Airmey
//
//  Created by supertext on 2021/5/30.
//

import UIKit
extension UIViewController{
    var am_pop:AMPopupCenter?{
        get{
            let key  = UnsafeRawPointer.init(bitPattern: "am_pop_key".hashValue)!
            return objc_getAssociatedObject(self, key) as? AMPopupCenter
        }
        set{
            let key  = UnsafeRawPointer.init(bitPattern: "am_pop_key".hashValue)!
            objc_setAssociatedObject(self, key, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    @objc private func builtinDismiss(animated flag: Bool, completion: AMBlock? = nil){
        if let pop = self.am_pop {
            pop.dismiss(self, animated: flag, completion: completion)
        }else{
            self.builtinDismiss(animated: flag, completion: completion)
        }
    }
    open func _dismiss(animated flag: Bool, completion: AMBlock? = nil) {
        self.builtinDismiss(animated: flag, completion: nil)
        /// make callback surely
        if flag {
            DispatchQueue.main.asyncAfter(deadline: .now()+0.31) {
                completion?()
            }
        }else{
            completion?()
        }
    }
    class func swizzleDismiss() {
        let originalSelctor = #selector(UIViewController.dismiss(animated:completion:))
        let swizzledSelector = #selector(UIViewController.builtinDismiss(animated:completion:))
        let aClass = UIViewController.self
        let originalMethod = class_getInstanceMethod(aClass, originalSelctor)
        let swizzledMethod = class_getInstanceMethod(aClass, swizzledSelector)
        method_exchangeImplementations(originalMethod!, swizzledMethod!)
    }
}
open class AMPopupController:UIViewController{
    /// public presenter
    public let presenter:AMPresenter
    ///
    /// AMPopupController designed initializer
    /// - Parameters:
    ///     - presenter: The present animation describer
    /// - Note: After init  A default implements of presenter.onMaskClick will be set.
    ///
    public init(_ presenter:AMPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
        self.transitioningDelegate = presenter
        self.modalPresentationStyle = .custom
        presenter.onMaskClick = {[weak self] in
            self?.dismiss(animated: true)
        }
    }
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public typealias AMAlertBlock = (Int)->Void
public typealias AMActionBlock = (AMTextDisplayable?,Int?)->Void

///Loading style
public protocol AMWaitable:AMPopupController{
    static var timeout:TimeInterval {get}
    init(_ msg:String?,timeout:TimeInterval?)
}
///Tost style
public protocol AMRemindable:AMPopupController{
    init(_ msg:AMTextDisplayable,title:AMTextDisplayable?)
}
///Alert style
public protocol AMAlertable:UIViewController{
    init(
        _ msg:AMTextDisplayable,
        title:AMTextDisplayable?,
        confirm:AMTextDisplayable?,
        cancel:AMTextDisplayable?,
        onhide:AMAlertBlock?)
}
///ActionSheet style
public protocol AMActionable:UIViewController{
    init(_ items:[AMTextDisplayable],onhide:AMActionBlock?)
}

//
//  AMPopupController.swift
//  Airmey
//
//  Created by supertext on 2021/5/30.
//

import UIKit

/// Describe the popup level base on UIWindow.Level
public typealias AMPopupLevel = UIWindow.Level

extension AMPopupLevel{
    /// Just for set window level friendly
    ///
    ///         let window = UIWindow()
    ///         window.windowLevel = .alert + 1
    ///
    public static func +(lhs:AMPopupLevel,rhs:CGFloat)->UIWindow.Level{
        return AMPopupLevel(rawValue: lhs.rawValue - rhs)
    }
    public static func -(lhs:AMPopupLevel,rhs:CGFloat)->UIWindow.Level{
        return AMPopupLevel(rawValue: lhs.rawValue - rhs)
    }
    /// global default wait window level
    /// by default use .alert + 2000
    public static var wait:AMPopupLevel { .alert + 2000 }
    /// global default remind window level
    /// by default use .alert + 1000
    public static var remind:AMPopupLevel { .alert + 1000 }
    /// global default remind window level
    /// by default use .alert
    public static var action:AMPopupLevel { .alert }
}

extension UIViewController{
    /// override this property for change the popup window level
    /// by default use UIWindow.Level.alert
    ///
    ///     public var popupLevel:UIWindow.Level {
    ///         .alert + 1
    ///     }
    ///
    @objc public var popupLevel:AMPopupLevel {
        .alert
    }
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
    func _dismiss(animated flag: Bool, completion: AMBlock? = nil) {
        self.builtinDismiss(animated: flag, completion: nil)
        let window = self.view.window as? AMPopupWindow
        func hideWindow(){
            if let pop = self.am_pop,let wind = window,
               let idx = pop.windows.lastIndex(of: wind){
                wind.isHidden = true
                wind.resignKey()
                self.am_pop = nil
                pop.windows.remove(at: idx)
            }
        }
        /// make callback surely
        if flag {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.31) {
                hideWindow()
                completion?()
            }
        }else{
            hideWindow()
            completion?()
        }
    }
    class func swizzleDismiss() {
        let originalSelector = #selector(UIViewController.dismiss(animated:completion:))
        let swizzledSelector = #selector(UIViewController.builtinDismiss(animated:completion:))
        let aClass = UIViewController.self
        let originalMethod = class_getInstanceMethod(aClass, originalSelector)!
        let swizzledMethod = class_getInstanceMethod(aClass, swizzledSelector)!
        method_exchangeImplementations(originalMethod, swizzledMethod)
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
    open override var shouldAutorotate: Bool { presenter.shouldAutorotate }
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

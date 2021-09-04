//
//  AMPopupController.swift
//  Airmey
//
//  Created by supertext on 2021/5/30.
//

import UIKit

open class AMPopupController:UIViewController{
    var pop:AMPopupCenter?
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
    open override func dismiss(animated flag: Bool, completion: AMBlock? = nil) {
        self.pop?.dismiss(self, animated: flag, completion: completion)
    }
    func _dismiss(animated flag: Bool, completion: AMBlock? = nil){
        super.dismiss(animated: flag, completion: completion)
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

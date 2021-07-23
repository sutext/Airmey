//
//  AMToolBar.swift
//  Airmey
//
//  Created by supertext on 2020/11/14.
//  Copyright © 2020年 airmey. All rights reserved.
//

import UIKit

///this is an abstract class
///all the subviews must been add to the contentView
///this class just define an toolbar structure
///you must inherit from this class and implment your appearance

open class AMToolBar: UIView {
    /// as same as the class var
    public let style:Style
    /// as same as the class var
    public let contentHeight:CGFloat
    /// all subview must be add to the content view
    public let contentView = UIView()
    private var effectView:UIVisualEffectView?
    private var shadowLine:UIView?
    private var offsetConstraint:NSLayoutConstraint!
    private var heightConstraint:NSLayoutConstraint!
    public init() {
        self.style = Self.style
        self.contentHeight = Self.contentHeight
        super.init(frame: .zero)
        self.addSubview(self.contentView)
        switch self.style{
        case .header:
            self.contentView.amake {
                $0.edge.equal(top:.headerHeight,left: 0,bottom: 0,right: 0)
                self.heightConstraint = $0.height.equal(to: contentHeight)
            }
        case .footer:
            self.contentView.amake {
                $0.edge.equal(top:0,left: 0,bottom: -.footerHeight,right: 0)
                self.heightConstraint = $0.height.equal(to: contentHeight)
            }
        }
    }
    /// override for your custom
    open class var style:Style{.footer}
    /// the toolbar content height. by default decide by style. override for custom
    open class var contentHeight:CGFloat{
        switch style{
        case .header:
            return .navbarHeight - .headerHeight
        case .footer:
            return .tabbarHeight - .footerHeight
        }
    }
    /// the tool bar height
    public lazy var height:CGFloat = {
        switch style {
        case .header:
            return contentHeight - .headerHeight
        case .footer:
            return contentHeight - .footerHeight
        }
    }()
    /// add shadow line
    /// using nil for remove shaddow
    public func usingShadow(_ color:UIColor? = .hex(0xbbbbbb,alpha:0.7)){
        self.shadowLine?.removeFromSuperview()
        let view = UIView()
        view.backgroundColor = color
        self.addSubview(view)
        switch style{
        case .header:
            view.amake {
                $0.edge.equal(left: 0,bottom: 0, right: 0)
                $0.height.equal(to: 0.5)
            }
        case .footer:
            view.amake {
                $0.edge.equal(top: 0, left: 0, right: 0)
                $0.height.equal(to: 0.5)
            }
        }
        self.shadowLine = view
    }
    /// add UIBlurEffect
    /// using nil for remove effect
    open func usingEffect(_ effect:UIBlurEffect.Style? = .light){
        self.effectView?.removeFromSuperview()
        guard let effect = effect else {
            return
        }
        let view = UIVisualEffectView(effect: UIBlurEffect(style:effect))
        self.insertSubview(view, belowSubview: self.contentView)
        view.am.edge.equal(to: 0)
        self.effectView = view
    }
    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if let _ = self.superview{
            switch style{
            case .header:
                self.offsetConstraint = self.am.edge.equal(top:0,left: 0,right: 0).top!
            case .footer:
                self.offsetConstraint = self.am.edge.equal(left: 0,bottom: 0,right: 0).bottom!
            }
        }
    }
    public convenience required init?(coder aDecoder: NSCoder) {
        return nil
    }
}
extension AMToolBar{
    public enum Style{
        case header
        case footer
    }
    public func setup(offset:CGFloat){
        self.offsetConstraint.constant = offset
        UIView.animate(withDuration: 0.25) {
            self.superview?.layoutIfNeeded();
        }
    }
    public func setup(height:CGFloat){
        self.heightConstraint.constant = height
        UIView.animate(withDuration: 0.25) {
            self.superview?.layoutIfNeeded();
        }
    }
}


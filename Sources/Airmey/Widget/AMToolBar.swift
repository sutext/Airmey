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
///this class just define an toolBar structure
///you must inherit from this class and implment your appearance

open class AMToolBar: UIView {
    open class var contentHeight:CGFloat{
        switch position{
        case .top:
            return .navbarHeight - .headerHeight
        case .bottom:
            return .tabbarHeight - .footerHeight
        }
    }
    open class var position:Position{.bottom}
    public let contentView = UIView()
    public let style:Style
    ///available when effect style
    public private(set) var effectView:AMEffectView?
    private var positionConstraint:NSLayoutConstraint!
    private var heightConstraint:NSLayoutConstraint!
    public init(style:Style = .normal) {
        self.style = style
        super.init(frame: .zero)
        switch style {
        case .effect:
            self.effectView = AMEffectView()
            self.addSubview(self.effectView!)
            self.addSubview(self.contentView)
            self.effectView?.am.edge.equal(to: 0)
        case .normal:
            self.addSubview(self.contentView)
        }
        switch Self.position{
        case .top:
            self.contentView.amake {
                $0.edge.equal(top:.headerHeight,left: 0,bottom: 0,right: 0)
                self.heightConstraint = $0.height.equal(to: Self.contentHeight)
            }
        case .bottom:
            self.contentView.amake {
                $0.edge.equal(top:0,left: 0,bottom: -.footerHeight,right: 0)
                self.heightConstraint = $0.height.equal(to: Self.contentHeight)
            }
        }
       
    }
    public convenience init(){
        self.init(style: .effect)
    }
    public convenience required init?(coder aDecoder: NSCoder) {
        return nil
    }
    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if let _ = self.superview{
            switch Self.position{
            case .top:
                self.positionConstraint = self.am.edge.equal(top:0,left: 0,right: 0).top!
            case .bottom:
                self.positionConstraint = self.am.edge.equal(left: 0,bottom: 0,right: 0).bottom!
            }
        }
    }
    public lazy var height:CGFloat {
        switch Self.position {
        case .top:
            return .navbarHeight
        case .bottom:
            return .tabbarHeight
        }
    }
    public lazy var contentHeight:CGFloat = {
        Self.contentHeight
    }()
    public lazy var shadowLine:UIView={
        let view = UIView()
        view.backgroundColor = .hex(0xe6e6e6,alpha:0.9)
        self.addSubview(view)
        switch Self.position{
        case .top:
            view.amake {
                $0.edge.equal(left: 0,bottom: 0, right: 0)
                $0.height.equal(to: 0.5)
            }
        case .bottom:
            view.amake {
                $0.edge.equal(top: 0, left: 0, right: 0)
                $0.height.equal(to: 0.5)
            }
        }
        return view
    }()
}
extension AMToolBar{
    public func setup(position:CGFloat){
        self.positionConstraint.constant = position
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
    public enum Style {
        case effect
        case normal
    }
    public enum Position{
        case top
        case bottom
    }
}


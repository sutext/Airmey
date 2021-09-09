//
//  AMAutoLayout.swift
//  Airmey
//
//  Created by supertext on 2020/7/21.
//  Copyright © 2020年 airmey. All rights reserved.
//

import UIKit

///These sample methods of layout anchor create an active constraint
extension NSLayoutXAxisAnchor{
    @discardableResult
    func equal(to other:NSLayoutXAxisAnchor,offset:CGFloat?=nil) -> NSLayoutConstraint {
        guard let offset = offset else {
            let const = self.constraint(equalTo: other)
            const.isActive = true
            return const
        }
        let const = self.constraint(equalTo: other,constant:offset);
        const.isActive = true;
        return const;
    }
    @discardableResult
    func less(than other:NSLayoutXAxisAnchor,offset:CGFloat?=nil)-> NSLayoutConstraint{
        guard let offset = offset else {
            let const = self.constraint(lessThanOrEqualTo: other)
            const.isActive = true
            return const
        }
        let const = self.constraint(lessThanOrEqualTo: other,constant:offset);
        const.isActive = true
        return const
    }
    @discardableResult
    func greater(than other:NSLayoutXAxisAnchor,offset:CGFloat?=nil)-> NSLayoutConstraint{
        guard let offset = offset else {
            let const = self.constraint(greaterThanOrEqualTo: other)
            const.isActive = true
            return const
        }
        let const = self.constraint(greaterThanOrEqualTo: other,constant:offset)
        const.isActive = true
        return const
    }
}
///These sample methods of layout anchor create an active constraint
extension NSLayoutYAxisAnchor{
    @discardableResult
    func equal(to other:NSLayoutYAxisAnchor,offset:CGFloat?=nil) -> NSLayoutConstraint {
        guard let offset = offset else {
            let const = self.constraint(equalTo: other)
            const.isActive = true
            return const
        }
        let const = self.constraint(equalTo: other,constant:offset);
        const.isActive = true;
        return const;
    }
    @discardableResult
    func less(than other:NSLayoutYAxisAnchor,offset:CGFloat?=nil)-> NSLayoutConstraint{
        guard let offset = offset else {
            let const = self.constraint(lessThanOrEqualTo: other)
            const.isActive = true
            return const
        }
        let const = self.constraint(lessThanOrEqualTo: other,constant:offset);
        const.isActive = true
        return const
    }
    @discardableResult
    func greater(than other:NSLayoutYAxisAnchor,offset:CGFloat?=nil)-> NSLayoutConstraint{
        guard let offset = offset else {
            let const = self.constraint(greaterThanOrEqualTo: other)
            const.isActive = true
            return const
        }
        let const = self.constraint(greaterThanOrEqualTo: other,constant:offset)
        const.isActive = true
        return const
    }
}

extension NSLayoutDimension{
    @discardableResult
    func equal(to constant:CGFloat) -> NSLayoutConstraint {
        let const = self.constraint(equalToConstant: constant)
        const.isActive = true
        return const
    }
    @discardableResult
    func equal(to other:NSLayoutDimension,multiplier:CGFloat? = nil,offset:CGFloat? = nil) -> NSLayoutConstraint {
        switch (multiplier,offset) {
        case (nil,nil):
            let const = self.constraint(equalTo: other)
            const.isActive = true
            return const
        case (let m?,nil):
            let const = self.constraint(equalTo: other, multiplier: m)
            const.isActive = true
            return const
        case (nil,let o?):
            let const = self.constraint(equalTo: other, constant: o)
            const.isActive = true
            return const
        case (let m?,let o?):
            let const = self.constraint(equalTo: other, multiplier: m,constant: o)
            const.isActive = true
            return const
        }
    }
    @discardableResult
    func less(than constant:CGFloat) -> NSLayoutConstraint {
        let const = self.constraint(lessThanOrEqualToConstant: constant)
        const.isActive = true
        return const
    }
    @discardableResult
    func less(than other:NSLayoutDimension,multiplier:CGFloat? = nil,offset:CGFloat? = nil) -> NSLayoutConstraint {
        switch (multiplier,offset) {
        case (nil,nil):
            let const = self.constraint(lessThanOrEqualTo: other)
            const.isActive = true
            return const
        case (let m?,nil):
            let const = self.constraint(lessThanOrEqualTo: other, multiplier: m)
            const.isActive = true
            return const
        case (nil,let o?):
            let const = self.constraint(lessThanOrEqualTo: other, constant: o)
            const.isActive = true
            return const
        case (let m?,let o?):
            let const = self.constraint(lessThanOrEqualTo: other, multiplier: m,constant: o)
            const.isActive = true
            return const
        }
    }
    @discardableResult
    func greater(than constant:CGFloat) -> NSLayoutConstraint {
        let const = self.constraint(greaterThanOrEqualToConstant: constant)
        const.isActive = true
        return const
    }
    @discardableResult
    func greater(than other:NSLayoutDimension,multiplier:CGFloat? = nil,offset:CGFloat? = nil) -> NSLayoutConstraint {
        switch (multiplier,offset) {
        case (nil,nil):
            let const = self.constraint(greaterThanOrEqualTo: other)
            const.isActive = true
            return const
        case (let m?,nil):
            let const = self.constraint(greaterThanOrEqualTo: other, multiplier: m)
            const.isActive = true
            return const
        case (nil,let o?):
            let const = self.constraint(greaterThanOrEqualTo: other, constant: o)
            const.isActive = true
            return const
        case (let m?,let o?):
            let const = self.constraint(greaterThanOrEqualTo: other, multiplier: m,constant: o)
            const.isActive = true
            return const
        }
    }
}

public struct AMXAxisAnchor {
    enum Kind {
        case left
        case right
        case center
    }
    let kind:Kind
    let view:UIView
    @discardableResult
    public func less(than offset:CGFloat)->NSLayoutConstraint{
        guard let su = self.view.superview else {
            fatalError("The superview must exsit!")
        }
        switch self.kind {
        case .left:
            return view.leadingAnchor.less(than: su.leadingAnchor, offset: offset)
        case .right:
            return view.trailingAnchor.less(than: su.trailingAnchor, offset: offset)
        case .center:
            return view.centerXAnchor.less(than: su.centerXAnchor, offset: offset)
        }
    }
    @discardableResult
    public func less(than other:UIView, offset:CGFloat? = nil)->NSLayoutConstraint{
        switch self.kind {
        case .left:
            return self.view.leadingAnchor.less(than: other.leadingAnchor, offset: offset)
        case .right:
            return self.view.trailingAnchor.less(than: other.trailingAnchor,offset: offset)
        case .center:
            return self.view.centerXAnchor.less(than: other.centerXAnchor, offset: offset)
        }
    }
    @discardableResult
    public func less(than other:Self, offset:CGFloat? = nil) -> NSLayoutConstraint{
        switch self.kind {
        case .left:
            let left = self.view.leadingAnchor
            switch other.kind {
            case .left:
                return left.less(than: other.view.leadingAnchor, offset: offset)
            case .right:
                return left.less(than: other.view.trailingAnchor,offset: offset)
            case .center:
                return left.less(than: other.view.centerXAnchor, offset: offset)
            }
        case .right:
            let right = self.view.trailingAnchor
            switch other.kind {
            case .left:
                return right.less(than: other.view.leadingAnchor, offset: offset)
            case .right:
                return right.less(than: other.view.trailingAnchor,offset: offset)
            case .center:
                return right.less(than: other.view.centerXAnchor, offset: offset)
            }
        case .center:
            let center = self.view.centerXAnchor
            switch other.kind {
            case .left:
                return center.less(than: other.view.leadingAnchor, offset: offset)
            case .right:
                return center.less(than: other.view.trailingAnchor,offset: offset)
            case .center:
                return center.less(than: other.view.centerXAnchor, offset: offset)
            }
        }
    }
    @discardableResult
    public func equal(to offset:CGFloat)->NSLayoutConstraint{
        guard let su = self.view.superview else {
            fatalError("The superview must exsit!")
        }
        switch self.kind {
        case .left:
            return view.leadingAnchor.equal(to: su.leadingAnchor, offset: offset)
        case .right:
            return  view.trailingAnchor.equal(to: su.trailingAnchor,offset: offset)
        case .center:
            return view.centerXAnchor.equal(to: su.centerXAnchor, offset: offset)
        }
    }
    @discardableResult
    public func equal(to other:UIView, offset:CGFloat? = nil)->NSLayoutConstraint{
        switch self.kind {
        case .left:
            return self.view.leadingAnchor.equal(to: other.leadingAnchor, offset: offset)
        case .right:
            return self.view.trailingAnchor.equal(to: other.trailingAnchor,offset: offset)
        case .center:
            return self.view.centerXAnchor.equal(to: other.centerXAnchor, offset: offset)
        }
    }
    @discardableResult
    public func equal(to other:Self, offset:CGFloat? = nil)->NSLayoutConstraint{
        switch self.kind {
        case .left:
            let left = self.view.leadingAnchor
            switch other.kind {
            case .left:
                return left.equal(to: other.view.leadingAnchor, offset: offset)
            case .right:
                return left.equal(to: other.view.trailingAnchor,offset: offset)
            case .center:
                return left.equal(to: other.view.centerXAnchor, offset: offset)
            }
        case .right:
            let right = self.view.trailingAnchor
            switch other.kind {
            case .left:
                return right.equal(to: other.view.leadingAnchor, offset: offset)
            case .right:
                return right.equal(to: other.view.trailingAnchor,offset: offset)
            case .center:
                return right.equal(to: other.view.centerXAnchor, offset: offset)
            }
        case .center:
            let center = self.view.centerXAnchor
            switch other.kind {
            case .left:
                return center.equal(to: other.view.leadingAnchor, offset: offset)
            case .right:
                return center.equal(to: other.view.trailingAnchor,offset: offset)
            case .center:
                return center.equal(to: other.view.centerXAnchor, offset: offset)
            }
        }
    }
    @discardableResult
    public func greater(than offset:CGFloat)->NSLayoutConstraint{
        guard let su = self.view.superview else {
            fatalError("The superview must exsit!")
        }
        switch self.kind {
        case .left:
            return view.leadingAnchor.greater(than: su.leadingAnchor, offset: offset)
        case .right:
            return view.trailingAnchor.greater(than: su.trailingAnchor, offset: offset)
        case .center:
            return view.centerXAnchor.greater(than: su.centerXAnchor, offset: offset)
        }
    }
    @discardableResult
    public func greater(than other:UIView, offset:CGFloat? = nil)->NSLayoutConstraint{
        switch self.kind {
        case .left:
            return self.view.leadingAnchor.greater(than: other.leadingAnchor, offset: offset)
        case .right:
            return self.view.trailingAnchor.greater(than: other.trailingAnchor,offset: offset)
        case .center:
            return self.view.centerXAnchor.greater(than: other.centerXAnchor, offset: offset)
        }
    }
    @discardableResult
    public func greater(than other:Self, offset:CGFloat? = nil)->NSLayoutConstraint{
        switch self.kind {
        case .left:
            let left = self.view.leadingAnchor
            switch other.kind {
            case .left:
                return left.greater(than: other.view.leadingAnchor, offset: offset)
            case .right:
                return left.greater(than: other.view.trailingAnchor,offset: offset)
            case .center:
                return left.greater(than: other.view.centerXAnchor, offset: offset)
            }
        case .right:
            let right = self.view.trailingAnchor
            switch other.kind {
            case .left:
                return right.greater(than: other.view.leadingAnchor, offset: offset)
            case .right:
                return right.greater(than: other.view.trailingAnchor,offset: offset)
            case .center:
                return right.greater(than: other.view.centerXAnchor, offset: offset)
            }
        case .center:
            let center = self.view.centerXAnchor
            switch other.kind {
            case .left:
                return center.greater(than: other.view.leadingAnchor, offset: offset)
            case .right:
                return center.greater(than: other.view.trailingAnchor,offset: offset)
            case .center:
                return center.greater(than: other.view.centerXAnchor, offset: offset)
            }
        }
    }
}

public struct AMYAxisAnchor {
    enum Kind {
        case top
        case bottom
        case center
    }
    let kind:Kind
    let view:UIView
    
    @discardableResult
    public func less(than offset:CGFloat)->NSLayoutConstraint{
        guard let su = self.view.superview else {
            fatalError("The superview must exsit!")
        }
        switch self.kind {
        case .top:
            return view.topAnchor.less(than: su.topAnchor, offset: offset)
        case .bottom:
            return view.bottomAnchor.less(than: su.bottomAnchor,offset: offset)
        case .center:
            return view.centerYAnchor.less(than: su.centerYAnchor, offset: offset)
        }
    }
    @discardableResult
    public func less(than other:UIView, offset:CGFloat? = nil)->NSLayoutConstraint{
        switch self.kind {
        case .top:
            return self.view.topAnchor.less(than: other.topAnchor, offset: offset)
        case .bottom:
            return self.view.bottomAnchor.less(than: other.bottomAnchor,offset: offset)
        case .center:
            return self.view.centerYAnchor.less(than: other.centerYAnchor, offset: offset)
        }
    }
    @discardableResult
    public func less(than other:Self, offset:CGFloat? = nil)->NSLayoutConstraint{
        switch self.kind {
        case .top:
            let top = self.view.topAnchor
            switch other.kind {
            case .top:
                return top.less(than: other.view.topAnchor, offset: offset)
            case .bottom:
                return top.less(than: other.view.bottomAnchor,offset: offset)
            case .center:
                return top.less(than: other.view.centerYAnchor, offset: offset)
            }
        case .bottom:
            let bottom = self.view.bottomAnchor
            switch other.kind {
            case .top:
                return bottom.less(than: other.view.topAnchor, offset: offset)
            case .bottom:
                return bottom.less(than: other.view.bottomAnchor,offset: offset)
            case .center:
                return  bottom.less(than: other.view.centerYAnchor, offset: offset)
            }
        case .center:
            let center = self.view.centerYAnchor
            switch other.kind {
            case .top:
                return center.less(than: other.view.topAnchor, offset: offset)
            case .bottom:
                return center.less(than: other.view.bottomAnchor,offset: offset)
            case .center:
                return center.less(than: other.view.centerYAnchor, offset: offset)
            }
        }
    }
    
    @discardableResult
    public func equal(to offset:CGFloat)->NSLayoutConstraint{
        guard let su = self.view.superview else {
            fatalError("The superview must exsit!")
        }
        switch self.kind {
        case .top:
            return view.topAnchor.equal(to: su.topAnchor, offset: offset)
        case .bottom:
            return view.bottomAnchor.equal(to: su.bottomAnchor,offset: offset)
        case .center:
            return view.centerYAnchor.equal(to: su.centerYAnchor, offset: offset)
        }
    }
    @discardableResult
    public func equal(to other:UIView, offset:CGFloat? = nil)->NSLayoutConstraint{
        switch self.kind {
        case .top:
            return self.view.topAnchor.equal(to: other.topAnchor, offset: offset)
        case .bottom:
            return  self.view.bottomAnchor.equal(to: other.bottomAnchor,offset: offset)
        case .center:
            return self.view.centerYAnchor.equal(to: other.centerYAnchor, offset: offset)
        }
    }
    @discardableResult
    public func equal(to other:Self, offset:CGFloat? = nil)->NSLayoutConstraint{
        switch self.kind {
        case .top:
            let top = self.view.topAnchor
            switch other.kind {
            case .top:
                return top.equal(to: other.view.topAnchor, offset: offset)
            case .bottom:
                return top.equal(to: other.view.bottomAnchor,offset: offset)
            case .center:
                return top.equal(to: other.view.centerYAnchor, offset: offset)
            }
        case .bottom:
            let bottom = self.view.bottomAnchor
            switch other.kind {
            case .top:
                return bottom.equal(to: other.view.topAnchor, offset: offset)
            case .bottom:
                return  bottom.equal(to: other.view.bottomAnchor,offset: offset)
            case .center:
                return  bottom.equal(to: other.view.centerYAnchor, offset: offset)
            }
        case .center:
            let center = self.view.centerYAnchor
            switch other.kind {
            case .top:
                return center.equal(to: other.view.topAnchor, offset: offset)
            case .bottom:
                return center.equal(to: other.view.bottomAnchor,offset: offset)
            case .center:
                return center.equal(to: other.view.centerYAnchor, offset: offset)
            }
        }
    }
    
    @discardableResult
    public func greater(than offset:CGFloat)->NSLayoutConstraint{
        guard let su = self.view.superview else {
            fatalError("The superview must exsit!")
        }
        switch self.kind {
        case .top:
            return view.topAnchor.greater(than: su.topAnchor, offset: offset)
        case .bottom:
            return view.bottomAnchor.greater(than: su.bottomAnchor,offset: offset)
        case .center:
            return view.centerYAnchor.greater(than: su.centerYAnchor, offset: offset)
        }
    }
    @discardableResult
    public func greater(than other:UIView, offset:CGFloat? = nil)->NSLayoutConstraint{
        switch self.kind {
        case .top:
            return self.view.topAnchor.greater(than: other.topAnchor, offset: offset)
        case .bottom:
            return self.view.bottomAnchor.greater(than: other.bottomAnchor,offset: offset)
        case .center:
            return self.view.centerYAnchor.greater(than: other.centerYAnchor, offset: offset)
        }
    }
    public func greater(than other:Self, offset:CGFloat? = nil)->NSLayoutConstraint{
        switch self.kind {
        case .top:
            let top = self.view.topAnchor
            switch other.kind {
            case .top:
                return top.greater(than: other.view.topAnchor, offset: offset)
            case .bottom:
                return top.greater(than: other.view.bottomAnchor,offset: offset)
            case .center:
                return top.greater(than: other.view.centerYAnchor, offset: offset)
            }
        case .bottom:
            let bottom = self.view.bottomAnchor
            switch other.kind {
            case .top:
                return bottom.greater(than: other.view.topAnchor, offset: offset)
            case .bottom:
                return bottom.greater(than: other.view.bottomAnchor,offset: offset)
            case .center:
                return bottom.greater(than: other.view.centerYAnchor, offset: offset)
            }
        case .center:
            let center = self.view.centerYAnchor
            switch other.kind {
            case .top:
                return center.greater(than: other.view.topAnchor, offset: offset)
            case .bottom:
                return center.greater(than: other.view.bottomAnchor,offset: offset)
            case .center:
                return center.greater(than: other.view.centerYAnchor, offset: offset)
            }
        }
    }
}
public struct AMDimensionAnchor {
    enum Kind {
        case width
        case height
    }
    let kind:Kind
    let view:UIView
    
    @discardableResult
    public func less(than offset:CGFloat)->NSLayoutConstraint{
        switch self.kind {
        case .width:
            return view.widthAnchor.less(than: offset)
        case .height:
            return view.heightAnchor.less(than: offset)
        }
    }
    @discardableResult
    public func less(than other:UIView, offset:CGFloat? = nil)->NSLayoutConstraint{
        switch (self.kind) {
        case .width:
            return view.widthAnchor.less(than: other.widthAnchor,offset: offset)
        case .height:
            return view.heightAnchor.less(than: other.heightAnchor,offset: offset)
        }
    }
    @discardableResult
    public func less(than other:Self, offset:CGFloat? = nil)->NSLayoutConstraint{
        switch (self.kind,other.kind) {
        case (.width,.width):
            return view.widthAnchor.less(than: other.view.widthAnchor,offset: offset)
        case (.width,.height):
            return view.widthAnchor.less(than: other.view.heightAnchor,offset: offset)
        case (.height,.width):
            return view.heightAnchor.less(than: other.view.widthAnchor,offset: offset)
        case (.height,.height):
            return view.heightAnchor.less(than: other.view.heightAnchor,offset: offset)
        }
    }
    @discardableResult
    public func equal(to offset:CGFloat)->NSLayoutConstraint{
        switch self.kind {
        case .width:
            return view.widthAnchor.equal(to: offset)
        case .height:
            return view.heightAnchor.equal(to: offset)
        }
    }
    @discardableResult
    public func equal(to other:UIView, offset:CGFloat? = nil)->NSLayoutConstraint{
        switch self.kind {
        case .width:
            return view.widthAnchor.equal(to: other.widthAnchor,offset: offset)
        case .height:
            return view.heightAnchor.equal(to: other.heightAnchor,offset: offset)
        }
    }
    @discardableResult
    public func equal(to other:Self, offset:CGFloat? = nil)->NSLayoutConstraint{
        switch (self.kind,other.kind) {
        case (.width,.width):
            return view.widthAnchor.equal(to: other.view.widthAnchor,offset: offset)
        case (.width,.height):
            return view.widthAnchor.equal(to: other.view.heightAnchor,offset: offset)
        case (.height,.width):
            return view.heightAnchor.equal(to: other.view.widthAnchor,offset: offset)
        case (.height,.height):
            return view.heightAnchor.equal(to: other.view.heightAnchor,offset: offset)
        }
    }
    
    @discardableResult
    public func greater(than offset:CGFloat)->NSLayoutConstraint{
        switch self.kind {
        case .width:
            return view.widthAnchor.greater(than: offset)
        case .height:
            return view.heightAnchor.greater(than: offset)
        }
    }
    @discardableResult
    public func greater(than other:UIView, offset:CGFloat? = nil)->NSLayoutConstraint{
        switch self.kind {
        case .width:
            return view.widthAnchor.greater(than: other.widthAnchor,offset: offset)
        case .height:
            return view.heightAnchor.greater(than: other.heightAnchor,offset: offset)
        }
    }
    @discardableResult
    public func greater(than other:Self, offset:CGFloat? = nil)->NSLayoutConstraint{
        switch (self.kind,other.kind) {
        case (.width,.width):
            return view.widthAnchor.greater(than: other.view.widthAnchor,offset: offset)
        case (.width,.height):
            return view.widthAnchor.greater(than: other.view.heightAnchor,offset: offset)
        case (.height,.width):
            return view.heightAnchor.greater(than: other.view.widthAnchor,offset: offset)
        case (.height,.height):
            return view.heightAnchor.greater(than: other.view.heightAnchor,offset: offset)
        }
    }
}
public struct AMCenterAnchor {
    private let maker:AMAnchorMaker
    public typealias Constraint = (x:NSLayoutConstraint,y:NSLayoutConstraint)
    init(view:UIView) {
        self.maker = AMAnchorMaker(view)
    }
    @discardableResult
    public func equal(to:CGFloat)->Constraint {
        return (maker.centerX.equal(to: to),maker.centerY.equal(to: to))
    }
    @discardableResult
    public func equal(to:(x:CGFloat,y:CGFloat))->Constraint {
        return (maker.centerX.equal(to: to.x),maker.centerY.equal(to: to.y))
    }
    @discardableResult
    public func equal(to:UIView,offset:CGFloat?=nil)->Constraint {
        return self.equal(to: to.am.center, offset: offset)
    }
    @discardableResult
    public func equal(to:UIView,offset:(x:CGFloat,y:CGFloat))->Constraint {
        return self.equal(to: to.am.center, offset: offset)
    }
    @discardableResult
    public func equal(to:AMCenterAnchor,offset:CGFloat?=nil)->Constraint {
        return (
            maker.centerX.equal(to: to.maker.centerX,offset: offset),
            maker.centerY.equal(to: to.maker.centerY,offset: offset))
    }
    @discardableResult
    public func equal(to:AMCenterAnchor,offset:(x:CGFloat,y:CGFloat))->Constraint {
        return (
            maker.centerX.equal(to: to.maker.centerX,offset: offset.x),
            maker.centerY.equal(to: to.maker.centerY,offset: offset.y))
    }
}
public struct AMEdgeAnchor {
    public typealias Constraint = (
        top:NSLayoutConstraint?,
        left:NSLayoutConstraint?,
        bottom:NSLayoutConstraint?,
        right:NSLayoutConstraint?)
    public typealias ConstConstraint = (
        top:NSLayoutConstraint,
        left:NSLayoutConstraint,
        bottom:NSLayoutConstraint,
        right:NSLayoutConstraint)
    private let maker:AMAnchorMaker
    init(view:UIView) {
        self.maker = AMAnchorMaker(view)
    }
    
    /// Add edge offset constraint
    ///
    ///- Parameters:
    ///     - to: superview or brotherview or superview.am.edege or  brotherview.am.edge
    ///     - insets: top = left = -bottom = -right = insets
    @discardableResult
    public func equal(insets:CGFloat)->ConstConstraint {
        let top = maker.top.equal(to: insets)
        let left = maker.left.equal(to: insets)
        let right = maker.right.equal(to: -insets)
        let bottom = maker.bottom.equal(to: -insets)
        return (top,left,bottom,right)
    }
    @discardableResult
    public func equal(to:UIView,insets:CGFloat)->ConstConstraint {
        return self.equal(to: to.am.edge, insets: insets)
    }
    @discardableResult
    public func equal(to:AMEdgeAnchor,insets:CGFloat)->ConstConstraint {
        let top = maker.top.equal(to: to.maker.top,offset: insets)
        let left = maker.left.equal(to: to.maker.left,offset: insets)
        let right = maker.right.equal(to: to.maker.right,offset: -insets)
        let bottom = maker.bottom.equal(to: to.maker.bottom,offset: -insets)
        return (top,left,bottom,right)
    }
    
    
    /// Add edge offset constraint
    ///
    ///- Parameters:
    ///     - to: superview or brotherview or superview.am.edege or  brotherview.am.edge
    ///     - offset: top=left=bottom=right=offset
    @discardableResult
    public func equal(to offset:CGFloat)->ConstConstraint {
        let top = maker.top.equal(to: offset)
        let left = maker.left.equal(to: offset)
        let right = maker.right.equal(to: offset)
        let bottom = maker.bottom.equal(to: offset)
        return (top,left,bottom,right)
    }
    @discardableResult
    public func equal(to:UIView,offset:CGFloat?=nil)->ConstConstraint {
        return self.equal(to: to.am.edge, offset: offset)
    }
    @discardableResult
    public func equal(to:AMEdgeAnchor,offset:CGFloat?=nil)->ConstConstraint {
        let top = maker.top.equal(to: to.maker.top,offset: offset)
        let left = maker.left.equal(to: to.maker.left,offset: offset)
        let right = maker.right.equal(to: to.maker.right,offset: offset)
        let bottom = maker.bottom.equal(to: to.maker.bottom,offset: offset)
        return (top,left,bottom,right)
    }
    
    /// Add edge offset constraint
    ///
    ///- Parameters:
    ///     - to: superview or brotherview or superview.am.edege or  brotherview.am.edge
    ///     - top: top offset . `nil` means not add constraint.
    ///     - left: top offset . `nil` means not add constraint.
    ///     - bottom: top offset . `nil` means not add constraint.
    ///     - right: top offset . `nil` means not add constraint.
    @discardableResult
    public func equal(
        top:CGFloat?=nil,
        left:CGFloat?=nil,
        bottom:CGFloat?=nil,
        right:CGFloat?=nil)->Constraint {
        var leftC:NSLayoutConstraint? = nil
        if let v = left {
            leftC = maker.left.equal(to: v)
        }
        var rightC:NSLayoutConstraint? = nil
        if let v = right {
            rightC = maker.right.equal(to: v)
        }
        var topC:NSLayoutConstraint? = nil
        if let v = top {
            topC = maker.top.equal(to: v)
        }
        var bottomC:NSLayoutConstraint? = nil
        if let v = bottom {
            bottomC = maker.bottom.equal(to: v)
        }
        return (topC,leftC,bottomC,rightC)
    }
    @discardableResult
    public func equal(
        to:UIView,
        top:CGFloat?=nil,
        left:CGFloat?=nil,
        bottom:CGFloat?=nil,
        right:CGFloat?=nil)->Constraint {
        return self.equal(to: to.am.edge,top: top,left: left,bottom: bottom,right: right)
    }
    @discardableResult
    public func equal(
        to:AMEdgeAnchor,
        top:CGFloat?=nil,
        left:CGFloat?=nil,
        bottom:CGFloat?=nil,
        right:CGFloat?=nil)->Constraint {
        var leftC:NSLayoutConstraint? = nil
        if let v = left {
            leftC = maker.left.equal(to: to.maker.left,offset: v)
        }
        var rightC:NSLayoutConstraint? = nil
        if let v = right {
            rightC = maker.right.equal(to: to.maker.right,offset: v)
        }
        var topC:NSLayoutConstraint? = nil
        if let v = top {
            topC = maker.top.equal(to: to.maker.top,offset: v)
        }
        var bottomC:NSLayoutConstraint? = nil
        if let v = bottom {
            bottomC = maker.bottom.equal(to: to.maker.bottom,offset: v)
        }
        return (topC,leftC,bottomC,rightC)
    }
}
public struct AMSizeAnchor {
    public typealias Constraint = (width:NSLayoutConstraint,height:NSLayoutConstraint)
    private let maker:AMAnchorMaker
    init(view:UIView) {
        self.maker = AMAnchorMaker(view)
    }
    @discardableResult
    public func equal(to:CGFloat)->Constraint {
        return (maker.width.equal(to: to),maker.height.equal(to: to))
    }
    @discardableResult
    public func equal(to:(width:CGFloat,height:CGFloat))->Constraint {
        return (maker.width.equal(to: to.width),maker.height.equal(to: to.height))
    }
    @discardableResult
    public func equal(to:UIView,offset:CGFloat?=nil)->Constraint {
        return self.equal(to: to.am.size, offset: offset)
    }
    @discardableResult
    public func equal(
        to:UIView,
        offset:(width:CGFloat,height:CGFloat))->Constraint {
        return self.equal(to: to.am.size, offset: offset)
    }
    @discardableResult
    public func equal(to:AMSizeAnchor,offset:CGFloat?=nil)->Constraint {
        return (maker.width.equal(to: to.maker.width,offset: offset),
            maker.height.equal(to: to.maker.height,offset: offset))
    }
    @discardableResult
    public func equal(to:AMSizeAnchor,offset:(width:CGFloat,height:CGFloat))->Constraint {
        return (maker.width.equal(to: to.maker.width,offset: offset.width),
                maker.height.equal(to: to.maker.height,offset: offset.height))
    }
}

public struct AMAnchorMaker {
    private let view:UIView
    init(_ view:UIView) {
        self.view = view
    }
    public var left:AMXAxisAnchor{
        return AMXAxisAnchor(kind:.left,view:self.view)
    }
    public var right:AMXAxisAnchor{
        return AMXAxisAnchor(kind:.right,view:self.view)
    }
    public var centerX:AMXAxisAnchor{
        return AMXAxisAnchor(kind:.center,view:self.view)
    }
    public var top:AMYAxisAnchor{
        return AMYAxisAnchor(kind:.top,view:self.view)
    }
    public var bottom:AMYAxisAnchor{
        return AMYAxisAnchor(kind:.bottom,view:self.view)
    }
    public var centerY:AMYAxisAnchor{
        return AMYAxisAnchor(kind:.center,view:self.view)
    }
    public var width:AMDimensionAnchor{
        return AMDimensionAnchor(kind: .width, view: self.view)
    }
    public var height:AMDimensionAnchor{
        return AMDimensionAnchor(kind: .height, view: self.view)
    }
    public var edge:AMEdgeAnchor{
        return AMEdgeAnchor(view: self.view)
    }
    public var size:AMSizeAnchor{
        return AMSizeAnchor(view: self.view)
    }
    public var center:AMCenterAnchor{
        return AMCenterAnchor(view: self.view)
    }
}
extension UIView{
    public var am:AMAnchorMaker{
        self.translatesAutoresizingMaskIntoConstraints = false
        return AMAnchorMaker(self)
    }
    /// build constraints fastly
    public func amake(builder:(AMAnchorMaker)->Void) {
        builder(am)
    }
    /// rebuild constraints
    public func remake(builder:(AMAnchorMaker)->Void) {
        self.superview?.constraints.forEach({ layout in
            if NSStringFromClass(type(of: layout)) == "NSLayoutConstraint",
               (layout.firstItem as? UIView) == self {
                layout.isActive = false
            }
        })
        self.constraints.forEach({ layout in
            if NSStringFromClass(type(of: layout)) == "NSLayoutConstraint",
               (layout.firstItem as? UIView) == self {
                layout.isActive = false
            }
        })
        builder(am)
    }
}


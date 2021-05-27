//
//  AMAutoLayout.swift
//  Airmey
//
//  Created by supertext on 2020/7/21.
//  Copyright © 2020年 channeljin. All rights reserved.
//

import UIKit

///These sample methods of layout anchor create an active constraint
extension NSLayoutXAxisAnchor
{
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
extension NSLayoutYAxisAnchor
{
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

extension NSLayoutDimension
{
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

public struct XAxisAnchor {
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
            return view.leftAnchor.less(than: su.leftAnchor, offset: offset)
        case .right:
            return view.rightAnchor.less(than: su.rightAnchor, offset: offset)
        case .center:
            return view.centerXAnchor.less(than: su.centerXAnchor, offset: offset)
        }
    }
    @discardableResult
    public func less(than other:Self, offset:CGFloat? = nil) -> NSLayoutConstraint{
        switch self.kind {
        case .left:
            let left = self.view.leftAnchor
            switch other.kind {
            case .left:
                return left.less(than: other.view.leftAnchor, offset: offset)
            case .right:
                return left.less(than: other.view.rightAnchor,offset: offset)
            case .center:
                return left.less(than: other.view.centerXAnchor, offset: offset)
            }
        case .right:
            let right = self.view.leftAnchor
            switch other.kind {
            case .left:
                return right.less(than: other.view.leftAnchor, offset: offset)
            case .right:
                return right.less(than: other.view.rightAnchor,offset: offset)
            case .center:
                return right.less(than: other.view.centerXAnchor, offset: offset)
            }
        case .center:
            let center = self.view.centerXAnchor
            switch other.kind {
            case .left:
                return center.less(than: other.view.leftAnchor, offset: offset)
            case .right:
                return center.less(than: other.view.rightAnchor,offset: offset)
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
            return view.leftAnchor.equal(to: su.leftAnchor, offset: offset)
        case .right:
            return  view.rightAnchor.equal(to: su.rightAnchor,offset: offset)
        case .center:
            return view.centerXAnchor.equal(to: su.centerXAnchor, offset: offset)
        }
    }
    @discardableResult
    public func equal(to other:Self, offset:CGFloat? = nil)->NSLayoutConstraint{
        switch self.kind {
        case .left:
            let left = self.view.leftAnchor
            switch other.kind {
            case .left:
                return left.equal(to: other.view.leftAnchor, offset: offset)
            case .right:
                return left.equal(to: other.view.rightAnchor,offset: offset)
            case .center:
                return left.equal(to: other.view.centerXAnchor, offset: offset)
            }
        case .right:
            let right = self.view.leftAnchor
            switch other.kind {
            case .left:
                return right.equal(to: other.view.leftAnchor, offset: offset)
            case .right:
                return right.equal(to: other.view.rightAnchor,offset: offset)
            case .center:
                return right.equal(to: other.view.centerXAnchor, offset: offset)
            }
        case .center:
            let center = self.view.centerXAnchor
            switch other.kind {
            case .left:
                return center.equal(to: other.view.leftAnchor, offset: offset)
            case .right:
                return center.equal(to: other.view.rightAnchor,offset: offset)
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
            return view.leftAnchor.greater(than: su.leftAnchor, offset: offset)
        case .right:
            return view.rightAnchor.greater(than: su.rightAnchor, offset: offset)
        case .center:
            return view.centerXAnchor.greater(than: su.centerXAnchor, offset: offset)
        }
    }
    @discardableResult
    public func greater(than other:Self, offset:CGFloat? = nil)->NSLayoutConstraint{
        switch self.kind {
        case .left:
            let left = self.view.leftAnchor
            switch other.kind {
            case .left:
                return left.greater(than: other.view.leftAnchor, offset: offset)
            case .right:
                return left.greater(than: other.view.rightAnchor,offset: offset)
            case .center:
                return left.greater(than: other.view.centerXAnchor, offset: offset)
            }
        case .right:
            let right = self.view.leftAnchor
            switch other.kind {
            case .left:
                return right.greater(than: other.view.leftAnchor, offset: offset)
            case .right:
                return right.greater(than: other.view.rightAnchor,offset: offset)
            case .center:
                return right.greater(than: other.view.centerXAnchor, offset: offset)
            }
        case .center:
            let center = self.view.centerXAnchor
            switch other.kind {
            case .left:
                return center.greater(than: other.view.leftAnchor, offset: offset)
            case .right:
                return center.greater(than: other.view.rightAnchor,offset: offset)
            case .center:
                return center.greater(than: other.view.centerXAnchor, offset: offset)
            }
        }
    }
}

public struct YAxisAnchor {
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
public struct DimensionAnchor {
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
public struct CenterAnchor {
    private let maker:AnchorMaker
    public typealias Constraint = (x:NSLayoutConstraint,y:NSLayoutConstraint)
    init(view:UIView) {
        self.maker = AnchorMaker(view)
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
    public func equal(to:CenterAnchor)->Constraint {
        return (maker.centerX.equal(to: to.maker.centerX),maker.centerY.equal(to: to.maker.centerY))
    }
}
public struct EdgeAnchor {
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
    private let maker:AnchorMaker
    init(view:UIView) {
        self.maker = AnchorMaker(view)
    }
    @discardableResult
    public func equal(to:CGFloat)->ConstConstraint {
        let left = maker.left.equal(to: to)
        let right = maker.right.equal(to: to)
        let top =   maker.top.equal(to: to)
        let bottom = maker.bottom.equal(to: to)
        return (top,left,bottom,right)
    }
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
    ///
    /// Make edge inset constraint
    ///
    ///     self.am.edge.equal(to:other.am.edege)
    ///     self.am.edge.equal(to:other.am.edege,10)
    ///
    ///
    @discardableResult public func equal(to:EdgeAnchor,offset:CGFloat?=nil)->ConstConstraint {
        let left = maker.left.equal(to: to.maker.left,offset: offset)
        let right = maker.right.equal(to: to.maker.right,offset: offset)
        let top = maker.top.equal(to: to.maker.top,offset: offset)
        let bottom = maker.bottom.equal(to: to.maker.bottom,offset: offset)
        return (top,left,bottom,right)
    }
    ///
    /// Make edge inset constraint
    ///
    ///     self.am.edge.equal(to:other.am.edege,(10,10,nil,10))
    ///
    @discardableResult public func equal(
        to:EdgeAnchor,
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
public struct SizeAnchor {
    public typealias Constraint = (width:NSLayoutConstraint,height:NSLayoutConstraint)
    private let maker:AnchorMaker
    init(view:UIView) {
        self.maker = AnchorMaker(view)
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
    public func equal(to:SizeAnchor,offset:CGFloat?=nil)->Constraint {
        return (maker.width.equal(to: to.maker.width,offset: offset),
            maker.height.equal(to: to.maker.height,offset: offset))
    }
    @discardableResult
    public func equal(to:SizeAnchor,offset:(width:CGFloat,height:CGFloat))->Constraint {
        return (maker.width.equal(to: to.maker.width,offset: offset.width),
                maker.height.equal(to: to.maker.height,offset: offset.height))
    }
}

public struct AnchorMaker {
    private let view:UIView
    init(_ view:UIView) {
        self.view = view
    }
    public var left:XAxisAnchor{
        return XAxisAnchor(kind:.left,view:self.view)
    }
    public var right:XAxisAnchor{
        return XAxisAnchor(kind:.right,view:self.view)
    }
    public var centerX:XAxisAnchor{
        return XAxisAnchor(kind:.center,view:self.view)
    }
    public var top:YAxisAnchor{
        return YAxisAnchor(kind:.top,view:self.view)
    }
    public var bottom:YAxisAnchor{
        return YAxisAnchor(kind:.bottom,view:self.view)
    }
    public var centerY:YAxisAnchor{
        return YAxisAnchor(kind:.center,view:self.view)
    }
    public var width:DimensionAnchor{
        return DimensionAnchor(kind: .width, view: self.view)
    }
    public var height:DimensionAnchor{
        return DimensionAnchor(kind: .height, view: self.view)
    }
    public var edge:EdgeAnchor{
        return EdgeAnchor(view: self.view)
    }
    public var size:SizeAnchor{
        return SizeAnchor(view: self.view)
    }
    public var center:CenterAnchor{
        return CenterAnchor(view: self.view)
    }
}
extension UIView{
    public var am:AnchorMaker{
        self.translatesAutoresizingMaskIntoConstraints = false
        return AnchorMaker(self)
    }
    public func amake(builder:(AnchorMaker)->Void) {
        builder(am)
    }
    public func amake(
        _ t1:UIView,
        builder:(AnchorMaker,AnchorMaker)->Void) {
        builder(am,t1.am)
    }
    public func amake(
        _ t1:UIView,
        _ t2:UIView,
        builder:(AnchorMaker,AnchorMaker,AnchorMaker)->Void) {
        builder(am,t1.am,t2.am)
    }
    public func amake(
        _ t1:UIView,
        _ t2:UIView,
        _ t3:UIView,
        builder:(AnchorMaker,AnchorMaker,AnchorMaker,AnchorMaker)->Void) {
        builder(am,t1.am,t2.am,t3.am)
    }
    public func amake(
        _ t1:UIView,
        _ t2:UIView,
        _ t3:UIView,
        _ t4:UIView,
        builder:(AnchorMaker,AnchorMaker,AnchorMaker,AnchorMaker,AnchorMaker)->Void) {
        builder(am,t1.am,t2.am,t3.am,t4.am)
    }
    public func amake(
        _ t1:UIView,
        _ t2:UIView,
        _ t3:UIView,
        _ t4:UIView,
        _ t5:UIView,
        builder:(AnchorMaker,AnchorMaker,AnchorMaker,AnchorMaker,AnchorMaker,AnchorMaker)->Void) {
        builder(am,t1.am,t2.am,t3.am,t4.am,t5.am)
    }
}


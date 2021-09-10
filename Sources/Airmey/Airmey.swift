//
//  Airmey.swift
//  Airmey
//
//  Created by supertext on 2020/7/6.
//  Copyright © 2020年 airmey. All rights reserved.
//

import UIKit

public extension CGFloat{
    /// The screen scle factor
    static let scaleFactor:CGFloat   = {
        minimum(UIScreen.main.bounds.width, UIScreen.main.bounds.height) / 375.0
    }()
    /// The toolbar or tabbar height
    static let tabbarHeight:CGFloat  = 49 + .footerHeight
    /// The navigation bar height
    static let navbarHeight:CGFloat  = 44 + .headerHeight
    /// The screen width
    static var screenWidth:CGFloat { UIScreen.main.bounds.width }
    ///The screen height
    static var screenHeight:CGFloat{ UIScreen.main.bounds.height }
    ///The scree header height. got 44 when iphonex like. otherwise got 20.
    static let headerHeight:CGFloat  = {
        if #available(iOS 13.0, *) {
            if let height =  UIApplication.shared.keyWindow?.windowScene?.statusBarManager?.statusBarFrame.size.height{
                return height
            }
            return AMPhone.isSlim ? 44 : 20
        } else {
            return  UIApplication.shared.statusBarFrame.size.height
        }
    }()
    ///The scree footer height. got 34 when iphonex like. otherwise got 0.
    static let footerHeight:CGFloat  = {
        if (AMPhone.isSlim){
            return 34
        }
        return 0
    }()
    ///The scaled scalar using scaleFactor.
    static func scaled(_ origin:CGFloat) -> CGFloat{
        return origin * .scaleFactor
    }
}
public extension CGRect{
    static let screen = UIScreen.main.bounds
}

infix operator <> : RangeCaliperPrecedence
precedencegroup RangeCaliperPrecedence{
    associativity:none
    lowerThan:RangeFormationPrecedence
}

@inlinable
public func <> <V:Comparable>(l:V,r:ClosedRange<V>) -> V {
    return min(max(l, r.lowerBound), r.upperBound)
}

@inlinable
public func +(l:CGPoint,r:CGPoint)->CGPoint{
    return CGPoint(x: l.x+r.x, y: l.y+r.y);
}

@inlinable
public func *(l:CGPoint,r:CGFloat)->CGPoint{
    return CGPoint(x: l.x*r, y: l.y*r);
}

@inlinable
public func +(l:CGSize,r:CGSize)->CGSize{
    return CGSize(width: l.width+r.width, height: l.height+r.height);
}

@inlinable
public func *(l:CGSize,r:CGFloat)->CGSize{
    return CGSize(width: l.width*r, height: l.height*r);
}
extension String{
    ///
    /// Generate a new string repeat form self
    ///
    /// - Parameter count: The repeat count
    /// - Returns: A new string
    ///
    public func `repeat`(_ count:Int) -> String {
        (0..<count).reduce("") { result, _ in
            "\(result)\(self)"
        }
    }
}
extension Array {
    ///
    /// Remove some element form Array
    ///
    /// - Note: Any value in the set that out of  bounds will be ignore!
    /// - Parameter  indexSet  An set of index.
    /// - Returns: An array of elements that has been removed.
    ///
    public mutating func remove(in indexSet:NSIndexSet) -> [Element] {
        let idxs = indexSet.filter{$0<count}.sorted(by: >)
        var removed:[Element] = []
        for i in idxs {
            removed.append(remove(at: i))
        }
        return removed
    }
}

public extension UIColor{
    /// create a UIColor use hex rgb value.
    ///
    ///     label.textColor = UIColor(0xffffff)
    ///
    convenience init(_ hex:UInt,alpha:CGFloat=1.0) {
        self.init(
            red     : CGFloat((hex & 0xff0000) >> 16)/255.0,
            green   : CGFloat((hex & 0xff00) >> 8)/255.0,
            blue    : CGFloat(hex & 0xff)/255.0,
            alpha   : alpha)
    }
    /// create a UIColor use hex rgb value.
    ///
    ///     label.textColor = .hex(0xffffff)
    ///
    static func hex(_ rgb:UInt,alpha:CGFloat=1.0)->UIColor{
        UIColor(rgb,alpha: alpha)
    }
}

/// All empty closure
public typealias AMBlock = ()->Void
/// Common click closure
public typealias ONClick = (UIView)->Void
/// Common Result closure
public typealias ONResult<D> = (Result<D,Error>)->Void

extension Result{
    ///
    /// Get error from result
    /// Just make our code succinctly
    ///
    ///        let result:Result<Int,Error> = .success(1)
    ///        guard let value = result.value else{
    ///             print(result.error!)//At this time error not nil surely
    ///             retrun
    ///        }
    ///        print(value)//do your success logic
    ///
    public var error:Failure?{
        if case .failure(let err) = self {
            return err
        }
        return nil
    }
    ///
    /// Get success value from result
    /// Just make our code succinctly
    ///
    ///        let result:Result<Int,Error> = .success(1)
    ///        if let error = result.error{
    ///             print(result.error)
    ///             retrun
    ///        }
    ///        print(result.value!)//At this time value not nil surely
    ///
    public var value:Success?{
        if case .success(let value) = self {
            return value
        }
        return nil
    }
}

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
    static let scaleFactor:CGFloat   = .screenWidth / 375.0
    /// The toolbar or tabbar height
    static let tabbarHeight:CGFloat  = 49 + .footerHeight
    /// The navigation bar height
    static let navbarHeight:CGFloat  = 44 + .headerHeight
    /// The screen width
    static let screenWidth:CGFloat   = {
        minimum(CGRect.screen.width, CGRect.screen.height)
    }()
    ///The screen height
    static let screenHeight:CGFloat  = {
        maximum(CGRect.screen.width, CGRect.screen.height)
    }()
    ///The scree header height. got 44 when iphonex like. otherwise got 20.
    static let headerHeight:CGFloat  = {
        if (AMPhone.isSlim){
            return 44
        }
        return 20
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
extension Array {
    public mutating func remove(at indexSet:NSIndexSet) -> () {
        let idxs = indexSet.sorted(by: >)
        for i in idxs {
            self.remove(at: i)
        }
    }
}
public protocol AMTextConvertible {
    var text:String?{get}
}
extension String:AMTextConvertible{
    public var text: String?{
        return self
    }
}
public protocol AMImageConvertible {
    var image:UIImage?{get}
}
extension UIImage:AMImageConvertible{
    public var image: UIImage?{
        return self
    }
}
extension CALayer:AMImageConvertible{
    public var image: UIImage?{
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 3)
        defer {
            UIGraphicsEndImageContext()
        }
        if let context = UIGraphicsGetCurrentContext(){
            self.render(in: context)
            return UIGraphicsGetImageFromCurrentImageContext()
        }
        return nil
    }
}
extension CALayer{
    public struct GradualPoint {
        let color:UIColor
        let location:NSNumber
        let point:CGPoint
        public init(color: UIColor, location: NSNumber, point: CGPoint) {
            self.color = color
            self.location = location
            self.point = point
        }
        /// The start point:(0,y) loc:0 user for horizontal gradual
        @inlinable public static func xmin(_ color:UIColor,y:CGFloat=0)->GradualPoint{
            GradualPoint(color: color, location: 0, point: CGPoint(x: 0, y: y))
        }
        /// The start point:(x,0) loc:0 user for vertical gradual
        @inlinable public static func ymin(_ color:UIColor,x:CGFloat=0)->GradualPoint{
            GradualPoint(color: color, location: 0, point: CGPoint(x: x, y: 0))
        }
        /// The middle point:none loc:location user for middle point
        @inlinable public static func mid(_ color:UIColor,_ location:Float)->GradualPoint{
            assert(location>0&&location<1,"location must between in (0,1)")
            return GradualPoint(color: color, location: NSNumber(value: location), point: .zero)
        }
        /// The end point (1,y) loc:1 user for horizontal gradual
        @inlinable public static func xmax(_ color:UIColor,y:CGFloat=0)->GradualPoint{
            GradualPoint(color: color, location: 1, point: CGPoint(x: 1, y: y))
        }
        /// The end point (x,1) loc:1 user for vertical gradual
        @inlinable public static func ymax(_ color:UIColor,x:CGFloat = 0)->GradualPoint{
            GradualPoint(color: color, location: 1, point: CGPoint(x: x, y: 1))
        }
    }
    /// create gradual color layer
    public static func gradual(_ size:CGSize,points:GradualPoint...)->CALayer?{
        return Self.gradual(size, points: points)
    }
    /// create gradual color layer
    public static func gradual(_ size:CGSize,points:[GradualPoint])->CALayer?{
        guard points.count>=1 else {
            return nil
        }
        let layer = CAGradientLayer()
        layer.bounds = CGRect(origin: .zero, size: size)
        layer.colors = points.map{$0.color.cgColor}
        layer.locations = points.map{$0.location}
        layer.startPoint = points[0].point
        layer.endPoint = points[points.count-1].point
        return layer
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
public extension UIImage{
    static func rect(_ color:UIColor,size:CGSize)->UIImage?{
        UIGraphicsBeginImageContextWithOptions(size, false, 3)
        let context = UIGraphicsGetCurrentContext()
        defer {
            UIGraphicsEndImageContext()
        }
        context?.setFillColor(color.cgColor)
        context?.fill(CGRect(origin: .zero, size: size));
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    static func round(_ color:UIColor,radius:CGFloat)->UIImage?{
        let width = radius*2
        UIGraphicsBeginImageContextWithOptions(CGSize(width:width,height:width), false, 3)
        let context = UIGraphicsGetCurrentContext()
        defer {
            UIGraphicsEndImageContext()
        }
        context?.setFillColor(color.cgColor)
        context?.fillEllipse(in: CGRect(x: 0, y: 0, width: width, height: width))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    static func qrcode(_ string:String,size:CGSize = CGSize(width:200,height:200))->UIImage?{
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
            return nil
        }
        filter.setDefaults()
        filter.setValue(string.data(using: .utf8), forKey: "inputMessage")
        filter.setValue("H", forKey: "inputCorrectionLevel")
        guard let ciimage = filter.outputImage else{
            return nil
        }
        guard let cgimage = CIContext().createCGImage(ciimage, from: ciimage.extent) else{
            return nil
        }
        UIGraphicsBeginImageContextWithOptions(size, false, 3)
        defer {
            UIGraphicsEndImageContext()
        }
        guard let context = UIGraphicsGetCurrentContext() else{
            return nil
        }
        context.interpolationQuality = .none
        context.draw(cgimage, in: context.boundingBoxOfClipPath)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    var qrcode:String?{
        guard let ciimg = CIImage(image: self) else {
            return nil
        }
        guard let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh]) else {
            return nil
        }
        guard let feature = detector.features(in: ciimg).first as? CIQRCodeFeature else{
            return nil
        }
        return feature.messageString
    }
    func resize(scale:CGFloat)->UIImage?{
        UIGraphicsBeginImageContextWithOptions(self.size * (scale <> 0...1), false, self.scale)
        defer {
            UIGraphicsEndImageContext()
        }
        if let context = UIGraphicsGetCurrentContext(){
            self.draw(in: context.boundingBoxOfClipPath)
            return UIGraphicsGetImageFromCurrentImageContext()
        }
        return nil
    }
    static func base64(_ base64:String?)->UIImage?{
        guard let str = base64 ,
              let url = URL(string: str) ,
              let data = try? Data(contentsOf: url) else {
            return nil
        }
        return UIImage(data: data)
    }
    static func gradual(_ size:CGSize,points:CALayer.GradualPoint...)->UIImage?{
        return CALayer.gradual(size, points: points)?.image
    }
    static func gradual(_ size:CGSize,points:[CALayer.GradualPoint])->UIImage?{
        return CALayer.gradual(size, points: points)?.image
    }
}










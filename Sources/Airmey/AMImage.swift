//
//  AMImage.swift
//  Airmey
//
//  Created by supertext on 2020/7/6.
//  Copyright © 2020年 airmey. All rights reserved.
//

import UIKit

extension CALayer{
    ///create a capture image of layer
    public var capture: UIImage?{
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
    ///
    /// create an y directionGradientLayer:
    ///
    ///     let layer  : CALayer = .gradual(.init(width:100,height:100),points:.ymin(.black),.min(.gray),.ymax(.clear))
    ///
    /// create an x directionGradientLayer:
    ///
    ///     let layer : CALayer = .gradual(.init(width:100,height:100),points:.xmin(.black),.min(.gray),.xmax(.clear))

    ///
    ///- Parameters:
    /// - size: The layer size
    /// - points: The layer gradual points
    ///
    public static func gradual(_ size:CGSize,points:GradualPoint...)->CALayer{
        return Self.gradual(size, points: points)
    }
    /// create gradual color layer
    ///
    /// create an y directionGradientLayer:
    ///
    ///     let layer  : CALayer = .gradual(.init(width:100,height:100),points:.ymin(.black),.min(.gray),.ymax(.clear))
    ///
    /// create an x directionGradientLayer:
    ///
    ///     let layer : CALayer = .gradual(.init(width:100,height:100),points:.xmin(.black),.min(.gray),.xmax(.clear))

    ///
    ///- Parameters:
    /// - size: The layer size
    /// - points: The layer gradual points
    
        public static func gradual(_ size:CGSize,points:[GradualPoint])->CALayer{
        guard points.count>1 else {
            fatalError("point count must be greater than 1")
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

public extension UIImage{
    /// describe the image format from image data
    enum Format:UInt8 {
        case jpeg = 0xff
        case png = 0x89
        case gif = 0x47
        case tif = 0x49
        case bmp = 0x42
        case tiff = 0x4d
        public init?(_ data:Data){
            var c:UInt8 = 0
            data.copyBytes(to: &c, count: 1)
            self.init(rawValue: c)
        }
    }
    /// Different from UIImage.init(data:, scale:) method, this method add gif data support
    static func data(_ data:Data,scale:CGFloat=UIScreen.main.scale)->UIImage?{
        let format = Format(data)
        switch format {
        case .gif:
            guard let source = CGImageSourceCreateWithData(data as NSData, nil) else{
                return nil
            }
            let count = CGImageSourceGetCount(source)
            guard count > 0 else{
                return nil
            }
            var images:[UIImage] = []
            var duration:TimeInterval = 0
            var times:[TimeInterval] = []
            for i in 0..<count{
                guard let cgimg = CGImageSourceCreateImageAtIndex(source, i, nil) else{
                    continue
                }
                guard let dic = CGImageSourceCopyPropertiesAtIndex(source, i, nil) else{
                    continue
                }
                guard let gifdic = (dic as NSDictionary).object(forKey: kCGImagePropertyGIFDictionary) as? NSDictionary else{
                    continue
                }
                images.append(UIImage(cgImage: cgimg, scale: scale, orientation: .up))
                times.append(duration)
                if let dur = gifdic.object(forKey: kCGImagePropertyGIFUnclampedDelayTime) as? TimeInterval{
                    duration = duration + dur
                }else if let dur = gifdic.object(forKey: kCGImagePropertyGIFDelayTime) as? TimeInterval{
                    duration = duration + dur
                }
            }
            return UIImage.animatedImage(with: images, duration: duration)
        case .none:
            return nil
        default:
            return UIImage(data: data, scale: scale)
        }
    }
    /// create single color rectangle image
    /// 
    /// - Parameters:
    ///     - color: shape color
    ///     - scale: image scale
    ///     - radius: cornerRadius of shape default 0
    ///     - border: border width and color default nil
    static func rect(_ color: UIColor, size: CGSize, radius: CGFloat = 0, border: (color:UIColor,width:CGFloat)? = nil) -> UIImage?{
        let layer = CAShapeLayer()
        layer.frame = CGRect(origin: .zero, size: size)
        layer.backgroundColor = color.cgColor
        layer.masksToBounds = true
        layer.cornerRadius = radius
        if let border = border {
            layer.borderWidth = border.width
            layer.borderColor = border.color.cgColor
        }
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        defer {
            UIGraphicsEndImageContext()
        }
        if let context = UIGraphicsGetCurrentContext() {
            layer.render(in: context)
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        return image
    }
    /// create single color circle image
    static func round(_ color:UIColor,radius:CGFloat,scale:CGFloat=UIScreen.main.scale)->UIImage?{
        let width = radius*2
        UIGraphicsBeginImageContextWithOptions(CGSize(width:width,height:width), false, scale)
        let context = UIGraphicsGetCurrentContext()
        defer {
            UIGraphicsEndImageContext()
        }
        context?.setFillColor(color.cgColor)
        context?.fillEllipse(in: CGRect(x: 0, y: 0, width: width, height: width))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    /// create qrcode image from string
    static func qrcode(_ string:String,size:CGSize = CGSize(width:200,height:200),scale:CGFloat=UIScreen.main.scale)->UIImage?{
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
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
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
    /// transform an qrcode image to qrcode string
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
    /// Resize a UIImage
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
    /// decode base64 string to UIImage instance
    static func base64(_ base64:String?)->UIImage?{
        guard let str = base64 ,
              let url = URL(string: str) ,
              let data = try? Data(contentsOf: url) else {
            return nil
        }
        return UIImage(data: data)
    }
    /// create liner gradual cololor image
    ///
    /// create an x direction gradient Image:
    ///
    ///     let layer  : UIImage = .gradual(.init(width:100,height:100),points:.ymin(.black),.min(.gray),.ymax(.clear))
    ///
    /// create an x direction gradient Image:
    ///
    ///     let layer : UIImage = .gradual(.init(width:100,height:100),points:.xmin(.black),.min(.gray),.xmax(.clear))

    ///
    ///- Parameters:
    /// - size: The layer size
    /// - points: The layer gradual points
    ///
    static func gradual(_ size:CGSize,points:CALayer.GradualPoint...)->UIImage?{
        CALayer.gradual(size, points: points).capture
    }
    /// create liner gradual cololor image
    ///
    /// create an x direction gradient Image:
    ///
    ///     let image  : UIImage = .gradual(.init(width:100,height:100),points:.ymin(.black),.min(.gray),.ymax(.clear))
    ///
    /// create an x direction gradient Image:
    ///
    ///     let image : UIImage = .gradual(.init(width:100,height:100),points:.xmin(.black),.min(.gray),.xmax(.clear))

    ///
    ///- Parameters:
    /// - size: The layer size
    /// - points: The layer gradual points
    ///
    static func gradual(_ size:CGSize,points:[CALayer.GradualPoint])->UIImage?{
        CALayer.gradual(size, points: points).capture
    }
}

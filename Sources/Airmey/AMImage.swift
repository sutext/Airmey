//
//  AMImage.swift
//  Airmey
//
//  Created by supertext on 2020/7/6.
//  Copyright © 2020年 channeljin. All rights reserved.
//

import UIKit

public extension UIImage{
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
    static func data(_ data:Data,scale:CGFloat)->UIImage?{
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

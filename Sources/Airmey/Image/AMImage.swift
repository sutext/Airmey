//
//  AMImage.swift
//  Airmey
//
//  Created by supertext on 2020/7/6.
//  Copyright © 2020年 channeljin. All rights reserved.
//

import UIKit


public class AMImage:NSObject{
    public enum Format {
        case png
        case gif
        case jpeg
        case tiff
        case none
    }
    public static func format(of data:Data)->Format{
        var c:UInt8 = 0
        data.copyBytes(to: &c, count: 1)
        switch c {
        case 0xff:
            return .jpeg
        case 0x89:
            return .png
        case 0x47:
            return .gif
        case 0x49,0x4d:
            return .tiff
        default:
            return .none
        }
    }
    public private(set) var value:UIImage
    public private(set) var format:Format
    ///the keyframes images when format == .gif otherwise empty
    public private(set) var images:[CGImage] = []
    ///the ketTimes number when format == .gif otherwise empty
    public private(set) var keyTimes:[NSNumber] = []
    ///the animation duration when format == .gif otherwise empty
    public private(set) var duration:TimeInterval = 0
    ///init with data and scale ,failed when data format error
    public init?(data: Data, scale: CGFloat) {
        let format = AMImage.format(of: data)
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
                self.images.append(cgimg)
                images.append(UIImage(cgImage: cgimg, scale: scale, orientation: .up))
                times.append(duration)
                if let dur = gifdic.object(forKey: kCGImagePropertyGIFUnclampedDelayTime) as? TimeInterval{
                    duration = duration + dur
                }else if let dur = gifdic.object(forKey: kCGImagePropertyGIFDelayTime) as? TimeInterval{
                    duration = duration + dur
                }
            }
            guard let image = UIImage.animatedImage(with: images, duration: duration) else{
                return nil
            }
            self.keyTimes = times.map{NSNumber(value:$0/duration)}
            self.duration = duration
            self.value = image
        case .none:
            return nil
        default:
            guard let image = UIImage(data: data, scale: scale) else{
                return nil
            }
            self.value = image
        }
        self.format = format
    }
}

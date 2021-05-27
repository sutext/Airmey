//
//  AMPhotoConfig.swift
//  Airmey
//
//  Created by supertext on 2020/6/24.
//  Copyright © 2020年 airmey. All rights reserved.
//

import UIKit

public class AMPhotoConfig: NSObject {
    public static let `default` = AMPhotoConfig()
    public var animationDuration:TimeInterval = 0.35
    public var maximumZoomScale:CGFloat = 3
    public var defaultThumbRect:CGRect = CGRect(x: .screenWidth/2-50, y: .screenHeight/2-50, width: 100, height: 100)
    public var imageInsets:UIEdgeInsets = .zero
}

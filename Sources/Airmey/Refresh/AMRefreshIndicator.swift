//  Airmey
//  AMRefreshIndicator.swift
//
//  Created by supertext on 2021/7/6.
//  Copyright © 2020年 airmey. All rights reserved.
//

import UIKit

public protocol AMRefreshIndicator:UIView{
    func update(status:AMRefresh.Status)
    func update(percent:CGFloat)
}
public class LoadingIndicator:UIView,AMRefreshIndicator{
    private let inner = UIActivityIndicatorView(style: .gray)
    public convenience init() {
        self.init(frame:.zero)
        self.addSubview(inner)
        inner.am.edge.equal(to: 0)
    }
    public func update(status: AMRefresh.Status) {
    }
    public func update(percent: CGFloat) {
        inner.transform = CGAffineTransform(rotationAngle: -percent * .pi)
    }
}
public class AMGifIndicator:UIView,AMRefreshIndicator{
    private let inner = UIImageView()
    private let images:[UIImage]
    private let duration:TimeInterval
    public init(_ images:[UIImage] ,duration:TimeInterval? = nil) {
        guard images.count>1 else {
            fatalError("image count must gather than 1")
        }
        self.images = images
        if let dur = duration {
            self.duration = dur
        }else{
            self.duration = Double(images.count) * 0.1
        }
        super.init(frame:.zero)
        self.addSubview(inner)
        inner.image = images.last
        inner.am.edge.equal(to: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public func update(status: AMRefresh.Status) {
        switch status {
        case .idle:
            inner.stopAnimating()
        case .refreshing:
            inner.animationImages = images
            inner.animationDuration = duration
            inner.startAnimating()
        default:
            break
        }
    }
    public func update(percent: CGFloat) {
        let index = Int(CGFloat(images.count - 1)*percent)
        inner.image = images[index]
    }
}

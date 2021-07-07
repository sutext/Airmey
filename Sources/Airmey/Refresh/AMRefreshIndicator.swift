//  Airmey
//  AMRefreshIndicator.swift
//
//  Created by supertext on 2021/7/6.
//  Copyright © 2020年 airmey. All rights reserved.
//

import UIKit

public protocol AMRefreshIndicator:UIView{
    func update(percent:CGFloat)
    func startAnimating()
    func stopAnimating()
}
public class LoadingIndicator:UIView,AMRefreshIndicator{
    private let inner = UIActivityIndicatorView(style: .gray)
    public convenience init() {
        self.init(frame:.zero)
        self.addSubview(inner)
        inner.am.center.equal(to: 0)
    }
    public func update(percent: CGFloat) {
        
    }
    public func startAnimating() {
        inner.startAnimating()
    }
    public func stopAnimating() {
        inner.stopAnimating()
    }
}

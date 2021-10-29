//  Airmey
//  AMRefreshHeader.swift
//
//  Created by supertext on 2020/8/14.
//  Copyright © 2020年 airmey. All rights reserved.
//

import UIKit

/// Builtin Refresh Header
open class AMRefreshHeader: AMRefresh {
    public let loading:Loading
    public init(_ indicator:Loading = Loading(),height:CGFloat?=nil) {
        self.loading = indicator
        super.init(.header,height: height)
        self.addSubview(indicator)
        indicator.am.center.equal(to: 0)
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public override var isEnabled: Bool{
        didSet{
            self.loading.isHidden = !isEnabled
        }
    }
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview != nil {
            self.amake { am in
                am.top.equal(to: -self.height)
                am.centerX.equal(to: 0)
            }
        }
    }
    public override func statusChanged(_ status: AMRefresh.Status,old:Status){
        loading.update(status: status)
        if case .refreshing = status {
            var insets = self.originalInset
            insets.top = self.height+insets.top
            UIView.animate(withDuration: 0.25) {
                self.scorllView?.contentOffset = CGPoint(x: 0, y: -self.height)
                self.scorllView?.contentInset = insets
            }
        }else{
            UIView.animate(withDuration: 0.25) {
                self.scorllView?.contentInset = self.originalInset
            }
        }
    }
    
    public override func contentOffsetChanged() {
        guard let scview = self.scorllView else {
            return
        }
        let offset = scview.contentOffset.y
        let happenOffset = -self.originalInset.top
        if offset > happenOffset {
            return
        }
        var percent = (happenOffset - offset)/self.height
        percent = (percent <> CGFloat(0)...CGFloat(1))
        if scview.isDragging {
            loading.update(percent: percent)
            if self.status == .idle , percent >= 1 {
                self.status = .draging
            }else if self.status == .draging && percent < 1{
                self.status = .idle
            }
        }else if self.status == .draging{
            self.beginRefreshing()
        }
    }
    public override func contentSizeChanged() {
        
    }
    public override func gestureStateChanged() {
        
    }
}

extension AMRefresh{
    open class Loading:UIView{
        private lazy var activity:UIActivityIndicatorView = {
            let view = UIActivityIndicatorView(style: .gray)
            view.hidesWhenStopped = false
            self.addSubview(view)
            view.am.edge.equal(to: 0)
            return view
        }()
        open func update(status: AMRefresh.Status) {
            switch status {
            case .idle:
                activity.stopAnimating()
            case .refreshing:
                activity.startAnimating()
            default:
                break
            }
        }
        open func update(percent: CGFloat) {
            activity.transform = CGAffineTransform(rotationAngle: -percent * .pi)
        }
        public static func gif(_ images:[UIImage],duration:TimeInterval? = nil)->Loading{
            GifLoading(images,duration: duration)
        }
    }
}
extension AMRefresh{
    public class GifLoading:Loading{
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
        public override func update(status: AMRefresh.Status) {
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
        public override func update(percent: CGFloat) {
            let index = Int(CGFloat(images.count - 1)*percent)
            inner.image = images[index]
        }
    }
}


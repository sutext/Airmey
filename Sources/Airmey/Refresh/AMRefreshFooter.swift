//
//  AMRefreshControl.swift
//  Airmey
//
//  Created by supertext on 2020/8/14.
//  Copyright © 2020年 airmey. All rights reserved.
//

import UIKit

/// Builtin Refresh Footer
open class AMRefreshFooter: AMRefresh {
    private var topConstt:NSLayoutConstraint?
    private let stackView = UIStackView()
    /// text when disabled
    public var disabledText:String?
    /// trigger refresh wihtout feeling
    /// recommend value [-1,1]. default value `0`
    public var threshold:CGFloat = 1{
        didSet{
            self.feedback = threshold >= 1
        }
    }
    public let indicator: Loading
    public init(_ indicator:Loading = Loading(), height:CGFloat? = nil) {
        self.indicator = indicator
        super.init(.footer,height: height)
        self.addSubview(self.indicator)
        self.indicator.am.center.equal(to: 0)
    }
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard let scview = self.scorllView else {
            return
        }
        self.amake { am in
            self.topConstt = am.top.equal(to: scview.bounds.height)
            am.centerX.equal(to: 0)
        }
    }
    public override var isEnabled: Bool{
        didSet{
            if !isEnabled {
                self.textLabel.displayText = self.disabledText ?? self.text
                self.indicator.update(status: .idle)
            }
        }
    }
    public override func statusChanged(_ status: AMRefresh.Status, old: AMRefresh.Status) {
        switch status {
        case .idle:
            self.indicator.update(status: .idle)
        case .refreshing:
            self.indicator.update(status: .refreshing)
        default:
            break
        }
        if case .refreshing = status {
            var insets = self.originalInset
            insets.bottom = self.height+insets.bottom
            UIView.animate(withDuration: 0.25) {
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
        let happenedOffset = -self.originalInset.top
        let moveableOffset = scview.contentSize.height - (scview.bounds.height-self.originalInset.bottom-self.originalInset.top)
        guard moveableOffset > 0 ,offset > happenedOffset else {
            return
        }
        let percent = (offset-happenedOffset-moveableOffset)/self.height
        if scview.isDragging {
            if self.status == .idle , percent >= threshold {
                self.status = .draging
            }else if self.status == .draging && percent < threshold{
                self.status = .idle
            }
        }else if self.status == .draging{
            self.beginRefreshing()
        }
    }
    public override func contentSizeChanged() {
        guard let scview = self.scorllView else{
            return
        }
        let boundsHeight = scview.bounds.height-self.originalInset.bottom-self.originalInset.top
//        self.isHidden = (scview.contentSize.height - boundsHeight <= 0)
        self.topConstt?.constant = max(scview.contentSize.height, boundsHeight)
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

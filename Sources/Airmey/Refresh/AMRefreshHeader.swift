//  Airmey
//  AMRefreshHeader.swift
//
//  Created by supertext on 2020/8/14.
//  Copyright © 2020年 airmey. All rights reserved.
//

import UIKit
///
/// Builtin Refresh Header
/// contentInset control the scorllView contentView.frame
/// contentSize and contentOffset never been change by contentInset
///
public class AMRefreshHeader: AMRefresh {
    private let indicator:AMRefreshIndicator
    private var topLayout:NSLayoutConstraint?
    public init(_ indicator:AMRefreshIndicator = LoadingIndicator()) {
        self.indicator = indicator
        super.init(.header)
        self.addSubview(indicator)
        indicator.am.center.equal(to: 0)
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.topLayout = self.am.top.equal(to: 0)
        self.am.left.equal(to: 0)
    }
    public override func statusChanged(_ status: AMRefresh.Status,old:Status) {
        if status == .refreshing {
            indicator.startAnimating()
        }else{
            indicator.stopAnimating()
        }
    }
    public override func contentOffsetChanged() {
        guard let scview = self.scorllView else {
            return
        }
        self.originalInset = scview.contentInset
        let offset = scview.contentOffset.y
        self.topLayout?.constant = offset+self.originalInset.top
        let happenOffset = -self.originalInset.top
        if offset > happenOffset {
            return
        }
        let criticalOffset = happenOffset - self.height
        let percent = (happenOffset - offset)/self.height
        if scview.isDragging {
            self.dragingPercent = percent
            if self.status == .idle , offset < criticalOffset {
                self.status = .draging
            }else if self.status == .draging && offset >= criticalOffset{
                self.status = .idle
            }
        }else if self.status == .draging{
            self.beginRefreshing()
        }else if percent < 1{
            self.dragingPercent = percent
        }
    }
    public override func contentSizeChanged() {
        
    }
    public override func gestureStateChanged() {
        
    }
}


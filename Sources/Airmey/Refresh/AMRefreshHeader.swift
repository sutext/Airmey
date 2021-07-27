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
    public init(_ indicator:AMRefreshIndicator = LoadingIndicator(),height:CGFloat?=nil) {
        self.indicator = indicator
        super.init(.header,height: height)
        self.addSubview(indicator)
        indicator.am.center.equal(to: 0)
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.amake { am in
            am.top.equal(to: -self.height)
            am.centerX.equal(to: 0)
        }
    }
    public override func statusChanged(_ status: AMRefresh.Status,old:Status){
        indicator.update(status: status)
        if case .refreshing = status {
            var insets = self.originalInset
            insets.top = self.height+insets.top
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
        let happenOffset = -self.originalInset.top
        if offset > happenOffset {
            return
        }
        var percent = (happenOffset - offset)/self.height
        percent = (percent <> CGFloat(0)...CGFloat(1))
        if scview.isDragging {
            indicator.update(percent: percent)
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


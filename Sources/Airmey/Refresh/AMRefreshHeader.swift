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
        self.topLayout = self.am.top.equal(to: 0)
        self.am.left.equal(to: 0)
    }
    public override func statusChanged(_ status: AMRefresh.Status,old:Status){
        print("statusChanged:",status,"old:",old)
        indicator.update(status: status)
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
        var percent = (happenOffset - offset)/self.height
        percent = (percent <> CGFloat(0)...CGFloat(1))
        if scview.isDragging {
            self.dragingPercent = percent
            indicator.update(percent: percent)
            if self.status == .idle , percent > 0.3 {
                self.status = .draging
            }else if self.status == .draging && percent == 1{
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


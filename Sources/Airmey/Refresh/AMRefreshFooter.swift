//
//  AMRefreshControl.swift
//  Airmey
//
//  Created by supertext on 2020/8/14.
//  Copyright © 2020年 airmey. All rights reserved.
//

import UIKit

/// Builtin Refresh Footer
/// contentInset control the scorllView contentView.frame
/// contentSize and contentOffset never been change by contentInset
///
public class AMRefreshFooter: AMRefresh {
    private let indicator = UIActivityIndicatorView(style: .gray)
    private var topConstt:NSLayoutConstraint?
    private let stackView = UIStackView()
    public init(height:CGFloat? = nil) {
        super.init(.footer,height: height)
        self.stackView.spacing = 5
        self.stackView.axis = .horizontal
        self.stackView.distribution = .equalCentering
        self.stackView.alignment = .center
        self.addSubview(self.stackView)
        self.stackView.am.center.equal(to: 0)
        self.stackView.addArrangedSubview(self.indicator)
        self.stackView.addArrangedSubview(self.textLabel)
        self.text = "drag to refresh"
        self.setText("relax to refreshing", for: .draging)
        self.setText("refreshing", for: .refreshing)
        self.setText("No more content", for: .noMoreData)
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
    public override func statusChanged(_ status: AMRefresh.Status, old: AMRefresh.Status) {
        switch status {
        case .noMoreData,.idle:
            self.indicator.stopAnimating()
        case .refreshing:
            self.indicator.startAnimating()
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
        guard self.status != .noMoreData else {
            return
        }
        let offset = scview.contentOffset.y
        let happenOffset = -self.originalInset.top
        let elasticHeight = scview.contentSize.height - (scview.bounds.height-self.originalInset.bottom-self.originalInset.top)
        guard elasticHeight > 0 ,offset > happenOffset else {
            return
        }
        var percent = (offset-happenOffset-elasticHeight)/self.height
        percent = (percent <> CGFloat(0)...CGFloat(1))
        if scview.isDragging {
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
        guard let scview = self.scorllView else{
            return
        }
        self.topConstt?.constant = max(scview.contentSize.height, scview.bounds.height-self.originalInset.bottom-self.originalInset.top)
    }
    public func setNoMoreData(){
        self.status = .noMoreData
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

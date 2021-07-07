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
    private let activityIndicator = UIActivityIndicatorView(style: .gray)
    private var topConstt:NSLayoutConstraint?
    public init() {
        super.init(.footer)
        self.addSubview(self.activityIndicator)
        self.activityIndicator.am.center.equal(to: self.am.center)
    }
//    public override var isRefreshing:Bool{
//        didSet{
//            guard oldValue != self.isRefreshing else{
//                return
//            }
//            guard let scview = self.scorllView else {
//                return
//            }
//            self.isUserInteractionEnabled = false
//            if self.isRefreshing {
//                self.activityIndicator.startAnimating()
//                self.textLabel.isHidden = true
//                self.sendActions(for: .valueChanged)
//                UIView.animate(withDuration: 0.25, animations: {
//                    var inset = scview.contentInset
//                    inset.bottom = inset.bottom + 49
//                    scview.contentInset = inset
//                }, completion: { (finished) in
//                    self.isUserInteractionEnabled = true;
//                })
//            }else{
//                self.activityIndicator.stopAnimating()
//                self.textLabel.isHidden = false
//                UIView.animate(withDuration: 0.25, animations: {
//                    var inset = scview.contentInset
//                    inset.bottom = inset.bottom - 49
//                    scview.contentInset = inset
//                }, completion: { (finished) in
//                    self.isUserInteractionEnabled = true
//                })
//            }
//        }
//    }
    private var maxOffset:CGFloat {
        guard let scview = self.scorllView else{
            return 0
        }
        return max(scview.contentSize.height, scview.bounds.height) - scview.bounds.height
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

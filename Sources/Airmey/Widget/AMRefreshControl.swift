//
//  AMRefreshControl.swift
//  Airmey
//
//  Created by supertext on 2020/8/14.
//  Copyright © 2020年 airmey. All rights reserved.
//

import UIKit

/*
 * contentInset control the scorllView contentView.frame
 * contentSize and contentOffset never been change by contentInset
 */
public class AMRefreshControl: UIControl {
    private let textLabel = AMLabel()
    private let activityIndicator = UIActivityIndicatorView(style: .gray)
    private weak var scorllView:UIScrollView?
    private var topConstt:NSLayoutConstraint?
    private var texts:[Bool:String] = [
        true:NSLocalizedString("am_load_more", value: "Load more content",comment: ""),
        false:NSLocalizedString("am_no_more", value: "No more content",comment: ""),
    ]
    public override var isEnabled: Bool{
        didSet {
            guard oldValue != isEnabled else {
                return
            }
            self.textLabel.text = self.texts[isEnabled]
        }
    }
    public var isRefreshing:Bool = false{
        didSet{
            guard oldValue != self.isRefreshing else{
                return
            }
            guard let scview = self.scorllView else {
                return
            }
            self.isUserInteractionEnabled = false
            if self.isRefreshing {
                self.activityIndicator.startAnimating()
                self.textLabel.isHidden = true
                self.sendActions(for: .valueChanged)
                UIView.animate(withDuration: 0.25, animations: {
                    var inset = scview.contentInset
                    inset.bottom = inset.bottom + 49
                    scview.contentInset = inset
                }, completion: { (finished) in
                    self.isUserInteractionEnabled = true;
                })
            }else{
                self.activityIndicator.stopAnimating()
                self.textLabel.isHidden = false
                UIView.animate(withDuration: 0.25, animations: {
                    var inset = scview.contentInset
                    inset.bottom = inset.bottom - 49
                    scview.contentInset = inset
                }, completion: { (finished) in
                    self.isUserInteractionEnabled = true
                })
            }
        }
    }
    private var maxOffset:CGFloat {
        guard let scview = self.scorllView else{
            return 0
        }
        return max(scview.contentSize.height, scview.bounds.height) - scview.bounds.height
    }
    required public init() {
        super.init(frame: .zero)
        self.backgroundColor = .clear
        self.textLabel.font = UIFont.systemFont(ofSize: 15)
        self.textLabel.textAlignment = .center
        self.textLabel.backgroundColor = .clear
        self.textLabel.text = self.texts[true]
        self.addSubview(self.textLabel)
        self.addSubview(self.activityIndicator)
        self.textLabel.am.center.equal(to: self.am.center)
        self.activityIndicator.am.center.equal(to: self.am.center)
    }
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if let scview = self.superview as? UIScrollView{
            self.amake { (am) in
                am.width.equal(to: scview.am.width)
                am.height.equal(to: 49)
                self.topConstt = am.top.equal(to: scview.am.top,offset: max(scview.contentSize.height,scview.frame.height))
            }
            self.scorllView = scview
            scview.addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)
            scview.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        }
    }
    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if newSuperview == nil{
            self.scorllView?.removeObserver(self, forKeyPath: "contentOffset")
            self.scorllView?.removeObserver(self, forKeyPath: "contentSize")
            self.scorllView = nil
        }
    }
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let scview = self.scorllView else { return }
        guard let keyPath = keyPath else { return }
        switch keyPath {
        case "contentOffset":
            guard self.isEnabled else { return }
            if !self.isUserInteractionEnabled  || self.isHidden  || self.isRefreshing || self.alpha <= 0.01{
                return
            }
            let striveOffset = scview.contentOffset.y - self.maxOffset
            if striveOffset < 0 {
                return
            }
            if !scview.isDragging{
                self.isRefreshing = true
            }
        case "contentSize":
            self.topConstt?.constant = max(scview.contentSize.height,scview.frame.height)
        default:
            break
        }
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension AMRefreshControl:AMRefresh{
    public func endRefreshing() {
        self.isRefreshing = false
    }
    public func beginRefreshing() {
        self.isRefreshing = true
    }
    public static var style: AMRefreshStyle {
        return .bottom
    }
}
extension UIRefreshControl:AMRefresh{
    public static var style: AMRefreshStyle {
        return .top
    }
}

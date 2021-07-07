//
//  AMRefresh.swift
//  Airmey
//
//  Created by supertext on 2020/8/14.
//  Copyright © 2020年 airmey. All rights reserved.
//

import UIKit

open class AMRefresh:UIControl{
    public let style:Style
    public let height:CGFloat
    public var isRefreshing:Bool {
        status == .willRefresh || status == .refreshing
    }
    weak var scorllView:UIScrollView?
    let textLabel = UILabel()
    var texts:[Status:String] = [:]
    var fonts:[Status:UIFont] = [:]
    var colors:[Status:UIColor] = [:]
    var dragingPercent:CGFloat = 0
    var originalInset:UIEdgeInsets = .zero
    public init(_ style:Style,height:CGFloat = 49) {
        self.style = style
        self.height = height
        super.init(frame: .zero)
        self.backgroundColor = .clear
        self.textLabel.textAlignment = .center
        self.textLabel.backgroundColor = .clear
        self.addSubview(self.textLabel)
        self.textLabel.am.center.equal(to: self.am.center)
    }
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public internal(set) var status:Status = .idle{
        didSet{
            if status != oldValue {
                self.statusChanged(status,old: oldValue)
            }
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
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard let scview = self.superview as? UIScrollView else{
            return
        }
        self.amake { am in
            am.width.equal(to: scview.am.width)
            am.height.equal(to: self.height)
        }
        self.scorllView = scview
        self.originalInset = scview.contentInset
        scview.alwaysBounceVertical = true
        scview.addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)
        scview.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        scview.panGestureRecognizer.addObserver(self, forKeyPath: "state", options: .new, context: nil)
    }
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" {
            self.contentSizeChanged()
        }
        guard isEnabled else { return }
        guard isUserInteractionEnabled else { return }
        if self.isHidden || self.alpha <= 0.01{
            return
        }
        switch keyPath {
        case "contentOffset":
            self.contentOffsetChanged()
        case "state":
            self.gestureStateChanged()
        default:
            break
        }
    }
    open func statusChanged(_ status:Status,old:Status){
        self.textLabel.text = self.texts[status]
        self.textLabel.font = self.fonts[status]
        self.textLabel.textColor = self.colors[status]
        DispatchQueue.main.async {
            self.setNeedsDisplay()
        }
    }
    open func contentOffsetChanged(){
        
    }
    open func contentSizeChanged(){
        
    }
    open func gestureStateChanged(){
        
    }
    
    public func beginRefreshing(){
        UIView.animate(withDuration: 0.1) {
            self.alpha = 1
        }
        self.dragingPercent = 1
        if self.window != nil {
            self.status = .refreshing
        }else{
            if self.status != .refreshing {
                self.status = .willRefresh
                self.setNeedsDisplay()
            }
        }
    }
    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        if self.status == .willRefresh {
            self.status = .refreshing
        }
    }
    public func endRefreshing(){
        self.status = .idle
    }
}
extension AMRefresh{
    public func text(for status:Status)->String?{
        self.texts[status]
    }
    public func setText(_ text:String,for status:Status){
        self.texts[status] = text
        if status == self.status {
            self.textLabel.text = text
        }
    }
    public func setTexts(_ texts:[Status:String]){
        texts.forEach {
            self.setText($0.value, for: $0.key)
        }
    }
    public func font(for status:Status)->UIFont?{
        self.fonts[status]
    }
    public func setFont(_ font:UIFont,for status:Status){
        self.fonts[status] = font
        if status == self.status {
            self.textLabel.font = font
        }
    }
    public func setFonts(_ fonts:[Status:UIFont]){
        fonts.forEach {
            self.setFont($0.value, for: $0.key)
        }
    }
    public func textColor(for status:Status)->UIColor?{
        self.colors[status]
    }
    
    public func setTextColor(_ color:UIColor,for status:Status){
        self.colors[status] = color
        if status == self.status {
            self.textLabel.textColor = color
        }
    }
    public func setTextColors(_ colors:[Status:UIColor]){
        colors.forEach {
            self.setTextColor($0.value, for: $0.key)
        }
    }
}
extension AMRefresh{
    public enum Style:String{
        case header
        case footer
    }
    public enum Status{
        case idle
        case draging
        case willRefresh
        case refreshing
        case noMoreData
    }
}

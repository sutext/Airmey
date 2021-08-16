//
//  AMRefresh.swift
//  Airmey
//
//  Created by supertext on 2020/8/14.
//  Copyright © 2020年 airmey. All rights reserved.
//

import UIKit

open class AMRefresh:UIControl{
    /// refreshing style
    public let style:Style
    /// refresh control height
    public let height:CGFloat
    /// enable UIImpactFeedback or not. By default `true`
    public var feedback:Bool = true
    private var texts:[Status:String] = [:]
    private var fonts:[Status:UIFont] = [:]
    private var colors:[Status:UIColor] = [:]
    weak var scorllView:UIScrollView?
    var originalInset:UIEdgeInsets = .zero
    public init(_ style:Style,height:CGFloat? = nil) {
        self.style = style
        self.height = height ?? style.defaultHeight
        super.init(frame: .zero)
        self.backgroundColor = .clear
    }
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /// Is refreshing or not at current time
    public var isRefreshing:Bool {
        status == .willRefresh || status == .refreshing
    }
    /// current status
    public internal(set) var status:Status = .idle{
        didSet{
            guard self.isEnabled else {
                return
            }
            if status != oldValue {
                let status = self.status
                self.textLabel.text = self.texts[status] ?? self.text
                self.textLabel.font = self.fonts[status] ?? self.font
                self.textLabel.textColor = self.colors[status] ?? self.textColor
                scorllView?.isUserInteractionEnabled = (status != .refreshing)
                self.statusChanged(status,old: oldValue)
                if case .refreshing = status{
                    self.notifyDelegate()
                }
                self.setNeedsDisplay()
            }
        }
    }
    /// default text label
    public lazy var textLabel:AMLabel = {
        let label = AMLabel()
        label.textAlignment = .center
        label.backgroundColor = .clear
        self.addSubview(label)
        return label
    }()
    /// default text font for any status
    public var font:UIFont?{
        didSet{
            self.textLabel.font = font
        }
    }
    /// default text  for any status
    public var text:String?{
        didSet{
            self.textLabel.text = text
        }
    }
    /// default text color for any status
    public var textColor:UIColor?{
        didSet{
            self.textLabel.textColor = textColor
        }
    }
    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if newSuperview == nil,let scview = self.scorllView{
            scview.removeObserver(self, forKeyPath: "contentOffset")
            scview.removeObserver(self, forKeyPath: "contentSize")
            scview.panGestureRecognizer.removeObserver(self, forKeyPath: "state")
            scview.remove(refresh: style)
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
            DispatchQueue.main.async { self.contentSizeChanged() }
        }
        guard isEnabled else { return }
        guard isUserInteractionEnabled else { return }
        switch keyPath {
        case "contentOffset":
            DispatchQueue.main.async { self.contentOffsetChanged() }
        case "state":
            DispatchQueue.main.async { self.gestureStateChanged() }
        default:
            break
        }
    }
    ///override point for subclass
    open func statusChanged(_ status:Status,old:Status){
        
    }
    ///override point for subclass
    open func contentOffsetChanged(){
        
    }
    ///override point for subclass
    open func contentSizeChanged(){
        
    }
    ///override point for subclass
    open func gestureStateChanged(){
        
    }
    public func endRefreshing(){
        self.status = .idle
    }
    open func beginRefreshing(){
        guard self.isEnabled else {
            return
        }
        if self.window != nil {
            self.status = .refreshing
            return
        }
        if self.status != .refreshing {
            self.status = .willRefresh
        }
    }
    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        if self.status == .willRefresh {
            self.status = .refreshing
        }
    }
    private func notifyDelegate() {
        guard let scview = self.scorllView else {
            return
        }
        guard let delegate  = scview.delegate else {
            return
        }
        if self.feedback {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
        switch delegate {
        case let d as AMScrollViewDelegate:
            d.scrollView(scview, willBegin: self)
        case let d as AMTableViewDelegate:
            if let tableView = self.scorllView as? UITableView {
                d.tableView(tableView, willBegin: self)
            }
        case let d as AMCollectionViewDelegate:
            if let collectionView = self.scorllView as? UICollectionView {
                d.collectionView(collectionView, willBegin: self)
            }
        default:
            break
        }
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
    public enum Style:String,CaseIterable{
        case header
        case footer
        /// default refresher height
        var defaultHeight:CGFloat{
            switch self {
            case .header:
                return 60
            case .footer:
                return 50
            }
        }
        
    }
    public enum Status{
        /// normal status
        case idle
        /// ready to refresh
        case draging
        /// refresh will be happend immediately
        case willRefresh
        /// in refreshing
        case refreshing
    }
}

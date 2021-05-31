//
//  AMLabel.swift
//  Airmey
//
//  Created by supertext on 2020/6/24.
//  Copyright © 2020年 airmey. All rights reserved.
//

import UIKit

open class AMLabel: UILabel {
    private lazy var tapges:UITapGestureRecognizer = {
        let ges = UITapGestureRecognizer(target: self, action: #selector(AMLabel.tapsel))
        ges.numberOfTapsRequired = 1;
        return ges;
    }()
    @objc private func tapsel() {
        self.onclick?(self)
    }
    open var onclick: ((_ sender:AMLabel) -> Swift.Void)?{
        didSet{
            if let _ = self.onclick {
                self.isUserInteractionEnabled = true;
                self.addGestureRecognizer(self.tapges)
            }
            else
            {
                self.isUserInteractionEnabled = false;
                self.removeGestureRecognizer(self.tapges);
            }
        }
    }
    open var textInsets:UIEdgeInsets?
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard let insets = self.textInsets else{
            return super.sizeThatFits(size);
        }
        guard let text = self.text,text.count > 0 else {
            return .zero;
        }
        let superSize = super.sizeThatFits(size);
        return CGSize(width: superSize.width+insets.left+insets.right, height: superSize.height + insets.top+insets.bottom)
    }
    open override func drawText(in rect: CGRect) {
        if let insets = self.textInsets {
            super.drawText(in: self.bounds.inset(by: insets))
        }else{
            super.drawText(in: rect)
        }
    }
    open override var intrinsicContentSize: CGSize{
        guard let insets = self.textInsets else{
            return super.intrinsicContentSize
        }
        guard let text = self.text,text.count > 0 else {
            return .zero;
        }
        let superSize = super.intrinsicContentSize
        return CGSize(width: superSize.width+insets.left+insets.right, height: superSize.height + insets.top+insets.bottom)
    }
}
final public class AMDigitLabel:AMLabel{
    public typealias Formater = (Int)->String
    public static var defaultFormater:Formater = {String($0)}
    private let rate:Double
    private var value:Int = 0
    private var step:Int = 0
    private var total:Int = 0
    private var goal:Int = 0
    private var stack:[Int] = []
    private let timer:AMTimer
    deinit {
        self.timer.stop()
    }
    init(_ frameRate:Double = 30) {
        self.rate = frameRate
        self.timer = AMTimer(interval: 1.0/frameRate)
        self.formater = Self.defaultFormater
        super.init(frame: .zero)
        self.timer.delegate = self
    }
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public var formater:Formater{
        didSet{
            self.text = self.formater(self.goal)
        }
    }
    public var digit:Int{
        get{
            if self.stack.count>0 {
                return self.stack.last ?? 0
            }
            return self.goal
        }
        set{
            self.stack.append(newValue)
            self.next()
        }
    }
    private func next(){
        if (self.step > 0 || self.stack.count == 0) {
            return;
        }
        let goal = self.stack[0]
        self.stack .remove(at: 0)
        if (self.goal == goal) {
            self.next()
            return
        }
        self.goal = goal;
        if (self.value == 0 || self.value>=self.goal) {
            self.setText(goal)
        }else{
            let delta = Double(self.goal - self.value);
            self.step = delta < self.rate ? 1 : (Int)(delta/self.rate);
            self.timer.start()
        }
    }
    private func setText(_ value:Int){
        if (self.value == value) {
            return;
        }
        self.value = value;
        self.text = self.formater(value);
    }
}
extension AMDigitLabel:AMTimerDelegate{
    public func timer(_ timer: AMTimer, repeated times: Int) {
        var v = value + step
        if v > goal {
            v = goal
        }
        self.setText(v)
        if v == goal {
            step = 0
            self.next()
            self.timer.stop()
        }
    }
}
///The badge label only suport auto layout
///otherwise it may dos't work!!
open class AMBadgeLabel: UILabel {
    private var widthConstt:NSLayoutConstraint!
    private var heightConstt:NSLayoutConstraint!
    public init(badge:Int?=nil,color:UIColor = .red) {
        super.init(frame:.zero)
        self.backgroundColor = color
        self.layer.masksToBounds = true;
        self.textColor = .white;
        self.font = UIFont.systemFont(ofSize: 11);
        self.textAlignment = .center;
        self.widthConstt = self.am.width.equal(to: 0)
        self.heightConstt = self.am.height.equal(to: 0)
        self.badge = badge
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    public func constraint(width:CGFloat,height:CGFloat){
        self.widthConstt.constant = width
        self.heightConstt.constant = height
    }
    public var badge:Int?{
        get{
            if let str = self.text {
                return Int(str)
            }
            return nil
        }
        set{
            guard let newval = newValue else {
                self.text = nil
                self.constraint(width: 0, height: 0)
                return
            }
            switch newval {
            case Int.min..<1:
                self.text = nil
                self.constraint(width: 0, height: 0)
            case 1..<10:
                self.constraint(width: 16, height: 16)
                self.layer.cornerRadius = 8;
                self.text = "\(newval)"
            case 10..<100:
                self.constraint(width: 22, height: 16)
                self.layer.cornerRadius = 8;
                self.text = "\(newval)"
            case 100..<Int.max:
                self.constraint(width: 24, height: 16)
                self.layer.cornerRadius = 8;
                self.text = "99+"
            default:break
            }
        }
    }
}

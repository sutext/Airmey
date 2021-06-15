//
//  CCBadgeLabel.swift
//
//
//  Created by supertext on 6/15/21.
//
import UIKit
import Airmey

/// 用于显示数字角标的Label
/// 必须使用自动约束布局，否则无法正常使用
open class CCBadgeLabel: UILabel {
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

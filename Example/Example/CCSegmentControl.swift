//
//  CKSegmentControl.swift
//  CoreKnight
//
//  Created by supertext on 2021/6/15.
//  Copyright © 2021年 airmey. All rights reserved.
//

import UIKit
import Airmey

protocol CCSegmentDelegate :NSObjectProtocol{
    func segment(_ segment:CCSegmentControl,valueChanged value:Int, from:Int)
}
class CCSegmentControl: UIView {
    private var items:[AMLabel] = []
    private var badges:[CCBadgeLabel] = []
    private let tracker = UIView()
    private var totalWidth:CGFloat
    private var trackerCenterX:NSLayoutConstraint!
    weak var delegate:CCSegmentDelegate?
    init(items:[String],width:CGFloat = .screenWidth) {
        self.totalWidth = width
        super.init(frame:CGRect(x: 0, y: 0, width: width, height: 48))
        let itemWidth = width/CGFloat(items.count)
        for item in items.enumerated(){
            let label = AMLabel()
            let badge = CCBadgeLabel(badge: 0)
            self.addSubview(label)
            self.addSubview(badge)
            self.items.append(label)
            self.badges.append(badge)
            label.textColor = self.textColor
            label.font = self.font
            label.text = item.element
            label.onclick = {[weak self]sender in
                self?.selectedIndex = item.offset
            }
            label.amake { am in
                am.centerY.equal(to: 0)
                am.centerX.equal(to: self.am.left,offset: itemWidth/2+itemWidth*CGFloat(item.offset))
            }
            badge.amake { am in
                am.left.equal(to: label.am.right)
                am.centerY.equal(to: label.am.top)
            }
        }
        self.addSubview(self.tracker)
        self.tracker.amake { am in
            am.size.equal(to: (itemWidth * 0.7,2))
            am.bottom.equal(to: self.am.bottom)
            self.trackerCenterX = am.centerX.equal(to: self.am.left,offset: itemWidth/2)
        }
        self.tintColor = .white
        self.backgroundColor = .hex(0xffca50,alpha:0.99)
    }
    var selectedIndex:Int = 0{
        willSet{
            assert(newValue>=0 && newValue<self.items.count, "selectedIndex:\(newValue) out of bounds!!")
        }
        didSet{
            guard selectedIndex != oldValue else { return }
            self.valueChanged(from: oldValue, to: selectedIndex)
        }
    }
    override var tintColor: UIColor!{
        didSet{
            guard tintColor != oldValue else { return }
            self.tracker.backgroundColor = tintColor
            self.items[self.selectedIndex].textColor = tintColor
        }
    }
    var textColor: UIColor = UIColor(0xffffff,alpha:0.8){
        didSet{
            guard textColor != oldValue else { return }
            self.items.forEach { (label) in
                label.textColor = textColor
            }
        }
    }
    var font:UIFont = .systemFont(ofSize: 14) {
        didSet{
            guard font != oldValue else { return }
            self.items.forEach { (label) in
                label.font = font
            }
        }
    }
    override var intrinsicContentSize: CGSize{
        return CGSize(width:self.totalWidth,height:48)
    }
    func increaseBadge(at index:Int){
        if let badge = self.badge(at: index) {
            let value = badge.badge ?? 0
            badge.badge = value + 1
        }
    }
    func clearBadge(at index:Int){
        if let badge = self.badge(at: index) {
            badge.badge = 0
        }
    }
    func set(badge:Int,at index:Int){
        if let view = self.badge(at: index) {
            view.badge = badge
        }
    }
    private func badge(at index:Int)->CCBadgeLabel?{
        guard index>=0,index<self.badges.count else {
            return nil
        }
        return self.badges[index]
    }
    private func valueChanged(from:Int,to:Int)  {
        let itemWidth = self.totalWidth/CGFloat(self.items.count)
        self.trackerCenterX.constant = itemWidth/2 + CGFloat(to) * itemWidth
        self.items[from].textColor = self.textColor
        self.items[to].textColor = self.tintColor
        self.badges[to].badge = 0
        self.delegate?.segment(self, valueChanged: to, from: from)
        UIView.animate(withDuration: 0.25) {
            self.layoutIfNeeded()
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


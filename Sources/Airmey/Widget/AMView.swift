//
//  AMView.swift
//  Airmey
//
//  Created by supertext on 2020/6/24.
//  Copyright © 2020年 airmey. All rights reserved.
//

import UIKit

open class AMView: UIView {
    private lazy var sigleTapGesture:UITapGestureRecognizer={
        let tap = UITapGestureRecognizer(target: self, action: #selector(AMView.sigleTapAction))
        tap.delaysTouchesBegan = true;
        tap.numberOfTapsRequired = 1;
        return tap;
    }()
    private lazy var doubleTapGesture:UITapGestureRecognizer={
        let tap = UITapGestureRecognizer(target: self, action: #selector(AMView.dobbleTapAction))
        tap.numberOfTapsRequired = 2;
        return tap;
    }()
    private var doubleTaped = false;
    public var onclick:((_ sender:AMView)->Void)?{
        didSet{
            if let _ = self.onclick {
                self.addGestureRecognizer(self.sigleTapGesture)
            }
            else{
                self.removeGestureRecognizer(self.sigleTapGesture);
            }
        }
    }
    public var doubleClick:((_ sender:AMView)->Void)?{
        didSet{
            if let _ = self.doubleClick {
                self.addGestureRecognizer(self.doubleTapGesture)
            }
            else{
                self.removeGestureRecognizer(self.doubleTapGesture);
            }
        }
    }
    public func setSingle(enable:Bool){
        if let _ = self.onclick{
            self.sigleTapGesture.isEnabled = enable;
        }
    }
    public func setDouble(enable:Bool){
        if let _ = self.doubleClick{
            self.doubleTapGesture.isEnabled = enable
        }
    }
    @objc private func handleSingleTap(){
        if !self.doubleTaped {
            self.onclick?(self)
        }
    }
    @objc private func sigleTapAction(){
        if let _ = self.doubleClick{
            self.doubleTaped = false;
            self.perform(#selector(AMView.handleSingleTap), with: nil, afterDelay: 0.2)
        }else {
            self.onclick?(self)
        }
    }
    @objc private func dobbleTapAction(){
        self.doubleTaped = true;
        self.doubleClick?(self)
    }
}


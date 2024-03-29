//
//  AMImageView.swift
//  Airmey
//
//  Created by supertext on 2020/7/5.
//  Copyright © 2020年 airmey. All rights reserved.
//

import UIKit
import Photos

/// Add click logic
open class AMImageView: UIImageView {
    private lazy var sigleTapGesture:UITapGestureRecognizer={
        let tap = UITapGestureRecognizer(target: self, action: #selector(AMImageView.sigleTapAction))
        tap.delaysTouchesBegan = true;
        tap.numberOfTapsRequired = 1;
        return tap;
    }()
    private lazy var doubleTapGesture:UITapGestureRecognizer={
        let tap = UITapGestureRecognizer(target: self, action: #selector(AMImageView.dobbleTapAction))
        tap.numberOfTapsRequired = 2;
        return tap;
    }()
    private var doubleTaped = false;
    public var onclick:ONClick?{
        didSet{
            if let _ = self.onclick {
                self.isUserInteractionEnabled = true
                self.addGestureRecognizer(self.sigleTapGesture)
            }
            else{
                self.removeGestureRecognizer(self.sigleTapGesture);
            }
        }
    }
    public var doubleClick:((_ sender:AMImageView)->Void)?{
        didSet{
            if let _ = self.doubleClick {
                self.isUserInteractionEnabled = true
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
            self.perform(#selector(AMImageView.handleSingleTap), with: nil, afterDelay: 0.2)
        }else {
            self.onclick?(self)
        }
    }
    @objc private func dobbleTapAction(){
        self.doubleTaped = true;
        self.doubleClick?(self)
    }
}

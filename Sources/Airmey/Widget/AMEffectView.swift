//
//  AMEffectView.swift
//  Airmey
//
//  Created by supertext on 2020/11/15.
//  Copyright © 2020年 airmey. All rights reserved.
//

import UIKit

open class AMEffectView: UIView {
    private let visualEffect:UIVisualEffectView
    /// innerView just an ref of visualEffectView's contentView
    public let innerView:UIView
    public init(effect: UIVisualEffect) {
        let visualView = UIVisualEffectView(effect: effect)
        self.innerView = visualView.contentView
        self.visualEffect = visualView
        super.init(frame: .zero)
        self.backgroundColor = .hex(0xffffff,alpha:0.7)
        self.addSubview(self.visualEffect)
        self.visualEffect.am.edge.equal(to: 0)
    }
    public var cornerRadius:CGFloat{
        get{
            return self.layer.cornerRadius
        }
        set{
            self.layer.cornerRadius = newValue
            self.visualEffect.layer.cornerRadius = newValue
        }
    }
    open override var clipsToBounds: Bool{
        didSet{
            self.visualEffect.clipsToBounds = clipsToBounds
        }
    }
    public required init?(coder aDecoder: NSCoder) {
        return nil
    }
    public convenience init(_ style:UIBlurEffect.Style = .light){
        self.init(effect: UIBlurEffect(style: style))
    }
}

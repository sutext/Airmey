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
            else{ 
                self.isUserInteractionEnabled = false;
                self.removeGestureRecognizer(self.tapges);
            }
        }
    }
    open var textInsets:UIEdgeInsets?
    open override func drawText(in rect: CGRect) {
        if let insets = self.textInsets {
            super.drawText(in: rect.inset(by: insets))
        }else{
            super.drawText(in: rect)
        }
    }
    open override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        guard let text = self.text,text.count > 0 else {
            return .zero;
        }
        var rect = super.textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines)
        guard let insets = self.textInsets else {
            return rect
        }
        rect.origin.x    -= insets.left
        rect.origin.y    -= insets.top
        rect.size.width  += (insets.left + insets.right)
        rect.size.height += (insets.top + insets.bottom)
        return rect
    }
}

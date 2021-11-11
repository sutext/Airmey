//
//  AMTextView.swift
//  
//
//  Created by mac-cyy on 2021/11/5.
//

import UIKit

public class AMTextView: UITextView {
    /// 占位文字
    public var placeholder: String?
    /// 占位文字颜色
    public var placeholderColor: UIColor? = UIColor.lightGray
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        // 设置默认字体
        self.font = UIFont.systemFont(ofSize: 15)
        // 使用通知监听文字改变
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange(_:)), name: UITextView.textDidChangeNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func draw(_ rect: CGRect) {
        // 如果有文字,就直接返回,不需要画占位文字
        if self.hasText {
            return
        }
        
        // 属性
        let attrs: [NSAttributedString.Key : Any] = [NSAttributedString.Key.foregroundColor: self.placeholderColor as Any, NSAttributedString.Key.font: self.font!]
        
        // 文字
        var rect1 = rect
        rect1.origin.x = 5
        rect1.origin.y = 8
        rect1.size.width = rect1.size.width - 2*rect1.origin.x
        (self.placeholder! as NSString).draw(in: rect1, withAttributes: attrs)
    }
    
    @objc func textDidChange(_ note: Notification) {
        // 会重新调用drawRect:方法
        self.setNeedsDisplay()
    }
    
}

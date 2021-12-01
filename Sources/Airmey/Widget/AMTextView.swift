//
//  AMTextView.swift
//  
//
//  Created by mac-cyy on 2021/11/5.
//

import UIKit

public class AMTextView: UITextView {
    /// setNeedsDisplay调用drawRect
    public var placeholder: String = "" {
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    var placeHolderColor: UIColor = UIColor.gray{
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    public override var font: UIFont?{
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    public override var text: String!{
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    public override var attributedText: NSAttributedString!{
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        /// default字号
        self.font = UIFont.systemFont(ofSize: 14)
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChanged(noti:)), name: UITextView.textDidChangeNotification, object: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func textDidChanged(noti: NSNotification)  {
        self.setNeedsDisplay()
    }
    
    public override func draw(_ rect: CGRect) {
        if self.hasText {
            return
        }
        var newRect = CGRect()
        newRect.origin.x = 5
        newRect.origin.y = 7
        let size = self.placeholder.getStringSize(rectSize: rect.size, font: self.font ?? UIFont.systemFont(ofSize: 14))
        newRect.size.width = size.width
        newRect.size.height = size.height
        /// 将placeHolder画在textView上
        (self.placeholder as NSString).draw(in: newRect, withAttributes: [NSAttributedString.Key.font: self.font ?? UIFont.systemFont(ofSize: 14),NSAttributedString.Key.foregroundColor: self.placeHolderColor])
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.setNeedsDisplay()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UITextView.textDidChangeNotification, object: self)
    }
    
}


extension String {
    /// 计算字符串的尺寸
    ///
    /// - Parameters:
    ///   - text: 字符串
    ///   - rectSize: 容器的尺寸
    ///   - fontSize: 字体
    /// - Returns: 尺寸
    ///
    public func getStringSize(rectSize: CGSize,font: UIFont) -> CGSize {
        let str: NSString = self as NSString
        let rect = str.boundingRect(with: rectSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return CGSize(width: ceil(rect.width), height: ceil(rect.height))
    }
}

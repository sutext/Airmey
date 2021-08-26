//
//  AMButton.swift
//  Airmey
//
//  Created by supertext on 2020/6/24.
//  Copyright © 2020年 airmey. All rights reserved.
//

import UIKit

public class AMButtonItem{
    public var image:UIImage?
    public var title:String?
    public var titleFont:UIFont?
    public var titleColor:UIColor?
    public var imageColor:UIColor?
    public var imageSize:CGSize?
    public var cornerRadius:CGFloat?
    public var backgroundImage: UIImage?
    public var backgroundColor: UIColor?
    public static let appearance=AMButtonItem(color: UIColor.white, font: .systemFont(ofSize: 14))
    private init(color:UIColor,font:UIFont){
        self.titleFont = font;
        self.titleColor = color;
    }
    public init(){
        self.titleColor = Self.appearance.titleColor;
        self.titleFont = Self.appearance.titleFont;
    }
}
open class AMButton: UIButton {
    public enum TitleStyle:Int {
        case cover
        case right
        case bottom
        public static let `default`:TitleStyle = .right
    }
    public private(set) var style:TitleStyle = .default;
    public private(set) var imageSize:CGSize = CGSize.zero;
    private var innerLabel:UILabel?
    public var onclick :ONClick?{
        didSet{
            if let _ = self.onclick {
                self.addTarget(self, action: #selector(AMButton.clicked), for: .touchUpInside)
            }else {
                self.removeTarget(self, action: #selector(AMButton.clicked), for: .touchUpInside)
            }
        }
    }
    public convenience init() {
        self.init(frame: CGRect.zero, style: .default)
    }
    public convenience init (_ style:TitleStyle){
        self.init(frame: CGRect.zero, style: style);
    }
    public override convenience init(frame: CGRect) {
        self.init(frame: frame, style: .default)
    }
    public init(frame: CGRect,style:TitleStyle = .default) {
        super.init(frame: frame);
        self.style = style;
        self.setup();
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        self.style = TitleStyle(rawValue: aDecoder.decodeInteger(forKey: "style"))!;
        self.imageSize = aDecoder.decodeCGSize(forKey: "imageSize")
        self.setup();
    }
    public func setImage(with color:UIColor ,for state:UIControl.State){
        self.setImage(.rect(color, size: self.imageSize), for: state);
    }
    public func setBackgroundImage(with color:UIColor ,for state:UIControl.State){
        self.setBackgroundImage(.rect(color, size: self.bounds.size), for: state);
    }
    public func apply(item:AMButtonItem,for state :UIControl.State){
        self.imageSize = item.imageSize ?? item.image?.size ?? CGSize.zero;
        if let image = item.image {
            self.setImage(image, for: state);
        }
        else if let color = item.imageColor{
            self.setImage(with: color, for: state);
        }
        if let bgImage = item.backgroundImage {
            self.setBackgroundImage(bgImage, for: state)
        }else if let bgColor = item.backgroundColor {
            self.setBackgroundImage(with: bgColor, for: state)
        }
        self.setTitle(item.title, for: state);
        self.setTitleColor(item.titleColor, for: state);
        self.titleLabel?.font = item.titleFont
        if let radius = item.cornerRadius {
            self.layer.cornerRadius = radius
            self.clipsToBounds = true;
        }
    }
}
extension AMButton{
    open override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        switch self.style {
        case .cover,.bottom:
            return CGRect(x: self.contentEdgeInsets.left, y: self.contentEdgeInsets.top, width: self.imageSize.width, height: self.imageSize.height)
        default:
            return super.imageRect(forContentRect: contentRect);
        }
    }
    open override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        switch self.style {
        case .cover:
            let titleSize = self.titleSize
            if titleSize == .zero {
                return .zero
            }
            let imageRect = CGRect(x: self.contentEdgeInsets.left, y: self.contentEdgeInsets.top, width: self.imageSize.width, height: self.imageSize.height);
            var resultRect = CGRect(x: imageRect.size.width/2-titleSize.width/2+imageRect.origin.x, y: imageRect.size.height/2-titleSize.height/2+imageRect.origin.y, width: titleSize.width, height: titleSize.height);
            resultRect.origin.x += self.titleEdgeInsets.left
            resultRect.origin.y += self.titleEdgeInsets.top
            return resultRect;
        case.bottom:
            let titleSize = self.titleSize
            if titleSize == .zero {
                return .zero
            }
            let imageRect = CGRect(x: self.contentEdgeInsets.left, y: self.contentEdgeInsets.top, width: self.imageSize.width, height: self.imageSize.height);
            var resultRect = CGRect(x:imageRect.size.width/2-titleSize.width/2+imageRect.origin.x, y:imageRect.size.height+imageRect.origin.y, width:titleSize.width, height:titleSize.height);
            resultRect.origin.y += self.titleEdgeInsets.top;
            return resultRect
        default:
            return super.titleRect(forContentRect: contentRect);
        }
    }
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        switch self.style {
        case .cover:
            return CGSize(width: self.contentEdgeInsets.left+self.contentEdgeInsets.right+self.imageSize.width, height: self.contentEdgeInsets.top+self.contentEdgeInsets.bottom+self.imageSize.height)
        case .bottom:
            let titleSize = self.titleSize
            var resultSize = CGSize(width: self.imageSize.width, height: self.imageSize.height+titleSize.height);
            resultSize.height += (self.titleEdgeInsets.top+self.titleEdgeInsets.bottom);
            return CGSize(width: self.contentEdgeInsets.left+self.contentEdgeInsets.right+resultSize.width, height: self.contentEdgeInsets.top+self.contentEdgeInsets.bottom+resultSize.height)
        default:
            return super.sizeThatFits(size);
        }
    }
    open override var intrinsicContentSize: CGSize{
        switch self.style {
        case .cover:
            return CGSize(width: self.contentEdgeInsets.left+self.contentEdgeInsets.right+self.imageSize.width, height: self.contentEdgeInsets.top+self.contentEdgeInsets.bottom+self.imageSize.height)
        case .bottom:
            let titleSize = self.titleSize
            var resultSize = CGSize(width: self.imageSize.width, height: self.imageSize.height+titleSize.height);
            resultSize.height += (self.titleEdgeInsets.top+self.titleEdgeInsets.bottom);
            return CGSize(width: self.contentEdgeInsets.left+self.contentEdgeInsets.right+resultSize.width, height: self.contentEdgeInsets.top+self.contentEdgeInsets.bottom+resultSize.height)
        default:
            return super.intrinsicContentSize;
        }
    }
    open override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder);
        aCoder.encode(self.style.rawValue, forKey: "style");
        aCoder.encode(self.imageSize, forKey: "imageSize");
    }
}
extension AMButton{
    private var titleSize:CGSize{
        guard let label = self.innerLabel else {
            return .zero
        }
        if label.text == nil || label.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count == 0 {
            return .zero
        }
        let width = self.imageSize.width + (self.contentEdgeInsets.left+self.contentEdgeInsets.right);
        let height = (self.style == .cover ? imageSize.height : CGFloat(Int16.max))
        return label.textRect(forBounds: CGRect(x:0,y:0,width:width,height:height), limitedToNumberOfLines: label.numberOfLines).size;
    }
    private func setup(){
        if self.style != .right {
            self.contentHorizontalAlignment = .left;
            self.contentVerticalAlignment = .top;
            self.innerLabel = super.titleLabel
            self.innerLabel?.textAlignment = .center;
        }
    }
    @objc private func clicked(){
        self.onclick?(self);
    }
}

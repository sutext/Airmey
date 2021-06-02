//
//  CKImageLabel.swift
//  CoreKnight
//
//  Created by supertext on 2018/7/6.
//  Copyright © 2018年 lerjin. All rights reserved.
//
import UIKit

public final class AMImageLabel: AMView {
    /// desc the image posiation
    public enum Layout{
        case left
        case right
        case top
        case bottom
    }
    private let stackView = UIStackView()
    private let imageView = AMImageView()
    private let textLabel = UILabel()
    private var imageConstt : AMSizeAnchor.Constraint?
    public private(set) var layout:Layout
    public private(set) var ratio:CGFloat?
    public private(set) var insets:AMEdgeAnchor.Constraint!
    public init(_ layout:Layout = .left,image:UIImage? = nil , text:String? = nil ,ratio:CGFloat? = nil) {
        self.layout = layout
        self.ratio = ratio
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.stackView)
        
        self.imageView.contentMode = .scaleToFill
        self.image = image
        self.textLabel.text = text
        self.textLabel.font = .systemFont(ofSize: 14)
        self.textLabel.textColor = .black
        
        self.stackView.spacing = 4.0
        self.stackView.distribution = .equalSpacing
        self.stackView.alignment = .center
        self.insets = self.stackView.am.edge.equal(to: 0)
        switch layout {
        case .left:
            self.stackView.axis = .horizontal
            self.stackView.addArrangedSubview(self.imageView)
            self.stackView.addArrangedSubview(self.textLabel)
        case .right:
            self.stackView.axis = .horizontal
            self.stackView.addArrangedSubview(self.textLabel)
            self.stackView.addArrangedSubview(self.imageView)
        case .top:
            self.stackView.axis = .vertical
            self.stackView.addArrangedSubview(self.imageView)
            self.stackView.addArrangedSubview(self.textLabel)
        case .bottom:
            self.stackView.axis = .vertical
            self.stackView.addArrangedSubview(self.textLabel)
            self.stackView.addArrangedSubview(self.imageView)
        }
    }
    public required init?(coder aDecoder: NSCoder) {
        return nil
    }
    private func setImage(width:CGFloat,height:CGFloat ){
        if let const = self.imageConstt {
            const.height.constant = width
            const.width.constant = height
            return
        }
        self.imageConstt = self.imageView.am.size.equal(to: (width,height))
    }
}
///MARK: property accessable
public extension AMImageLabel{
    var text:String?{
        get{
            return self.textLabel.text
        }
        set {
            self.textLabel.text = newValue
        }
    }
    var image:UIImage?{
        get{
            return self.imageView.image
        }
        set {
            guard let newone = newValue else {
                self.imageView.image = nil
                return
            }
            self.imageView.image = newone
            guard let scale = self.ratio else {
                return
            }
            let size = newone.size
            self.setImage(width: size.width*scale, height: size.height*scale)
        }
    }
    var font:UIFont?{
        get{
            return self.textLabel.font
        }
        set{
            self.textLabel.font = newValue
        }
    }
    var textColor:UIColor?{
        get{
            return self.textLabel.textColor
        }
        set{
            self.textLabel.textColor = newValue
        }
    }
    var numberOfLines:Int{
        get{
            return self.textLabel.numberOfLines
        }
        set{
            self.textLabel.numberOfLines = newValue
        }
    }
    var textAlignment:NSTextAlignment{
        get{
            return self.textLabel.textAlignment
        }
        set{
            self.textLabel.textAlignment = newValue
        }
    }
    var spaceing:CGFloat{
        get{
            return self.stackView.spacing
        }
        set{
            self.stackView.spacing = newValue
        }
    }
    var alignment:UIStackView.Alignment{
        get{
            return self.stackView.alignment
        }
        set{
            self.stackView.alignment = newValue
        }
    }
}

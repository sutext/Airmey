//
//  CKImageLabel.swift
//  CoreKnight
//
//  Created by supertext on 2020/7/6.
//  Copyright © 2020年 airmey. All rights reserved.
//
import UIKit

///
/// A UIImageView and UILabel structure
/// Use for simplyfy layout code
///
public final class AMImageLabel: AMView {
    /// describe the image posiation
    public enum Layout{
        /// image at left of text
        case left
        /// image at right of text
        case right
        /// image at top of text
        case top
        /// image at bottom of text
        case bottom
    }
    /// inner image image
    public let imageView = UIImageView()
    /// innter text label
    public let textLabel = UILabel()
    private let stackView = UIStackView()
    public private(set) var layout:Layout
    public private(set) var insets:AMEdgeAnchor.Constraint!
    ///
    /// Greate an imageLabel instance
    /// - Parameters:
    ///     - layout: describe the layout of image lable.
    ///     - image: UIImage instance
    ///     - text: text
    ///     - ratio: image scale ratio. if will work when set image for atuo scale
    ///
    public init(
        _ layout:Layout = .left,
        image:UIImage? = nil ,
        text:String? = nil) {
        self.layout = layout
        super.init(frame: .zero)
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
}
///MARK:  property accessable
public extension AMImageLabel{
    /// imageView contentMode
    var imageMode:UIView.ContentMode{
        get {imageView.contentMode}
        set {imageView.contentMode = newValue}
    }
    /// imageView image
    var image:UIImage?{
        get{
            return self.imageView.image
        }
        set {
            self.imageView.image = newValue
        }
    }
    /// lable text
    var text:String?{
        get{
            return self.textLabel.text
        }
        set {
            self.textLabel.text = newValue
        }
    }
    /// label font
    var font:UIFont?{
        get{
            return self.textLabel.font
        }
        set{
            self.textLabel.font = newValue
        }
    }
    /// label text color
    var textColor:UIColor?{
        get{
            return self.textLabel.textColor
        }
        set{
            self.textLabel.textColor = newValue
        }
    }
    /// number of lable lines
    var numberOfLines:Int{
        get{
            return self.textLabel.numberOfLines
        }
        set{
            self.textLabel.numberOfLines = newValue
        }
    }
    /// label textAlignment
    var textAlignment:NSTextAlignment{
        get{
            return self.textLabel.textAlignment
        }
        set{
            self.textLabel.textAlignment = newValue
        }
    }
    /// stack spacing
    var spacing:CGFloat{
        get{
            return self.stackView.spacing
        }
        set{
            self.stackView.spacing = newValue
        }
    }
    /// stack aligment
    var alignment:UIStackView.Alignment{
        get{
            return self.stackView.alignment
        }
        set{
            self.stackView.alignment = newValue
        }
    }
    /// stack distribution
    var distribution:UIStackView.Distribution{
        get{
            return self.stackView.distribution
        }
        set{
            self.stackView.distribution = newValue
        }
    }
}

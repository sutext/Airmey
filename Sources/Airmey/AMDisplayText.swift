//
//  AMDisplayText.swift
//  
//
//  Created by supertext on 9/4/21.
//

import UIKit

/// Both String and NSAttributedString can be AMDisplayText
/// Do not declare new conformances to this protocol;
/// They will not work as expected
public protocol AMDisplayText{}
extension String:AMDisplayText{}
extension NSAttributedString:AMDisplayText{}
extension Optional:AMDisplayText where Wrapped:AMDisplayText {}

/// Discribe any thing that can be display with text.
public protocol AMTextDisplayable{
    var displayText:AMDisplayText{get}
}
/// convenience getter of display text
extension AMTextDisplayable{
    /// attributed string value
    public var attrText:NSAttributedString?{
        return self.displayText as? NSAttributedString
    }
    /// string value
    public var text:String?{
        switch self.displayText {
        case let str as String:
            return str
        case let str as NSAttributedString:
            return str.string
        default:
            return nil
        }
    }
}
extension String:AMTextDisplayable{
    public var displayText: AMDisplayText{self}
}
extension NSAttributedString:AMTextDisplayable{
    public var displayText: AMDisplayText{self}
}
public extension UILabel{
    /// set displayable text
    var displayText:AMTextDisplayable?{
        get{ text ?? attributedText }
        set {
            switch newValue?.displayText {
            case let str as String:
                self.text = str
                self.attributedText = nil
            case let attr as NSAttributedString:
                self.attributedText = attr
                self.text = nil
            default:
                break
            }
        }
    }
}
public extension UITextView{
    /// set displayable text
    var displayText:AMTextDisplayable?{
        get{ text ?? attributedText }
        set {
            switch newValue?.displayText {
            case let str as String:
                self.text = str
                self.attributedText = nil
            case let attr as NSAttributedString:
                self.attributedText = attr
                self.text = nil
            default:
                break
            }
        }
    }
}
public extension UITextField{
    /// set displayable text
    var displayText:AMTextDisplayable?{
        get{ text ?? attributedText }
        set {
            switch newValue?.displayText {
            case let str as String:
                self.text = str
                self.attributedText = nil
            case let attr as NSAttributedString:
                self.attributedText = attr
                self.text = nil
            default:
                break
            }
        }
    }
}

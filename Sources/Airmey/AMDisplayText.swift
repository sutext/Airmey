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
    /// if NSAttributedString convertiable
    public var attrText:NSAttributedString?{
        if let value = self.displayText as? NSAttributedString {
            return value
        }
        return nil
    }
    /// if String convertiable
    public var text:String?{
        if let value = self.displayText as? String {
            return value
        }
        if let value = self.displayText as? NSAttributedString {
            return value.string
        }
        return nil
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
        get{
            fatalError("Getter is inaccurately. Please use text or attributedText")
        }
        set {
            if let text = newValue?.text {
                self.text = text
            }else if let attr = newValue?.attrText {
                self.attributedText = attr
            }
        }
    }
}
public extension UITextView{
    /// set displayable text
    var displayText:AMTextDisplayable?{
        get{
            fatalError("Getter is inaccurately. Please use text or attributedText")
        }
        set {
            if let text = newValue?.text {
                self.text = text
            }else if let attr = newValue?.attrText {
                self.attributedText = attr
            }
        }
    }
}
public extension UITextField{
    /// set displayable text
    var displayText:AMTextDisplayable?{
        get{
            fatalError("Getter is inaccurately. Please use text or attributedText")
        }
        set {
            if let text = newValue?.text {
                self.text = text
            }else if let attr = newValue?.attrText {
                self.attributedText = attr
            }
        }
    }
}

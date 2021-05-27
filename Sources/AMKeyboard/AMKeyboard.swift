//
//  AMKeyboard.swift
//  Airmey
//
//  Created by supertext on 2020/10/21.
//  Copyright © 2020年 airmey. All rights reserved.
//

import UIKit

public enum AMKeyboardType {
    case system
    case custom(AMKeyboardIdentifer)
}
public struct AMKeyboardIdentifer:RawRepresentable,Equatable, Hashable{
    public var rawValue: String
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    public var hashValue: Int{
        return self.rawValue.hashValue
    }
}
public protocol AMKeyboard:UIView{
    init()
    static var id:AMKeyboardIdentifer{get}
    var delegate:AMKeyboardDelegate?{get set}
}
public enum AMKeyboardAction {
    case input(text:String)
    case backward
    case complete
    case custom(content:Any)
}
///keyboard will be nil when the keyboardType == .system
public protocol AMKeyboardDelegate : AnyObject{
    func keyboard(_ keyboard:AMKeyboard?,didTrigger action:AMKeyboardAction)
}


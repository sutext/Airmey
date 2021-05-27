//
//  AMDateStyle.swift
//  
//
//  Created by supertext on 5/21/21.
//

import Foundation
public final class AMDateStyle :RawRepresentable,ExpressibleByStringLiteral,Equatable{
    public static let  full:AMDateStyle = "yyyy-MM-dd HH:mm:ss"
    public static let  mmss:AMDateStyle = "mm:ss"
    public static let  hhmmss:AMDateStyle = "HH:mm:ss"
    public static let  rfc822:AMDateStyle = {
        let s:AMDateStyle = "EEE, dd MMM yyyy HH:mm:ss z"
        s.update = {
            $0.dateFormat = $1
            $0.locale = Locale(identifier: "en")
            $0.timeZone = TimeZone(secondsFromGMT: 0)
        }
        return s
    }()
    public let rawValue: String
    public var update:((DateFormatter,String)->Void)
    required public init(rawValue: String) {
        self.rawValue = rawValue
        self.update = {
            $0.dateFormat = $1
        }
    }
    required public convenience init(stringLiteral value: StringLiteralType) {
        self.init(rawValue: value)
    }
    fileprivate var formater:DateFormatter {
        let dic = Thread.current.threadDictionary
        if let formater = dic["AMDateStyle:\(self.rawValue)"] as? DateFormatter{
            return formater
        }
        let formater = DateFormatter()
        self.update(formater,self.rawValue)
        dic["AMDateStyle:\(self.rawValue)"] = formater
        return formater
    }
}
extension Date{
    public func string(for style:AMDateStyle) -> String {
        return style.formater.string(from: self)
    }
}
extension String{
    public func date(for style:AMDateStyle) -> Date? {
        return style.formater.date(from: self)
    }
}
extension TimeInterval{
    public var hhmmss:String{
        let inttime = Int(self)
        let sec = inttime%60
        var min = inttime/60
        let hour = min/60
        min = min%60
        return String(format: "%02d:%02d:%02d", hour,min,sec)
    }
    public var mmss:String{
        let inttime = Int(self)
        let min = inttime/60
        let sec = inttime%60
        return String(format: "%02d:%02d", min,sec)
    }
    public func string(for style:AMDateStyle) -> String {
        return style.formater.string(from: Date(timeIntervalSince1970: self))
    }
}

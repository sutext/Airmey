//
//  AMDateStyle.swift
//  
//
//  Created by supertext on 5/21/21.
//

import Foundation

/// Definition a date style
///
/// User can extension your custom style:
///
///     extension AMDateStyle{
///         static let day:AMDateStyle = "yyyy-MM-dd"
///     }
///     func test(){
///         let str = Date().string(for: .day) // 2021-08-26
///         let date = "2021-08-26".date(for: .day)
///         let mmss = Date().string(for: "mm:ss")
///     }
///
public struct AMDateStyle :RawRepresentable,Equatable{
    /// common full date style  `yyyy-MM-dd HH:mm:ss`
    public static let full:AMDateStyle = "yyyy-MM-dd HH:mm:ss"
    /// `mm:ss`
    public static let mmss:AMDateStyle = "mm:ss"
    /// `HH:mm:ss`
    public static let hhmmss:AMDateStyle = "HH:mm:ss"
    /// `EEE, dd MMM yyyy HH:mm:ss z`
    public static let rfc822:AMDateStyle = {
        var s:AMDateStyle = "EEE, dd MMM yyyy HH:mm:ss z"
        s.updater = {
            $0.dateFormat = $1
            $0.locale = Locale(identifier: "en")
            $0.timeZone = TimeZone(secondsFromGMT: 0)
        }
        return s
    }()
    /// The DateFormatter updater hock after DateFormatter initialization
    /// User can add custom settings for DateFormatter here
    public var updater:((DateFormatter,String)->Void)
    public let rawValue: String
    public init(rawValue: String) {
        self.rawValue = rawValue
        self.updater = {
            $0.dateFormat = $1
        }
    }
    fileprivate var formater:DateFormatter {
        let dic = Thread.current.threadDictionary
        let key = "AMDateStyle:\(self.rawValue)"
        if let formater = dic[key] as? DateFormatter{
            return formater
        }
        let formater = DateFormatter()
        self.updater(formater,self.rawValue)
        dic[key] = formater
        return formater
    }
}

extension AMDateStyle:ExpressibleByStringLiteral{
    public init(stringLiteral value: StringLiteralType) {
        self.init(rawValue: value)
    }
}
extension Date{
    /// Fast and cached date formeter
    ///
    ///     let str = Date().string(for: .full)
    ///
    ///- Parameters:
    /// - style: The date style
    public func string(for style:AMDateStyle) -> String {
        return style.formater.string(from: self)
    }
}
extension String{
    /// Fast and cached date formeter
    ///
    ///     let date = "2021-08-26 10:10:10".date(for: .full)
    ///
    ///- Parameters:
    /// - style: The date style
    public func date(for style:AMDateStyle) -> Date? {
        return style.formater.date(from: self)
    }
}
extension TimeInterval{
    ///
    /// Change TimeInterval  to "hh:mm:ss" style fastly
    public var hhmmss:String{
        let inttime = Int(self)
        let sec = inttime%60
        var min = inttime/60
        let hour = min/60
        min = min%60
        return String(format: "%02d:%02d:%02d", hour,min,sec)
    }
    ///
    /// Change TimeInterval  to "mm:ss" style fastly
    public var mmss:String{
        let inttime = Int(self)
        let min = inttime/60
        let sec = inttime%60
        return String(format: "%02d:%02d", min,sec)
    }
    /// Fast date formeter
    ///
    ///     let str = 1629951106.string(for: .full) //2021-08-26 12:11:46 UTC-8
    ///
    ///- Parameters:
    ///    - style: The date style
    public func string(for style:AMDateStyle) -> String {
        return style.formater.string(from: Date(timeIntervalSince1970: self))
    }
}

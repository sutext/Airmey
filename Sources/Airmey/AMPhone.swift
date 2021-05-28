//
//  AMPhone.swift
//  
//
//  Created by supertext on 1/9/21.
//

import UIKit

public enum AMPhone {
    public static let width:Width? = {
        Width(rawValue: Int(UIScreen.main.bounds.size.width))
    }()
    public static let height:Height? = {
        Height(rawValue: Int(UIScreen.main.bounds.size.height))
    }()
    ///Is slim screen device eg. X XS XSMAX 11 11Pro 11ProMAx 12mini 12 12Pro 12ProMax
    public static let isSlim:Bool = {
        switch height {
        case .h693,.h812,.h844,.h896:
            return true
        case .none:
            let size = UIScreen.main.bounds.size
            return size.height/size.width > 1.78
        default:
            return false
        }
    }()
    ///Is small screen device eg. 5 5S SE
    public static let isSmall:Bool = {
        if case .w320 = width, case .h568 = height{
            return true
        }
        return false
    }()
    ///Is Plus or Max device eg. 6p 6sp 7p 8p XMax XSMax 11ProMax 12ProMax
    public static let isPlus:Bool = {
        guard let w = width else {
            let size = UIScreen.main.bounds.size
            return size.width>=414
        }
        switch w {
        case .w414,.w428:
            return true
        default:
            return false
        }
    }()
    public static let uuid : String  = {
        if let uuid = getUUID() {
            return uuid
        }
        return addUUID()
    }()
    public static var cacheDir:String{
        if let str  = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first {
            return str
        }
        return tmpDir
    }
    public static var docDir:String{
        if let str  = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            return str
        }
        return tmpDir
    }
    public static var tmpDir:String{
        return NSTemporaryDirectory()
    }
    private static func getUUID()-> String?{
        var query = self.keychainQuery()
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanTrue
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        if status == errSecItemNotFound {return nil}
        if status != noErr {return nil}
        if let existingItem = queryResult as? [String : AnyObject],
           let data = existingItem[kSecValueData as String] as? Data,
           let uuid = String(data: data, encoding: String.Encoding.utf8){
            return uuid
        }
        return nil
    }
    private static func addUUID() -> String{
        let uuid = (UIDevice.current.identifierForVendor ?? UUID()).uuidString
        var query = self.keychainQuery()
        query[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlocked
        query[kSecValueData as String] = uuid.data(using: .utf8) as NSData?
        SecItemAdd(query as CFDictionary, nil)
        return uuid
    }
    private static func keychainQuery() -> [String : AnyObject]{
        var query = [String : AnyObject]()
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrService as String] = "com.airmey" as NSString
        query[kSecAttrAccount as String] = "uuid" as NSString
//        query[kSecAttrAccessGroup as String] = "" as NSString
        return query
    }
}
public extension AMPhone {
    enum Width :Int{
        case w320 = 320
        case w375 = 375
        case w390 = 390
        case w414 = 414
        case w428 = 428
    }
    enum Height:Int {
        case h568 = 568
        case h667 = 667
        case h693 = 693
        case h736 = 736
        case h812 = 812
        case h844 = 844
        case h896 = 896
        case h926 = 926
    }
}


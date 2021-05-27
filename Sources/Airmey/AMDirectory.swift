//
//  AMDirectory.swift
//  
//
//  Created by supertext on 5/14/21.
//
import Foundation
enum AMDirectory {
    static var cache:String{
        if let str  = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first {
            return str
        }
        return tmp
    }
    static var doc:String{
        if let str  = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            return str
        }
        return tmp
    }
    static var tmp:String{
        return NSTemporaryDirectory()
    }
}

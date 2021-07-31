//
//  AMError.swift
//  
//
//  Created by supertext on 5/24/21.
//

import Foundation
public enum AMError:Error{
    case invalidURL(url:String?)
    case invalidData(data:Data?)
    case imageAsset(info:[AnyHashable:Any]?)
    case invalidId
    case momdNotFound
}

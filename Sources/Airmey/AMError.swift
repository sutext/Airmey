//
//  AMError.swift
//  
//
//  Created by supertext on 5/24/21.
//

import Foundation

public enum AMError:Error{
    case sqlite(_ :Sqlite)
    case image(_ :Image)
}

extension AMError{
    public enum Sqlite{
        case momdNotFound
        case idIsNil(info:String)
        case system(info:String)
    }
}
extension AMError{
    public enum Image{
        case invalidURL
        case invalidData
        case system(info:[AnyHashable:Any]?)
    }
}

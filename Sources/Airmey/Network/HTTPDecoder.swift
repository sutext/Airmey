///
//  HTTPDecoder.swift
//  Airmey
//
//  Created by supertext on 2021/6/09.
//  Copyright © 2021年 airmey. All rights reserved.
//

import Foundation

public protocol HTTPDecoder{
    func decode(_ data:Data?,response:HTTPURLResponse)throws -> JSON
}
///
///  application/json respone decoder
///
/// - Note JSNDecoder
///
public struct JSNDecoder:HTTPDecoder{
    public func decode(_ data: Data?, response: HTTPURLResponse) throws -> JSON {
        guard [200,204,205].contains(response.statusCode) else {
            throw HTTPError.invalidStatus(code:response.statusCode, info:.init(parse: data))
        }
        return JSON(parse: data)
    }
}
public struct PlistDecoder:HTTPDecoder{
    public func decode(_ data: Data?, response: HTTPURLResponse) throws -> JSON {
        guard [200,204,205].contains(response.statusCode) else {
            throw HTTPError.invalidStatus(code:response.statusCode, info:.init(parse: data))
        }
        guard let data = data else {
            return .null
        }
        let obj = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
        return JSON(obj)
    }
}

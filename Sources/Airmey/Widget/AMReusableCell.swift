//
//  AMReusableCell.swift
//  Airmey
//
//  Created by supertext on 2020/6/24.
//  Copyright © 2020年 airmey. All rights reserved.
//

import UIKit

public protocol AMCellReuseId:RawRepresentable where RawValue == String{}

public struct AMCommonReuseId:AMCellReuseId {
    public var rawValue: String
    public init(rawValue: String) {
        self.rawValue  = rawValue
    }
}
public protocol AMReusableCell:UITableViewCell{
    associatedtype ReuseId:AMCellReuseId
    static var reuseids:[ReuseId]{get}
    var reuseid:ReuseId?{get}
}
/// add common default implemention. One cell one reuseid
public extension AMReusableCell{
    static var reuseids:[AMCommonReuseId]{
        return [AMCommonReuseId(rawValue: NSStringFromClass(Self.self))]
    }
    var reuseid:AMCommonReuseId?{
        guard let str = self.reuseIdentifier else {
            return nil
        }
        return AMCommonReuseId(rawValue: str)
    }
}
///Auto implemention for string enum type ReuseId
public extension AMReusableCell where Self.ReuseId:CaseIterable,Self.ReuseId.AllCases == [Self.ReuseId]{
    static var reuseids:[ReuseId]{
         return ReuseId.allCases
    }
    var reuseid:ReuseId?{
        guard let str = self.reuseIdentifier else {
            return nil
        }
        return ReuseId(rawValue: str)
    }
}
public extension UITableView{
    /// Register all reuseid of Cell
    func register<Cell>(_ type:Cell.Type) where Cell:AMReusableCell{
        for id  in type.reuseids {
            self.register(type, forCellReuseIdentifier: id.rawValue)
        }
    }
    func register<Cell>(_ type:Cell.Type,for reuseids:[Cell.ReuseId])where Cell:AMReusableCell{
        for id  in reuseids {
            self.register(type, forCellReuseIdentifier: id.rawValue)
        }
    }
    func dequeueReusableCell<Cell>(_ type:Cell.Type, with identifier:Cell.ReuseId,for indexPath:IndexPath)->Cell where Cell:AMReusableCell{
        return self.dequeueReusableCell(withIdentifier: identifier.rawValue, for: indexPath) as! Cell
    }
    func dequeueReusableCell<Cell>(_ type:Cell.Type,for indexPath:IndexPath)->Cell where Cell:AMReusableCell, Cell.ReuseId == AMCommonReuseId{
        return self.dequeueReusableCell(type, with: AMCommonReuseId(rawValue: NSStringFromClass(type)) , for: indexPath)
    }
}

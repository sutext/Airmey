//
//  AMTableView.swift
//  Airmey
//
//  Created by supertext on 2020/6/24.
//  Copyright © 2020年 airmey. All rights reserved.
//

import UIKit

public protocol AMTableViewDelegate:UITableViewDelegate{
    func tableView(_ tableView:AMTableView,willRefreshUsing control:AMRefreshControl ,with style:AMRefreshStyle)
}

open class AMTableView: UITableView {
    private var controls:[AMRefreshStyle:AMRefreshControl] = [:]
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if newSuperview == nil {
            self.removeRefresh([.top,.bottom])
        }
    }
    open func usingRefresh(_ styles:Set<AMRefreshStyle>){
        if styles.contains(.top) {
            self.usingRefresh(UIRefreshControl.self)
        }
        if styles.contains(.bottom) {
            self.usingRefresh(AMLoadmoreControl.self)
        }
    }
    public func usingRefresh<Control:AMRefreshControl>(_ type:Control.Type){
        if self.controls[type.style] == nil{
            let control = type.init()
            control.addTarget(self, action: #selector(AMTableView.beginRefresh(sender:)), for: .valueChanged)
            self.controls[type.style] = control
            self.addSubview(control)
        }
    }
    public func removeRefresh(_ styles:Set<AMRefreshStyle>){
        for style in styles {
            self.controls[style]?.removeFromSuperview()
            self.controls[style] = nil
        }
    }
    public func set(_ styles:Set<AMRefreshStyle>,enable:Bool) {
        for style in styles {
            self.controls[style]?.isEnabled = enable
        }
    }
    public func control(of style:AMRefreshStyle)->AMRefreshControl?{
        return self.controls[style]
    }
    @objc func beginRefresh(sender:AnyObject) {
        guard let control = sender as? AMRefreshControl else {
            return
        }
        guard control.isEnabled else {
            control.endRefreshing()
            return
        }
        guard let delegate = self.delegate as? AMTableViewDelegate else{
            return
        }
        delegate.tableView(self, willRefreshUsing: control, with: type(of: control).style)
    }
}
public protocol AMCellReuseId{
    var rawValue:String{get}
}
extension String:AMCellReuseId{
    public var rawValue: String {
        return self
    }
}
//extension enum : AMCellReuseId where Self.RawValue == String{}

public protocol AMCellReusable{
    associatedtype ReuseId:AMCellReuseId
    static var reuseids:[ReuseId]{get}
    var reuseid:ReuseId?{get}
}
public extension AMCellReusable where Self:UITableViewCell{
    static var reuseids:[String]{
        return [NSStringFromClass(self)]
    }
    var reuseid:String?{
        return self.reuseIdentifier
    }
}
///Auto implemention for string enum type ReuseId
public extension AMCellReusable where Self:UITableViewCell,
                                      Self.ReuseId:RawRepresentable,
                                      Self.ReuseId.RawValue == String,
                                      Self.ReuseId:CaseIterable,
                                      Self.ReuseId.AllCases == [Self.ReuseId]{
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
    func register<Cell:UITableViewCell>(_ type:Cell.Type) where Cell:AMCellReusable{
        for id  in type.reuseids {
            self.register(type, forCellReuseIdentifier: id.rawValue)
        }
    }
    func register<Cell:UITableViewCell>(_ type:Cell.Type,for reuseids:[Cell.ReuseId])where Cell:AMCellReusable{
        for id  in reuseids {
            self.register(type, forCellReuseIdentifier: id.rawValue)
        }
    }
    func dequeueReusableCell<Cell:UITableViewCell>(_ type:Cell.Type, with identifier:Cell.ReuseId,for indexPath:IndexPath)->Cell where Cell:AMCellReusable{
        return self.dequeueReusableCell(withIdentifier: identifier.rawValue, for: indexPath) as! Cell
    }
    func dequeueReusableCell<Cell:UITableViewCell>(_ type:Cell.Type,for indexPath:IndexPath)->Cell where Cell:AMCellReusable, Cell.ReuseId == String{
        return self.dequeueReusableCell(type, with: NSStringFromClass(type), for: indexPath)
    }
}

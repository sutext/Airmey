//
//  AMTableView.swift
//  Airmey
//
//  Created by supertext on 2020/6/24.
//  Copyright © 2020年 airmey. All rights reserved.
//

import UIKit

public protocol AMTableViewDelegate:UITableViewDelegate{
    func tableView(_ tableView:AMTableView, beginRefresh style:AMRefreshStyle, control:AMRefreshControl)
}

open class AMTableView: UITableView {
    private var controls:[AMRefreshStyle:AMRefreshControl] = [:]
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if newSuperview == nil {
            self.remove(refreshs: [.top,.bottom])
        }
    }
    
    ///using default refresh control.
    public func using(refreshs:Set<AMRefreshStyle>){
        if refreshs.contains(.top) {
            self.using(refresh:UIRefreshControl.self)
        }
        if refreshs.contains(.bottom) {
            self.using(refresh: AMLoadmoreControl.self)
        }
    }
    public func using<Control:AMRefreshControl>(refresh type:Control.Type){
        if self.controls[type.style] == nil{
            let control = type.init()
            control.addTarget(self, action: #selector(AMTableView.beginRefresh(sender:)), for: .valueChanged)
            self.controls[type.style] = control
            self.addSubview(control)
        }
    }
    public func remove(refreshs:Set<AMRefreshStyle>){
        for style in refreshs {
            self.controls[style]?.removeFromSuperview()
            self.controls[style] = nil
        }
    }
    public func enable(refreshs :Set<AMRefreshStyle>){
        for style in refreshs {
            self.controls[style]?.isEnabled = true
        }
    }
    public func disable(refreshs:Set<AMRefreshStyle>){
        for style in refreshs {
            self.controls[style]?.isEnabled = false
        }
    }
    public func refresh(at style:AMRefreshStyle)->AMRefreshControl?{
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
        delegate.tableView(self, beginRefresh: type(of: control).style,control: control)
    }
}
public protocol AMCellReuseId:RawRepresentable where RawValue == String{}
//extension enum : AMCellReuseId where Self.RawValue == String{}
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

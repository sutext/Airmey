//
//  AMRefresh.swift
//  Airmey
//
//  Created by supertext on 2020/8/14.
//  Copyright © 2020年 airmey. All rights reserved.
//

import UIKit


public enum AMRefreshStyle:String{
    case top
    case bottom
}
public protocol AMScrollViewDelegate: UIScrollViewDelegate {
    func scrollView(_ scrollView:UIScrollView, willBegin refresh:AMRefresh, style:AMRefreshStyle)
}
public protocol AMTableViewDelegate:UITableViewDelegate{
    func tableView(_ tableView:UITableView, willBegin refresh:AMRefresh, style:AMRefreshStyle)
}
public protocol AMCollectionViewDelegate:UICollectionViewDelegate{
    func collectionView(_ collectionView:UICollectionView, willBegin style:AMRefresh, style:AMRefreshStyle)
}
public protocol AMRefresh:UIControl{
    init()
    static var style:AMRefreshStyle {get}
    var isRefreshing:Bool {get}
    func beginRefreshing()
    func endRefreshing()
}
extension UIScrollView {
    private var controls:NSMutableDictionary{
        let key  = UnsafeRawPointer.init(bitPattern: "am_scrollView_controls".hashValue)!
        if let dic = objc_getAssociatedObject(self, key) as? NSMutableDictionary{
            return dic
        }
        let dic = NSMutableDictionary()
        objc_setAssociatedObject(self, key, dic, .OBJC_ASSOCIATION_RETAIN)
        return dic
    }
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if newSuperview == nil {
            self.removeRefresh([.top,.bottom])
        }
    }
    ///using default refresh control.
    public func usingRefresh(_ styles:Set<AMRefreshStyle>){
        if styles.contains(.top) {
            self.usingRefresh(UIRefreshControl.self)
        }
        if styles.contains(.bottom) {
            self.usingRefresh(AMRefreshControl.self)
        }
    }
    public func usingRefresh<Control:AMRefresh>(_ type:Control.Type){
        guard self.controls.object(forKey: type.style.rawValue as NSString) == nil else {
            return
        }
        let refresh = type.init()
        refresh.addTarget(self, action: #selector(beginRefresh(sender:)), for: .valueChanged)
        self.controls.setObject(refresh, forKey: type.style.rawValue as NSString)
        self.addSubview(refresh)
    }
    public func removeRefresh(_ styles:Set<AMRefreshStyle>){
        for style in styles {
            if let refresh = self.controls.object(forKey: style.rawValue as NSString) as? AMRefresh {
                refresh.removeFromSuperview()
                self.controls.removeObject(forKey: style.rawValue as NSString)
            }
        }
    }
    public func enableRefresh(_ styles :Set<AMRefreshStyle>){
        for style in styles {
            if let refresh = self.controls.object(forKey: style.rawValue as NSString) as? AMRefresh {
                refresh.isEnabled = true
            }
        }
    }
    public func disableRefresh(_ styles:Set<AMRefreshStyle>){
        for style in styles {
            if let refresh = self.controls.object(forKey: style.rawValue as NSString) as? AMRefresh {
                refresh.isEnabled = false
            }
        }
    }
    public func refresh(of style:AMRefreshStyle)->AMRefresh?{
        return self.controls.object(forKey: style.rawValue as NSString) as? AMRefresh
    }
    @objc func beginRefresh(sender:AnyObject) {
        guard let refresh = sender as? AMRefresh else {
            return
        }
        guard refresh.isEnabled else {
            refresh.endRefreshing()
            return
        }
        guard let delegate  = self.delegate else {
            return
        }
        let style = type(of: refresh).style
        switch delegate {
        case let d as AMScrollViewDelegate:
            d.scrollView(self, willBegin: refresh, style: style)
        case let d as AMTableViewDelegate:
            if let tableView = self as? UITableView {
                d.tableView(tableView, willBegin: refresh, style: style)
            }
        case let d as AMCollectionViewDelegate:
            if let collectionView = self as? UICollectionView {
                d.collectionView(collectionView, willBegin: refresh, style: style)
            }
        default:
            break
        }
    }
}

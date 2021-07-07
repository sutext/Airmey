//
//  UIScrollView+AMRefresh.swift
//  Airmey
//
//  Created by supertext on 2020/8/14.
//  Copyright © 2020年 airmey. All rights reserved.
//

import UIKit

public protocol AMScrollViewDelegate: UIScrollViewDelegate {
    func scrollView(_ scrollView:UIScrollView, willBegin refresh:AMRefresh)
}
public protocol AMTableViewDelegate:UITableViewDelegate{
    func tableView(_ tableView:UITableView, willBegin refresh:AMRefresh)
}
public protocol AMCollectionViewDelegate:UICollectionViewDelegate{
    func collectionView(_ collectionView:UICollectionView, willBegin refresh:AMRefresh)
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
            self.removeRefresh([.header,.footer])
        }
    }
    ///using default refresh control.
    public func usingRefresh(_ styles:Set<AMRefresh.Style>){
        if styles.contains(.header) {
            self.usingRefresh(AMRefreshHeader())
        }
        if styles.contains(.footer) {
            self.usingRefresh(AMRefreshFooter())
        }
    }
    public func usingRefresh(_ refresh:AMRefresh){
        guard self.controls.object(forKey: refresh.style.rawValue as NSString) == nil else {
            return
        }
        refresh.addTarget(self, action: #selector(beginRefresh(sender:)), for: .valueChanged)
        self.controls.setObject(refresh, forKey: refresh.style.rawValue as NSString)
        self.addSubview(refresh)
    }
    public func removeRefresh(_ styles:Set<AMRefresh.Style>){
        for style in styles {
            if let refresh = self.controls.object(forKey: style.rawValue as NSString) as? AMRefresh {
                refresh.removeFromSuperview()
                self.controls.removeObject(forKey: style.rawValue as NSString)
            }
        }
    }
    public func enableRefresh(_ styles :Set<AMRefresh.Style>){
        for style in styles {
            if let refresh = self.controls.object(forKey: style.rawValue as NSString) as? AMRefresh {
                refresh.isEnabled = true
            }
        }
    }
    public func disableRefresh(_ styles:Set<AMRefresh.Style>){
        for style in styles {
            if let refresh = self.controls.object(forKey: style.rawValue as NSString) as? AMRefresh {
                refresh.isEnabled = false
            }
        }
    }
    public func refresh(of style:AMRefresh.Style)->AMRefresh?{
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
        switch delegate {
        case let d as AMScrollViewDelegate:
            d.scrollView(self, willBegin: refresh)
        case let d as AMTableViewDelegate:
            if let tableView = self as? UITableView {
                d.tableView(tableView, willBegin: refresh)
            }
        case let d as AMCollectionViewDelegate:
            if let collectionView = self as? UICollectionView {
                d.collectionView(collectionView, willBegin: refresh)
            }
        default:
            break
        }
    }
}

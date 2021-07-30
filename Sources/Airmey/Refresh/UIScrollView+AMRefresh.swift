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
    /// add refresh control to the scrollview
    ///- Note: only first one of each style effect !
    ///- Note: duplicate add refresh contorl of same style is noneffective !
    public func using(refresh:AMRefresh){
        guard self.controls.object(forKey: refresh.style.rawValue as NSString) == nil else {
            return
        }
        self.controls.setObject(refresh, forKey: refresh.style.rawValue as NSString)
        self.insertSubview(refresh, at: 0)
    }
    /// remove some refresh
    public func remove(refresh styles:AMRefresh.Style...){
        self.remove(refresh: Set(styles))
    }
    /// remove some refresh
    public func remove(refresh styles:Set<AMRefresh.Style>){
        for style in styles {
            if let refresh = self.controls.object(forKey: style.rawValue as NSString) as? AMRefresh {
                refresh.removeFromSuperview()
                self.controls.removeObject(forKey: style.rawValue as NSString)
            }
        }
    }
    /// refresh header if exsit
    public var header:AMRefreshHeader?{
        return self.controls.object(forKey: AMRefresh.Style.header.rawValue as NSString) as? AMRefreshHeader
    }
    /// refresh footer if exsit
    public var footer:AMRefreshFooter?{
        return self.controls.object(forKey: AMRefresh.Style.footer.rawValue as NSString) as? AMRefreshFooter
    }
}

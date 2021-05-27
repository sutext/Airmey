//
//  AMCollectionView.swift
//  Airmey
//
//  Created by supertext on 2020/6/24.
//  Copyright © 2020年 airmey. All rights reserved.
//

import UIKit

public protocol AMCollectionViewDelegate:UICollectionViewDelegate {
    func collectionView(_ collectionView:AMCollectionView,willRefreshUsing control:AMRefreshControl,with style:AMRefreshStyle)
}
open class AMCollectionView: UICollectionView {
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
    public func usingRefresh<Control:AMRefreshControl>(_ type:Control.Type) {
        if self.controls[type.style] == nil{
            let control = type.init()
            control.addTarget(self, action: #selector(AMCollectionView.beginRefresh(sender:)), for: .valueChanged)
            self.controls[type.style] = control
            self.addSubview(control)
        }
    }
    public func removeRefresh(_ styles:Set<AMRefreshStyle>) {
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
    public func control(of style:AMRefreshStyle)->AMRefreshControl? {
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
        guard let delegate = self.delegate as? AMCollectionViewDelegate else{
            return
        }
        delegate.collectionView(self, willRefreshUsing: control, with: type(of: control).style)
    }
}

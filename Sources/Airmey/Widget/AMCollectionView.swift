//
//  AMCollectionView.swift
//  Airmey
//
//  Created by supertext on 2020/6/24.
//  Copyright © 2020年 airmey. All rights reserved.
//

import UIKit

public protocol AMCollectionViewDelegate:UICollectionViewDelegate {
    func collectionView(_ collectionView:AMCollectionView, beginRefresh style:AMRefreshStyle, control:AMRefreshControl)
}
open class AMCollectionView: UICollectionView {
    private var controls:[AMRefreshStyle:AMRefreshControl] = [:]
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if newSuperview == nil {
            self.remove(refreshs:[.top,.bottom])
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
        guard let delegate = self.delegate as? AMCollectionViewDelegate else{
            return
        }
        delegate.collectionView(self, beginRefresh: type(of: control).style,control: control)
    }
}

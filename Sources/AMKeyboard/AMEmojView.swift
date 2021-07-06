//
//  AMEmojView.swift
//  Airmey
//
//  Created by supertext on 2020/10/21.
//  Copyright © 2020年 airmey. All rights reserved.
//

import UIKit
import Airmey
class AMEmojView: UIView {
    private let emoj:AMEmoj
    private let swiper = AMSwiper()
    private let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    private let ranges:[Range<Int>]
    private let pageSize:Int
    private let pageControl = UIPageControl()
    var didSelected:SelectHandler?
    var deleteClicked:(()->Void)?
    init(_ emoj:AMEmoj,pageSize:Int){
        self.emoj = emoj
        self.pageSize = pageSize
        let pageCount = emoj.contents.count/pageSize + 1
        var rangs:[Range<Int>] = []
        for idx in 0..<pageCount{
            rangs.append(idx*pageSize ..< (idx+1)*pageSize)
        }
        self.ranges = rangs
        super.init(frame: .zero)
        self.addSubview(self.effectView)
        self.addSubview(self.swiper)
        self.addSubview(self.pageControl)
        self.effectView.am.edge.equal(to: 0)

        self.pageControl.amake { (am) in
            am.centerX.equal(to: self.am.centerX)
            am.bottom.equal(to: 8)
            am.height.equal(to: 10)
        }
        self.pageControl.numberOfPages = self.ranges.count
        self.pageControl.currentPage = 0
        self.pageControl.currentPageIndicatorTintColor = .hex(0x9b9b9b)
        self.pageControl.pageIndicatorTintColor = .hex(0xd8d8d8)
        
        self.swiper.am.edge.equal(to: 0)
        self.swiper.dataSource = self
        self.swiper.delegate = self
        self.swiper.reload()
    }
    public required init?(coder aDecoder: NSCoder) {
        return nil
    }
}
extension AMEmojView:AMSwiperDataSource{
    func headNode(for swiper: AMSwiper) -> UIViewController? {
        if let first = self.ranges.first {
            return self.createChild(first)
        }
        return nil
    }
    func swiper(_ swiper: AMSwiper, nodeAfter node: UIViewController) -> UIViewController? {
        if let idx = (node as? ChildControler)?.index {
            if idx < self.ranges.count - 1 {
                return self.createChild(self.ranges[idx+1])
            }
        }
        return nil
    }
    func swiper(_ swiper: AMSwiper, nodeBefore node: UIViewController) -> UIViewController? {
        if let idx = (node as? ChildControler)?.index {
            if idx > 0 {
                return self.createChild(self.ranges[idx-1])
            }
        }
        return nil
    }
    
    private func createChild(_ range:Range<Int>)->ChildControler{
        let vc = ChildControler(self.emoj, range: range)
        vc.didSelected = {[weak self] text in
            self?.didSelected?(text)
        }
        vc.deleteClicked = {[weak self] in
            self?.deleteClicked?()
        }
        vc.loadViewIfNeeded()
        return vc
    }
}
extension AMEmojView:AMSwiperDelegate{
    func swiper(_ swiper: AMSwiper, didDisplay controller: UIViewController) {
        if let idx = (controller as? ChildControler)?.index {
            self.pageControl.currentPage = idx
        }
    }
}
extension AMEmojView{
    typealias SelectHandler = ((String)->Void)
    class ChildControler:UIViewController{
        private let contentView : UICollectionView
        private let range:Range<Int>
        private let emoj:AMEmoj
        var didSelected:SelectHandler?
        var deleteClicked:(()->Void)?
        var index:Int{
            return self.range.lowerBound/self.range.count
        }
        init(_ emoj:AMEmoj, range:Range<Int>){
            self.emoj = emoj
            self.range = range
            let layout = UICollectionViewFlowLayout()
            self.contentView = UICollectionView(frame: .zero, collectionViewLayout: layout)
            super.init(nibName: nil, bundle: nil)
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            layout.itemSize = CGSize(width:40,height:35)
            self.contentView.backgroundColor = AMEmojKeyboard.Config.default.backgroundColor
            self.contentView.dataSource = self
            self.contentView.delegate = self
            self.view.addSubview(self.contentView)
            self.contentView.am.edge.equal(to: 0)
            self.contentView.register(EmojCell.self, forCellWithReuseIdentifier: "EmojCell")
            self.contentView.register(ImageCell.self, forCellWithReuseIdentifier: "ImageCell")
            self.contentView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "EmptyCell")
        }
        public required init?(coder aDecoder: NSCoder) {
            return nil
        }
        override func viewDidLoad() {
            super.viewDidLoad()
        }
    }
}
extension AMEmojView.ChildControler:UICollectionViewDataSource
{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.range.count + 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard indexPath.item != self.range.count else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        }
        let idx = self.range.lowerBound + indexPath.item
        guard idx < self.emoj.contents.count else{
            return collectionView.dequeueReusableCell(withReuseIdentifier: "EmptyCell", for: indexPath)
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojCell", for: indexPath) as! EmojCell
        cell.textLabel.text = self.emoj.contents[idx]
        return cell
    }
}
extension AMEmojView.ChildControler:UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard indexPath.item != self.range.count else {
            self.deleteClicked?()
            return
        }
        let idx = self.range.lowerBound + indexPath.item
        if idx < self.emoj.contents.count{
            self.didSelected?(self.emoj.contents[idx])
        }
    }
}
extension AMEmojView.ChildControler{
    class EmojCell:UICollectionViewCell{
        let textLabel = AMLabel()
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.addSubview(self.textLabel)
            self.textLabel.font = UIFont.systemFont(ofSize: 28)
            self.textLabel.am.center.equal(to: self.contentView.am.center)
            self.selectedBackgroundView = UIView()
            self.selectedBackgroundView?.layer.cornerRadius = 3
            self.selectedBackgroundView?.backgroundColor = .lightGray
        }
        required init?(coder aDecoder: NSCoder) {
            return nil
        }
    }
    class ImageCell:UICollectionViewCell{
        private let imageView = UIImageView()
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.addSubview(self.imageView)
            self.selectedBackgroundView = UIView()
            self.selectedBackgroundView?.layer.cornerRadius = 3
            self.selectedBackgroundView?.backgroundColor = .lightGray
            self.imageView.image = AMEmojKeyboard.Config.default.deleteImage
            self.imageView.am.center.equal(to: self.contentView.am.center)
        }
        required init?(coder aDecoder: NSCoder) {
            return nil
        }
    }
}

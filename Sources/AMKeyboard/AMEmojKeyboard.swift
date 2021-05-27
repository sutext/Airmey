//
//  AMEmojKeyboard.swift
//  Airmey
//
//  Created by supertext on 2020/10/21.
//  Copyright © 2020年 airmey. All rights reserved.
//

import UIKit
import Airmey
public extension AMKeyboardIdentifer{
    static let emoj = AMKeyboardIdentifer(rawValue: "Airmey.Emoj.Keyboard")
}

public class AMEmojKeyboard: UIView,AMKeyboard {
    public static let id = AMKeyboardIdentifer.emoj
    private let emojs:[AMEmoj]
    private var currentEmojView:AMEmojView?
    weak public var delegate:AMKeyboardDelegate?
    private let pageSize:Int
    private let toolBar = ToolBar()
    public required init(){
        self.emojs = Config.default.emojs
        self.pageSize = Int((CGFloat.screenWidth - 20)/40)*4 - 1
        super.init(frame:.zero)
        self.toolBar.collectionView.delegate = self
        self.toolBar.collectionView.dataSource = self
        self.toolBar.collectionView.selectItem(at: IndexPath(item:0,section:0), animated: false, scrollPosition: .left)
        self.toolBar.sendButton.onclick = {[weak self] sender in
            guard let wself = self else {
                return
            }
            wself.delegate?.keyboard(wself, didTrigger: .complete)
        }
        self.addSubview(self.toolBar)
        self.currentEmojView = self.createEmojView(at:0)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        return nil
    }
}
extension AMEmojKeyboard:UICollectionViewDataSource
{
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.emojs.count
    }
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BarCell", for: indexPath) as! BarCell
        cell.setup(emoj: self.emojs[indexPath.item].title)
        return cell
    }
}
extension AMEmojKeyboard:UICollectionViewDelegate{
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let oldView = self.currentEmojView else {
            self.currentEmojView = self.createEmojView(at:indexPath.item)
            return
        }
        let newView = self.createEmojView(at:indexPath.item)
        newView.alpha = 0
        self.currentEmojView = newView
        UIView.animate(withDuration: 0.25, animations: {
            oldView.alpha = 0
            newView.alpha = 1
        }) { (finished) in
            oldView.removeFromSuperview()
        }
    }
    private func createEmojView(at index:Int)->AMEmojView{
        let emoj = self.emojs[index]
        let emojView = AMEmojView(emoj, pageSize: self.pageSize)
        emojView.didSelected = {[weak self] text in
            guard let wself = self else {
                return
            }
            wself.delegate?.keyboard(wself, didTrigger: .input(text:text))
        }
        emojView.deleteClicked = {[weak self] in
            guard let wself = self else {
                return
            }
            wself.delegate?.keyboard(wself, didTrigger: .backward)
        }
        self.addSubview(emojView)
        emojView.am.edge.equal(top: 0, left: 0, bottom: .tabbarHeight, right: 0)
        return emojView
    }
}
extension AMEmojKeyboard{
    class ToolBar:AMToolBar{
        let collectionView:UICollectionView
        let sendButton = AMButton(.cover)
        init() {
            let layout = UICollectionViewFlowLayout()
            self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
            super.init(style: .normal)
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            layout.itemSize = CGSize(width:(.screenWidth - 80)/6,height:ToolBar.contentHeight)
            self.backgroundColor = AMEmojKeyboard.Config.default.backgroundColor
            self.collectionView.backgroundColor = .clear
            self.collectionView.register(BarCell.self, forCellWithReuseIdentifier: "BarCell")
            
            self.contentView.addSubview(self.collectionView)
            self.contentView.addSubview(self.sendButton)
            self.collectionView.am.edge.equal(top: 0, left: 0, bottom: 0, right: 80)
            self.sendButton.am.edge.equal(top: 0, right: 0)
            self.setupButton()
        }
        required init?(coder aDecoder: NSCoder) {
            return nil
        }
        func setupButton(){
            let item = AMButtonItem()
            item.imageSize = CGSize(width: 80, height: ToolBar.contentHeight)
            item.imageColor = Config.default.sendColor
            item.title = Config.default.sendTitle
            self.sendButton.apply(item: item, for: .normal)
            self.sendButton.sizeToFit()
        }
    }
}
extension AMEmojKeyboard{
    class BarCell:UICollectionViewCell{
        private let textLabel = AMLabel()
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.contentView.addSubview(self.textLabel)
            self.textLabel.font = UIFont.systemFont(ofSize: 28)
            self.textLabel.am.center.equal(to: self.am.center)
            self.selectedBackgroundView = UIView()
            self.selectedBackgroundView?.backgroundColor = Config.default.barSelectedColor
        }
        func setup(emoj:String?){
            self.textLabel.text = emoj
        }
        required init?(coder aDecoder: NSCoder) {
            return nil
        }
    }
}
extension AMEmojKeyboard{
    public class Config{
        public static let `default` = Config()
        private init(){}
        public var emojs:[AMEmoj] = AMEmoj.usual
        public var sendTitle:String = "发送"
        public var sendColor:UIColor = .hex(0xd43c38)
        public var backgroundColor:UIColor = .hex(0xf8f8f8,alpha:0.8)
        public var barSelectedColor:UIColor = .hex(0xe6e6e6,alpha:0.8)
        public var deleteImage:UIImage? = {
            let data = Data(base64Encoded: "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")
            return UIImage(data: data!, scale: 3)
        }()
    }
}

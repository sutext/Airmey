//
//  AMActionController.swift
//  Airmey
//
//  Created by supertext on 5/28/21.
//

import UIKit

///ActionSheet contorller
open class AMActionController:AMPopupController,AMActionable{
    public let items:[AMTextDisplayable]
    public let tableView = UITableView()
    private let cancelBar = CancelBar()
    private let rowHeight:CGFloat = 50
    private var hideAtIndex:Int?
    public required init(_ items:[AMTextDisplayable],onhide:AMActionBlock?=nil) {
        let count = items.count <> 1...5
        self.items = items
        super.init(AMFramePresenter(bottom: CGFloat(count)*self.rowHeight + .tabbarHeight))
        self.presenter.onhide = {[weak self] in
            if let idx = self?.hideAtIndex {
                onhide?(items[idx],idx)
            }else{
                onhide?(nil,nil)
            }
        }
        self.tableView.isScrollEnabled = (items.count > 5)
    }
    ///dos't implement NSCoding protocol
    required public init?(coder aDecoder: NSCoder) {
        return nil
    }
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.cancelBar)
        self.tableView.contentInsetAdjustmentBehavior = .never
        self.tableView.delaysContentTouches = false
        self.tableView.separatorStyle = .singleLine
        self.tableView.estimatedRowHeight = 0
        self.tableView.estimatedSectionFooterHeight = 0
        self.tableView.estimatedSectionHeaderHeight = 0
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.rowHeight = self.rowHeight
        self.tableView.backgroundColor = .clear
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.cancelText = "Cancel"
        self.cancelFont = .systemFont(ofSize: 20)
        self.cancelColor = .hex(0xf93d32)
        self.tableView.amake { am in
            am.edge.equal(top: 0, left: 0, right: 0)
            am.height.equal(to: CGFloat((self.items.count <> 1...5)*50))
        }
        self.cancelBar.control.addTarget(self, action: #selector(cancelAction(sender:)), for: .touchUpInside)
    }
    public var cancelText:AMTextDisplayable?{
        get {self.cancelBar.label.displayText}
        set {self.cancelBar.label.displayText = newValue}
    }
    public var cancelColor:UIColor?{
        get {self.cancelBar.label.textColor}
        set {self.cancelBar.label.textColor = newValue}
    }
    public var cancelFont:UIFont?{
        get {self.cancelBar.label.font}
        set {self.cancelBar.label.font = newValue}
    }
    @objc dynamic func cancelAction(sender:UIControl){
        self.dismiss(animated: true)
    }
}
extension AMActionController:UITableViewDataSource,UITableViewDelegate{
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "actionCell")
        if cell == nil{
            cell = UITableViewCell(style: .default, reuseIdentifier: "actionCell");
            cell?.accessoryType = .none;
            cell?.textLabel?.textAlignment = .center;
            cell?.textLabel?.textColor = .hex(0x2389f9)
            cell?.separatorInset = UIEdgeInsets.zero
            cell?.backgroundColor = .clear
        }
        cell!.textLabel?.displayText = self.items[indexPath.row];
        return cell!;
    }
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.hideAtIndex = indexPath.row
        self.dismiss(animated: true)
    }
}
extension AMActionController{
    class CancelBar:AMToolBar{
        let label = UILabel()
        let control = UIControl()
        override init(){
            super.init()
            self.usingEffect()
            self.backgroundColor = .hex(0xffffff,alpha:0.7)
            self.contentView.addSubview(self.label)
            self.addSubview(self.control)
            self.label.am.center.equal(to: 0)
            self.control.am.edge.equal(to: 0)
            self.control.addTarget(self, action: #selector(CancelBar.touchDown), for: .touchDown)
            self.control.addTarget(self, action: #selector(CancelBar.touchUp), for: .touchUpInside)
            self.control.addTarget(self, action: #selector(CancelBar.touchUp), for: .touchUpOutside)
        }
        @objc func touchDown(){
            self.backgroundColor = .lightGray
        }
        @objc func touchUp(){
            self.backgroundColor = .clear
        }
        required init?(coder aDecoder: NSCoder) {
            return nil
        }
    }
}

//
//  AMActionController.swift
//  Airmey
//
//  Created by supertext on 5/28/21.
//

import UIKit

open class AMActionController:UIViewController,AMActionable{
    private var finishBlock:AMPopup.ActionBlock?
    private let effectView = AMEffectView()
    private var items:[AMTextConvertible]
    private let presenter:AMFramePresenter
    private let cancelBar = CancelBar()
    private let tableView = UITableView()
    private let rowHeight:CGFloat = 50
    public required init(_ items:[AMTextConvertible],onhide:AMPopup.ActionBlock?=nil) {
        let count = items.count <> 1...5
        self.items = items
        self.cancelBar.text = "Cancel"
        self.presenter = AMFramePresenter(CGFloat(count)*self.rowHeight + .tabbarHeight)
        self.finishBlock = onhide
        super.init(nibName: nil, bundle: nil)
        self.tableView.isScrollEnabled = (items.count > 5)
        self.transitioningDelegate = self.presenter
        self.modalPresentationStyle = .custom
    }
    ///dos't implement NSCoding protocol
    required public init?(coder aDecoder: NSCoder) {
        return nil
    }
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.effectView)
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.cancelBar)
        self.effectView.am.edge.equal(to: 0)
        self.tableView.contentInsetAdjustmentBehavior = .never
        self.tableView.delaysContentTouches = false
        self.tableView.separatorStyle = .singleLine
        self.tableView.estimatedRowHeight = 0
        self.tableView.estimatedSectionFooterHeight = 0
        self.tableView.estimatedSectionHeaderHeight = 0
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.rowHeight = self.rowHeight
        self.tableView.backgroundColor = .clear
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.amake { am in
            am.edge.equal(top: 0, left: 0, right: 0)
            am.height.equal(to: CGFloat((self.items.count <> 1...5)*50))
        }
        self.cancelBar.control.addTarget(self, action: #selector(AMActionController.cancelAction(sender:)), for: .touchUpInside)
    }
    @objc dynamic func cancelAction(sender:UIControl){
        self.hide()
    }
    private func hide(_ index:Int? = nil){
        self.dismiss(animated: true) {
            if let idx = index{
                self.finishBlock?(self.items[idx],idx);
            }else{
                self.finishBlock?(nil,nil)
            }
        }
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
            cell?.separatorInset = UIEdgeInsets.zero
            cell?.backgroundColor = .clear
        }
        cell!.textLabel?.text = self.items[indexPath.row].text;
        return cell!;
    }
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.hide(indexPath.row)
    }
}
extension AMActionController{
    class CancelBar:AMToolBar{
        let label = UILabel()
        let control = UIControl()
        init(){
            super.init(style:.normal)
            self.shadowLine.isHidden = true
            self.label.translatesAutoresizingMaskIntoConstraints = false
            self.control.translatesAutoresizingMaskIntoConstraints = false
            self.contentView.addSubview(self.label)
            self.addSubview(self.control)
            self.label.font = .systemFont(ofSize: 18)
            self.label.textColor = .darkText
            self.label.am.center.equal(to: 0)
            self.control.am.edge.equal(to: 0)
            self.control.addTarget(self, action: #selector(CancelBar.touchDown), for: .touchDown)
            self.control.addTarget(self, action: #selector(CancelBar.touchUp), for: .touchUpInside)
            self.control.addTarget(self, action: #selector(CancelBar.touchUp), for: .touchUpOutside)
        }
        var text:String?{
            get{
                return self.label.text
            }
            set{
                self.label.text = newValue
            }
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

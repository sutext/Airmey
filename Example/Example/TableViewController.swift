//
//  TableViewController.swift
//  Example
//
//  Created by supertext on 7/14/21.
//

import UIKit
import Airmey

class TableViewController: UIViewController {
    var count = 0
    let tableView = UITableView()
    init() {
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .fullScreen
        self.tabBarItem = UITabBarItem(title: "TableView", image: .round(.yellow, radius: 10), selectedImage: .round(.cyan, radius: 10))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.tableView)
        self.title = "TableView"
        self.navbar.title = "TableView"
        let images = (1...45).compactMap {
            UIImage(named: String(format: "loading%02i", $0))
        }
        self.tableView.separatorStyle = .none
        self.tableView.separatorInset = .zero
        self.tableView.am.edge.equal(to: 0)
        self.tableView.contentInsetAdjustmentBehavior = .never
        self.tableView.contentInset = UIEdgeInsets(top: navbar.height, left: 0, bottom: .tabbarHeight, right: 0)
        self.tableView.using(refresh: AMRefreshHeader(.gif(images)))
        self.tableView.using(refresh: AMRefreshFooter())
        self.tableView.register(Cell.self)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.footer?.threshold = -2
        self.tableView.header?.beginRefreshing()
    }
    
}
extension TableViewController:AMTableViewDelegate{
    func tableView(_ tableView: UITableView, willBegin refresh: AMRefresh) {
        switch refresh.style {
        case .header:
            DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                refresh.endRefreshing()
                self.count = 16
                self.tableView.reloadData()
            }
        case .footer:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                refresh.endRefreshing()
                self.count += 10
                self.tableView.reloadData()
            }
        }
    }
}
extension TableViewController:UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        200
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(Cell.self, for: indexPath)
        cell.index = indexPath.row
        return cell
    }
}
class Cell: UITableViewCell,AMReusableCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .white
        self.textLabel?.textColor = .red
        self.separatorInset = .zero
    }
    var index:Int = 0 {
        didSet{
            self.textLabel?.text = "\(index)"
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

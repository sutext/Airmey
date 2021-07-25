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
        let indicator = AMGifIndicator(images)
        self.tableView.am.edge.equal(top: navbar.height, left: 0, bottom: 0, right: 0)
        self.tableView.using(refresh: AMRefreshHeader(indicator))
        self.tableView.register(Cell.self)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.count = 20
            self.tableView.reloadData()
        }
    }
    
}
extension TableViewController:AMTableViewDelegate{
    func tableView(_ tableView: UITableView, willBegin refresh: AMRefresh) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2){
            refresh.endRefreshing()
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

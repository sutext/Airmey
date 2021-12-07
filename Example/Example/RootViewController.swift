//
//  RootViewController.swift
//  Example
//
//  Created by supertext on 2021/5/30.
//

import UIKit
import Airmey

var root:RootViewController? = nil
class RootViewController: AMLayoutViewContrller {
    let tabbarController:UITabBarController = UITabBarController()
    init() {
        super.init(rootViewController: tabbarController)
        self.leftDisplayMode = .cover
        root = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        let table = UINavigationController(rootViewController: TableViewController())
        let popup = UINavigationController(rootViewController: PopupController())
        let json = UINavigationController(rootViewController: TestJsonController())
        let widget = UINavigationController(rootViewController: WidgetsController())
        let coreData = UINavigationController(rootViewController: CoreDataController())
        table.setNavigationBarHidden(true, animated: false)
        popup.setNavigationBarHidden(true, animated: false)
        json.setNavigationBarHidden(true, animated: false)
        widget.setNavigationBarHidden(true, animated: false)
        self.tabbarController.viewControllers = [table,popup,json,widget,coreData]
        self.leftViewController = NetowrkController()
    }
    func push(_ controller:UIViewController)  {
        self.dismissCurrentController(animated: false)
        if let nav = self.tabbarController.selectedViewController as? UINavigationController {
            nav.pushViewController(controller, animated: true)
        }
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        [.landscapeRight,.portrait]
    }
    override var shouldAutorotate: Bool { true } 
}

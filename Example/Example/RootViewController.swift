//
//  RootViewController.swift
//  Example
//
//  Created by supertext on 2021/5/30.
//

import UIKit
import Airmey

class RootViewController: AMLayoutViewContrller {
    let tabbarController:UITabBarController = UITabBarController()
    init() {
        super.init(rootViewController: tabbarController)
        self.leftDisplayMode = .cover
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        let popup = UINavigationController(rootViewController: PopupController())
        let json = UINavigationController(rootViewController: TestJsonController())
        let widget = UINavigationController(rootViewController: WidgetsController())
        self.tabbarController.viewControllers = [popup,json,widget]
        self.leftViewController = NetowrkController()
    }
}

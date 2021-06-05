//
//  RootViewController.swift
//  Example
//
//  Created by supertext on 2021/5/30.
//

import UIKit

class RootViewController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        let popup = UINavigationController(rootViewController: PopupController())
        let network = UINavigationController(rootViewController: NetowrkController())
        let json = UINavigationController(rootViewController: TestJsonController())
        self.viewControllers = [popup,network,json]
    }
}

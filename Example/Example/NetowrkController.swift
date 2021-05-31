//
//  ViewController.swift
//  Example
//
//  Created by supertext on 5/27/21.
//

import UIKit
import Airmey
class NetowrkController: UIViewController {
    let stackView = UIStackView()
    init() {
        super.init(nibName: nil, bundle: nil)
        self.tabBarItem = UITabBarItem(title: "Network", image: .round(.blue, radius: 10), selectedImage: .round(.red, radius: 10))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Network Tester"
        self.view.addSubview(self.stackView)
        self.stackView.axis = .vertical
        self.stackView.alignment = .leading
        self.stackView.distribution = .equalCentering
        self.stackView.spacing = 20
        self.stackView.am.center.equal(to: 0)
        self.addTest("Test Popup") {
            pop.remind("test1")
            pop.action(["apple","facebook"])
            pop.remind("testing....")
            pop.alert("test1test1test1test1test1test1test1test1test1test1test1test1test1test1test1testest1test1test1test1test1test1test1test1test1test1test1test1test1test1test1testest1test1test1test1test1test1test1test1test1test1test1test1test1test1test1tes")
            pop.alert("test1test1test1test1test1test1test1test1test1test1test1test1test1test1test1testest1test1test1test1test1test1test1test1test1test1test1test1test1test1test1testest1test1test1test1test1test1test1test1test1test1test1test1test1test1test1tes")

            pop.action(["facebook","apple"])
            pop.wait("loading...")
            pop.idle()
        }
        self.addTest("Test Present") {
            self.present(NetowrkController(), animated: true, completion: nil)
        }
    }
    func addTest(_ text:String,action:(()->Void)?) {
        let imageLabel = AMImageLabel(.left)
        imageLabel.image = .round(.red, radius: 5)
        imageLabel.text = text
        imageLabel.font = .systemFont(ofSize: 17)
        imageLabel.textColor = .black
        self.stackView.addArrangedSubview(imageLabel)
        imageLabel.onclick = {_ in
            action?()
        }
    }
}


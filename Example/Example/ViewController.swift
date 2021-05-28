//
//  ViewController.swift
//  Example
//
//  Created by supertext on 5/27/21.
//

import UIKit
import Airmey
let pop = AMPopup()
class ViewController: UIViewController {
    let imageLabel:AMImageLabel = .init()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        imageLabel.text = "Test Remind"
        imageLabel.font = .systemFont(ofSize: 17)
        imageLabel.textColor = .black
        self.view.addSubview(imageLabel)
        imageLabel.am.center.equal(to: 0)
        imageLabel.onclick = {_  in
            pop.remind("test")
        }
//        var image:UIImage? = .gradual(.zero, points: .xmin(.red),.xmax(.blue))
        // Do any additional setup after loading the view.
    }
}


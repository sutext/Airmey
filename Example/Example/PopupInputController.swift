//
//  PopupInputController.swift
//  Example
//
//  Created by supertext on 12/20/21.
//

import UIKit
import Airmey

class PopupInputController: AMPopupController {
    let textFied = UITextField()
    init() {
        super.init(AMDimmingPresenter())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.view.addSubview(textFied)
        textFied.placeholder = "请输入文字"
        textFied.amake { am in
            am.size.equal(to: (300,50))
            am.center.equal(to: 0)
        }
        textFied.becomeFirstResponder()
        // Do any additional setup after loading the view.
    }

}

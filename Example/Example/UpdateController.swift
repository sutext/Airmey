//
//  UpdateController.swift
//  Example
//
//  Created by supertext on 5/31/21.
//

import UIKit
import Airmey

class UpdateController: AMPopupController {
    let contentView = AMEffectView(.light)
    let stackView = UIStackView()
    init() {
        super.init(AMDimmingPresenter())
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.contentView)
        self.contentView.addSubview(self.stackView)
        self.stackView.axis = .vertical
        self.stackView.alignment = .center
        self.stackView.distribution = .equalSpacing
        self.stackView.spacing = 20
        self.contentView.cornerRadius = 5
        self.contentView.clipsToBounds = true
        self.stackView.am.edge.equal(top: 20, left: 15, bottom: -15, right: -10)
        let label = AMLabel()
        label.text = "这是演示标题"
        label.textColor = .blue
        self.stackView.addArrangedSubview(label)
        
        let meaageLabel = AMLabel()
        meaageLabel.text = "这是演示内容这是演示内容这是演示内容这是演示内容这是演示内容这是演示内容这是演示内容这是演示内容这是演示内容这是演示内容这是演示内容这是演示内容这是演示内容这是演示内容这是演示内容这是演示内容"
        meaageLabel.numberOfLines = 10
        meaageLabel.textColor = .blue
        self.stackView.addArrangedSubview(meaageLabel)
        self.contentView.amake { am in
            am.width.equal(to: .screenWidth*0.75)
            am.center.equal(to: 0)
        }
        self.addTest("Test Dismiss"){
            pop.dismiss(self)
        }
        self.addTest("Test Alert"){
            pop.alert("Do you want to delete this boy?",title: "Waring...",confirm: "Confirm",cancel: "Cancel")
        }
        self.addTest("Test Clear") {
            pop.clear()
        }
        self.addTest("Test wait") {
            pop.wait("loading ...")
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                pop.idle()
                pop.remind("Loading Ok")
            }
        }
        self.presenter.onMaskClick={
            self.dismiss(animated: true)
        }
        
    }
    func addTest(_ text:String,action:(()->Void)? = nil) {
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

//
//  PopupTestController.swift
//  Example
//
//  Created by supertext on 2021/5/30.
//

import UIKit
import Airmey
let pop = PopupCenter()
public class PopupCenter:AMPopupCenter{
    public override class var Alert: AMAlertable.Type{AMAlertController.self}
    public override class var Action: AMActionable.Type{AMActionController.self}
}
class PopupController: UIViewController {
    init() {
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .fullScreen
        self.tabBarItem = UITabBarItem(title: "Popup", image: .round(.yellow, radius: 10), selectedImage: .round(.cyan, radius: 10))
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    let stackView = UIStackView()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.title = "Popup Tester"
        self.view.addSubview(self.stackView)
        self.stackView.axis = .vertical
        self.stackView.alignment = .leading
        self.stackView.distribution = .equalSpacing
        self.stackView.spacing = 20
        self.stackView.am.center.equal(to: 0)
        self.addTest("Test multiple popup") {
            pop.wait("loading....")
            pop.idle()
            pop.remind("test1")
            pop.action(["apple","facebook"])
            pop.action(["facebook","apple"])
            pop.remind("testing....")
            pop.alert("test alert",confirm: "确定",cancel: "取消")
            pop.alert("test1test1test1test1test1test1test1test1test1test1test1test1test1test1test1testest1test1test1test1test1test1test1test1test1test1test1test1test1test1test1testest1test1test1test1test1test1test1test1test1test1tes")
            pop.present(self)

        }
        self.addTest("Test Present") {
            pop.present(UpdateController())
        }
        self.addTest("clear") {
            pop.clear()
        }
        self.addTest("Test Wait") {
            pop.wait("loading...")
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                pop.idle()
            }
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


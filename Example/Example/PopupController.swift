//
//  PopupTestController.swift
//  Example
//
//  Created by supertext on 2021/5/30.
//

import UIKit
import Airmey
let pop = PopupCenter()

enum LoginError:Error {
    case invalidPassword
    case invalidUsername
}
extension LoginError:AMTextDisplayable{
    var displayText: AMDisplayText{
        switch self {
        case .invalidPassword:
            return "密码不正确"
        case .invalidUsername:
            return "用户不存在"
        }
    }
}
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
    let scrollView = UIScrollView()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.view.addSubview(self.scrollView)
        self.scrollView.backgroundColor = .white
        self.scrollView.contentInsetAdjustmentBehavior = .never
        navbar.title = "Popup Tester"
        self.scrollView.contentInset = UIEdgeInsets(top: .navbarHeight, left: 0, bottom: .tabbarHeight, right: 0)
        self.scrollView.am.edge.equal(to: 0)
        let images = (1...45).compactMap {
            UIImage(named: String(format: "loading%02i", $0), in: .main, compatibleWith: nil)
        }
        self.scrollView.using(refresh: AMRefreshHeader(.gif(images)))
        self.scrollView.addSubview(self.stackView)
        self.scrollView.delegate = self
        self.stackView.backgroundColor = .white
        self.stackView.axis = .vertical
        self.stackView.alignment = .leading
        self.stackView.distribution = .equalSpacing
        self.stackView.spacing = 20
        self.stackView.amake { am in
            am.center.equal(to: 0)
            am.edge.equal(top: 0, bottom: 0)
        }
        self.addTest("Test multiple popup") {
            pop.alert("test alert",confirm: "确定",cancel: "取消")

            pop.alert("test alert",confirm: "确定",cancel: "取消")

            pop.alert("test alert",confirm: "确定",cancel: "取消")

            pop.wait("loading....")
            pop.idle()
            pop.remind("test1")
//            pop.action(["apple","facebook"])
            pop.action(["facebook","apple"])
            pop.remind("testing....")
            pop.alert("test alert",confirm: "确定",cancel: "取消")
            pop.alert("test1test1test1test1test1test1test1test1test1test1test1test1test1test1test1testest1test1test1test1test1test1test1test1test1test1test1test1test1test1test1testest1test1test1test1test1test1test1test1test1test1tes")
            pop.remind(LoginError.invalidUsername)

        }
        self.addTest("Test Present") {
            pop.action(["test"])
//            pop.present(UpdateController())
        }
        self.addTest("clear") {
            pop.clear()
        }
        self.addTest("Test Wait") {
            pop.wait("loading...")
//            pop.idle()
        }
        self.addTest("Test remind") {
            pop.remind("test remind")
            
            pop.remind("test1test1test1test1test1test1test1test1test1test1test1test1test1test1test1testest1test1test1test1test1test1test1test1test1test1test1test1test1test1test1testest1test1test1test1test1test1test1test1test1test1tes")
            pop.remind("test remind")
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

extension PopupController:AMScrollViewDelegate{
    func scrollView(_ scrollView: UIScrollView, willBegin refresh: AMRefresh) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5){
            refresh.endRefreshing()
        }
    }
}

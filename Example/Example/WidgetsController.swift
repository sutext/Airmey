//
//  WidgetsController.swift
//  Example
//
//  Created by supertext on 6/15/21.
//

import UIKit
import Airmey


class WidgetsController: UIViewController {
    let contentView = AMEffectView(.light)
    let stackView = UIStackView()

    init() {
        super.init(nibName: nil, bundle: nil)
        self.tabBarItem = UITabBarItem(title: "Widgets", image: .round(.blue, radius: 10), selectedImage: .round(.red, radius: 10))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(contentView)
        self.contentView.addSubview(self.stackView)
        self.contentView.am.edge.equal(to: 0)
        self.stackView.axis = .vertical
        self.stackView.alignment = .leading
        self.stackView.distribution = .equalCentering
        self.stackView.spacing = 20
        self.stackView.am.center.equal(to: 0)
        self.addTest("测试swiper") {[weak self] in
            self?.navigationController?.pushViewController(SwiperController(), animated: true)
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

//
//  AMRemindController.swift
//  Airmey
//
//  Created by supertext on 5/28/21.
//

import UIKit

open class AMRemindController: AMPopupController ,AMRemindable{
    private lazy var blurView:UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor(white: 0, alpha: 0.6)
        view.layer.cornerRadius = 5
        return view;
    }()
    private lazy var messageLabel:AMLabel = {
        let label = AMLabel()
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    public required init(_ msg: String, title: String? = nil) {
        super.init(AMFadeinPresenter())
        self.messageLabel.text = msg
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        self.view.addSubview(self.blurView)
        self.blurView.addSubview(self.messageLabel)
        self.messageLabel.am.center.equal(to: 0)
        self.blurView.amake{
            $0.size.equal(to: (200,80))
            $0.center.equal(to: 0)
        }
    }
}

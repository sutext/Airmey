//
//  AMAlertController.swift
//  Airmey
//
//  Created by supertext on 2021/5/29.
//

import UIKit

/// A system like alert controller
open class AMAlertController: AMPopupController,AMAlertable {
    public let contentView = AMEffectView(.light)
    public let titleLabel = UILabel()
    public let messageLabel = UILabel()
    public let buttonStack = UIStackView()
    private var onhide:AMPopupCenter.AlertHide?
    public required init(_ msg: String, title: String?, confirm: String?, cancel: String?, onhide: AMPopupCenter.AlertHide?) {
        super.init(AMDimmingPresenter())
        self.titleLabel.text = title ?? "Alert"
        self.messageLabel.text = msg
        self.onhide = onhide
        self.addButton(confirm ?? "Confirm",index:0)
        if let cancel = cancel {
            self.addButton(cancel, index: 1)
        }
    }
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func addButton(_ text:String,index:Int){
        let button = AMLabel()
        button.text = text
        button.textColor = .blue
        button.textAlignment = .center
        self.buttonStack.addArrangedSubview(button)
        button.onclick = {_ in
            self.dismiss(animated: true)
            self.onhide?(index)
        }
    }
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.contentView)
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.messageLabel)
        self.contentView.addSubview(self.buttonStack)
        self.titleLabel.textColor = .black
        self.messageLabel.textColor = .darkGray
        self.messageLabel.numberOfLines = 999
        self.buttonStack.axis = .horizontal
        self.buttonStack.distribution = .fillEqually
        self.buttonStack.alignment = .fill
        self.contentView.clipsToBounds = true
        self.contentView.cornerRadius = 10
        self.messageLabel.textAlignment = .center
        
        self.contentView.amake { am in
            am.width.equal(to: .screenWidth * 0.75)
            am.center.equal(to: 0)
        }
        self.titleLabel.amake { am in
            am.centerX.equal(to: 0)
            am.centerY.equal(to: self.contentView.am.top,offset: 25)
        }
        self.messageLabel.amake { am in
            am.top.equal(to: 50)
            am.bottom.equal(to: -50)
            am.centerX.equal(to: 0)
            am.height.greater(than: 35)
            am.width.less(than: self.contentView.am.width,offset: -30)
        }
        self.buttonStack.amake { am in
            am.edge.equal(left: 0, bottom: 0, right: 0)
            am.height.equal(to: 50)
        }
    }
}


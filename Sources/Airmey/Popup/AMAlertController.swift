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
    public let stackView = UIStackView()
    public let titleLabel = UILabel()
    public let messageLabel = UILabel()
    public let buttonStack = UIStackView()
    private var onhide:AMPopupCenter.AlertHide?
    public required init(_ msg: String, title: String?, confirm: String?, cancel: String?, onhide: AMPopupCenter.AlertHide?) {
        super.init(AMDimmingPresenter())
        self.titleLabel.text = title
        self.messageLabel.text = msg
        self.onhide = onhide
        self.addButton(confirm ?? "Confirm",index:0)
        if let cancel = cancel {
            self.addButton(cancel, index: 1)
        }
        self.presenter.onMaskClick = nil
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
        button.onclick = {[weak self] _ in
            self?.dismiss(animated: true)
            self?.onhide?(index)
        }
    }
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.contentView)
        self.contentView.addSubview(self.stackView)
        self.stackView.addArrangedSubview(self.titleLabel)
        self.stackView.addArrangedSubview(self.messageLabel)
        self.stackView.addArrangedSubview(self.buttonStack)
        self.contentView.backgroundColor = UIColor(white: 1, alpha: 0.9)
        self.stackView.axis = .vertical
        self.stackView.distribution = .equalSpacing
        self.stackView.alignment = .center
        self.stackView.spacing = 8
        
        self.titleLabel.textColor = .black
        self.messageLabel.textColor = .darkGray
        self.messageLabel.numberOfLines = 15
        self.buttonStack.axis = .horizontal
        self.buttonStack.distribution = .fillEqually
        self.buttonStack.alignment = .fill
        self.contentView.clipsToBounds = true
        self.contentView.cornerRadius = 8
        self.messageLabel.textAlignment = .center
        self.contentView.amake { am in
            am.width.equal(to: .screenWidth * 0.75)
            am.center.equal(to: 0)
        }
        self.stackView.am.edge.equal(top: 10, left: 0, bottom: 0, right: 0)
        self.messageLabel.amake { am in
            am.height.greater(than: 35)
            am.width.less(than: self.stackView,offset: -30)
        }
        self.buttonStack.amake { am in
            am.edge.equal(left: 0, right: 0)
            am.height.equal(to: 48)
        }
    }
}


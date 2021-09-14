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
    public let onhide:AMAlertBlock?
    public required init(
        _ msg: AMTextDisplayable,
        title: AMTextDisplayable?,
        confirm: AMTextDisplayable?,
        cancel: AMTextDisplayable?,
        onhide: AMAlertBlock?) {
        self.onhide = onhide
        super.init(AMDimmingPresenter())
        self.titleLabel.displayText = title
        self.messageLabel.displayText = msg
        self.buttonStack.addArrangedSubview(self.confirmLabel)
        self.confirmLabel.displayText = confirm ?? "Confirm"
        self.confirmLabel.onclick = {[weak self] _ in
            self?.clicked(at: 0)
        }
        if let cancel = cancel {
            let line = UIView()
            line.backgroundColor = .hex(0xbbbbbb,alpha:0.7)
            line.am.size.equal(to: (0.5,48))
            self.buttonStack.addSubview(line)
            line.am.center.equal(to: 0)
            self.buttonStack.addArrangedSubview(self.cancelLabel)
            self.cancelLabel.displayText = cancel
            self.cancelLabel.onclick = {[weak self] _ in
                self?.clicked(at: 1)
            }
        }
        self.presenter.onMaskClick = nil
    }
    private func clicked(at index:Int){
        self.dismiss(animated: true)
        self.onhide?(index)
    }
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.contentView)
        self.contentView.addSubview(self.stackView)
        self.stackView.addArrangedSubview(self.titleLabel)
        self.stackView.addArrangedSubview(self.messageLabel)
        self.stackView.addArrangedSubview(self.buttonStack)
        self.buttonStack.addSubview(self.separator)
        self.contentView.backgroundColor = UIColor(white: 1, alpha: 0.9)
        self.stackView.axis = .vertical
        self.stackView.distribution = .equalSpacing
        self.stackView.alignment = .center
        self.stackView.spacing = 12
        
        self.titleLabel.textColor = .hex(0x2389f9)
        self.messageLabel.textColor = .darkGray
        self.messageLabel.numberOfLines = 15
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
        self.stackView.am.edge.equal(top: 10, left: 0, bottom: 0, right: 0)
        self.separator.amake { am in
            am.edge.equal(top: 0, left: 0, right: 0)
            am.height.equal(to: 0.5)
        }
        self.messageLabel.amake { am in
            am.height.greater(than: 35)
            am.width.less(than: self.stackView,offset: -30)
        }
        self.buttonStack.amake { am in
            am.edge.equal(left: 0, right: 0)
            am.height.equal(to: 48)
        }
        self.contentView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 20) {
                self.contentView.transform = .identity
            }
        }
    }
    private lazy var separator:UIView = {
        let line = UIView()
        line.backgroundColor = .hex(0xbbbbbb,alpha:0.7)
        return line
    }()
    public lazy var confirmLabel:AMLabel = {
        let button = AMLabel()
        button.textColor = .hex(0x2389f9)
        button.textAlignment = .center
        return button
    }()
    public var cancelLabel:AMLabel = {
        let button = AMLabel()
        button.textColor = .hex(0x2389f9)
        button.textAlignment = .center
        return button
    }()
}


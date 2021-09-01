//
//  AMWaitiController.swift
//  Airmey
//
//  Created by supertext on 5/28/21.
//

import UIKit

open class AMWaitController: AMPopupController,AMWaitable {
    open class var timeout:TimeInterval{ 10 }
    public lazy var blurView:UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor(white: 0, alpha: 0.6)
        view.layer.cornerRadius = 5
        return view;
    }()
    public lazy var titleLabel:AMLabel = {
        let label = AMLabel()
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    public lazy var indicator:UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .whiteLarge)
        view.startAnimating()
        return view
    }()
    public lazy var stackView:UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .center
        view.distribution = .equalSpacing
        view.spacing = 10
        return view
    }()
    required public init(_ msg:String?,timeout:TimeInterval?) {
        super.init(AMDimmingPresenter())
        self.presenter.dimming = 0
        self.presenter.onMaskClick = nil
        let timeout = timeout ?? Self.timeout
        DispatchQueue.main.asyncAfter(deadline: .now()+timeout) {
            self.presenter.onMaskClick = {[weak self] in
                self?.dismiss(animated: true)
            }
        }
        self.titleLabel.text = msg
    }
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        self.view.addSubview(self.blurView)
        self.blurView.addSubview(self.stackView)
        self.stackView.addArrangedSubview(self.indicator)
        self.stackView.addArrangedSubview(self.titleLabel)
        self.blurView.amake { (am) in
            am.size.equal(to: (170,100))
            am.center.equal(to: 0)
        }
        self.stackView.am.center.equal(to: 0)
    }
}

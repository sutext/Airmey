//
//  AMWaitiController.swift
//  Airmey
//
//  Created by supertext on 5/28/21.
//

import UIKit

open class AMWaitController: AMPopupController,AMWaitable {
    /// Global default timeout interval `default` 5
    /// subclass can override this var for custom
    open class var timeout:TimeInterval{ 5 }
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
        super.init(Presenter())
        self.presenter.dimming = 0
        self.presenter.onMaskClick = nil
        let timeout = timeout ?? Self.timeout
        DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
            self.dismiss(animated: true)
        }
        self.titleLabel.text = msg
    }
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    open override func viewDidLoad() {
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
extension AMWaitController{
    class Presenter: AMPresenter {
        private lazy var dimmingView:AMView = {
            let view = AMView()
            view.onclick = {[weak self] _ in
                self?.onMaskClick?()
            }
            return view;
        }()
        override func presentWillBegin(in pc: UIPresentationController) {
            guard let container = pc.containerView else {
                return
            }
            guard let presentView = pc.presentedView else {
                return
            }
            dimmingView.frame = presentView.bounds
            presentView.insertSubview(dimmingView, at: 0)
            container.addSubview(presentView)
        }
        override func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
            0
        }
        override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
            transitionContext.completeTransition(true)
        }
    }
}

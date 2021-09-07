//
//  AMRemindController.swift
//  Airmey
//
//  Created by supertext on 5/28/21.
//

import UIKit

/// Default buildin Remind appearence
open class AMRemindController: AMPopupController ,AMRemindable{
    public lazy var blurView:UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor(white: 0, alpha: 0.7)
        view.layer.cornerRadius = 5
        return view;
    }()
    public lazy var messageLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 17)
        return label
    }()
    public required init(
        _ msg: AMTextDisplayable,
        title: AMTextDisplayable? = nil) {
        super.init(AMDimmingPresenter())
        self.presenter.dimming = 0
        self.presenter.onMaskClick = nil
        self.messageLabel.displayText = msg
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        self.view.addSubview(self.blurView)
        self.blurView.addSubview(self.messageLabel)
        self.messageLabel.numberOfLines = 15
        self.blurView.amake{
            $0.width.greater(than: 210)
            $0.center.equal(to: 0)
        }
        self.messageLabel.amake { am in
            am.width.less(than: .screenWidth * 0.8)
            am.height.greater(than: 45)
            am.edge.equal(top:20,left: 15 , bottom: -20,right: -15 )
        }
    }
}

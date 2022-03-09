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
        view.am.width.greater(than: 210)
        view.layer.cornerRadius = 8
        view.addSubview(messageLabel)
        messageLabel.am.edge.equal(top:messageInset.top,left: messageInset.left , bottom: -messageInset.bottom,right: -messageInset.right)
        return view;
    }()
    public lazy var messageLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 17)
        label.numberOfLines = 15
        return label
    }()
    public required init(_ msg: AMTextDisplayable,
                         title: AMTextDisplayable?,
                         inset: UIEdgeInsets?,
                         position: RemindPosition?) {
        super.init(AMDimmingPresenter())
        self.presenter.dimming = 0
        self.presenter.onMaskClick = nil
        self.messageLabel.displayText = msg
        if let inset = inset {
            self.messageInset = inset
        }
        if let position = position {
            self.position = position
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        self.view.addSubview(self.blurView)
        blurView.am.centerX.equal(to: 0)
        if position == .middle {
            blurView.am.centerY.equal(to: 0)
        }else{
            blurView.am.bottom.equal(to: -(.footerHeight + 32))
        }
    }
    
    private var position: RemindPosition = .middle
    
    private var messageInset: UIEdgeInsets = .init(top: 20, left: 15, bottom: 20, right: 15)
}

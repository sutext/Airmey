//
//  AMKeyboardController.swift
//  Airmey
//
//  Created by supertext on 2020/10/21.
//  Copyright © 2020年 airmey. All rights reserved.
//

import UIKit

open class AMKeyboardController: UIInputViewController {
    public private(set) var textView:UITextView
    private var keyboards:[AMKeyboardIdentifer:AMKeyboard] = [:]
    private var metaKeyboards:[AMKeyboardIdentifer:AMKeyboard.Type] = [:]
    public private(set) var current:AMKeyboard?
    public weak var delegate:AMKeyboardDelegate?
    public init(_ textView:UITextView){
        self.textView = textView
        super.init(nibName: nil, bundle: nil)
        self.textView.delegate = self
        self.textView.contentInsetAdjustmentBehavior = .never
        self.extendedLayoutIncludesOpaqueBars = false
    }
    required public init?(coder aDecoder: NSCoder) {
        return nil
    }
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.inputView?.frame = CGRect(x: 0, y: 0, width: .screenWidth, height: 176 + .tabbarHeight)
    }
    public func register(_ type:AMKeyboard.Type){
        self.metaKeyboards[type.id] = type
    }
    public func `switch`(to type:AMKeyboardType){
        switch type {
        case .system:
            guard let old = self.current else{
                return
            }
            self.current = nil
            self.textView.inputView = nil
            self.textView.reloadInputViews()
            UIView.animate(withDuration: 0.25, animations: {
                old.alpha = 0
            }, completion: { (finished) in
                old.removeFromSuperview()
            })
        case .custom(let id):
            guard let board = self.keyboard(for: id) else{
                return
            }
            guard self.current !== board else{
                return
            }
            board.alpha = 0
            self.view.addSubview(board)
            let old = self.current
            self.current = board
            self.textView.inputView = self.view
            self.textView.reloadInputViews()
            UIView.animate(withDuration: 0.25, animations: {
                old?.alpha = 0
                board.alpha = 1
            }, completion: { (finished) in
                old?.removeFromSuperview()
            })
        }
    }
    private func keyboard(for id:AMKeyboardIdentifer) -> AMKeyboard?{
        guard let metaType = self.metaKeyboards[id] else{
            return nil
        }
        if let keyboard = self.keyboards[id] {
            return keyboard
        }
        let newone = metaType.init()
        newone.frame = self.view.bounds
        newone.delegate = self
        self.keyboards[id] = newone
        return newone
    }
    open func presentKeyboard(){
        self.textView.becomeFirstResponder()
    }
}

extension AMKeyboardController:AMKeyboardDelegate{
    public func keyboard(_ keyboard: AMKeyboard?, didTrigger action: AMKeyboardAction) {
        switch action {
        case .input(let text):
            self.textDocumentProxy.insertText(text)
        case .backward:
            self.textDocumentProxy.deleteBackward()
        case .complete:
            self.delegate?.keyboard(keyboard, didTrigger: action)
            self.textView.text = ""
        case .custom:
            self.delegate?.keyboard(keyboard, didTrigger: action)
        }
    }
}
extension AMKeyboardController : UITextViewDelegate
{
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        switch text {
        case "\n":
            self.delegate?.keyboard(self.current, didTrigger: .complete)
            textView.text = ""
            return false
        case "":
            self.delegate?.keyboard(self.current, didTrigger: .backward)
            return true
        default:
            self.delegate?.keyboard(self.current, didTrigger: .input(text: text))
        }
        return true;
    }
}

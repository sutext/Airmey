//
//  AMDigitLabel.swift
//  Airmey
//
//  Created by supertext on 2021/6/15.
//  Copyright © 2021年 airmey. All rights reserved.
//

import UIKit

/// rolling number label
/// It will auto rolling when update digit
final public class AMDigitLabel:AMLabel{
    public typealias Formater = (Int)->String
    public static var defaultFormater:Formater = { String($0) }
    private let rate:Double
    private var value:Int = 0
    private var step:Int = 0
    private var total:Int = 0
    private var goal:Int = 0
    private var stack:[Int] = []
    private let timer:AMTimer
    deinit {
        self.timer.stop()
    }
    /// Designed initialization for digit label
    /// - Parameters:
    ///     - frameRate:The animation update frequency
    ///
    public init(_ frameRate:Double = 30) {
        self.rate = frameRate
        self.timer = AMTimer(interval: 1.0/frameRate)
        self.formater = Self.defaultFormater
        super.init(frame: .zero)
        self.timer.delegate = self
    }
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /// Provide a number formater for digit label
    /// This function decide how  to display the digit number
    public var formater:Formater{
        didSet{
            self.text = self.formater(goal)
        }
    }
    /// The digit property.  User should not set `text` property directy.
    /// Set digit will update text automatic.
    /// if new value is greater than old then animation occurred.
    public var digit:Int{
        get{
            if stack.count>0 {
                return stack.last ?? 0
            }
            return goal
        }
        set{
            stack.append(newValue)
            next()
        }
    }
    private func next(){
        if step > 0 || stack.count == 0 {
            return
        }
        let goal = stack.remove(at: 0)
        if self.goal == goal {
            next()
            return
        }
        self.goal = goal;
        if value == 0 || value >= goal {
            setText(goal)
            next()
            return
        }
        let delta = Double(goal - value);
        step = (delta < rate ? 1 : Int(delta/rate));
        timer.start()
    }
    private func setText(_ value:Int){
        if self.value != value {
            self.value = value
            self.text = self.formater(value)
        }
    }
}
extension AMDigitLabel:AMTimerDelegate{
    public func timer(_ timer: AMTimer, repeated times: Int) {
        var v = value + step
        if v > goal {
            v = goal
        }
        setText(v)
        if v == goal {
            timer.stop()
            step = 0
            next()
        }
    }
}

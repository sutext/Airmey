//
//  AMDigitLabel.swift
//  Airmey
//
//  Created by supertext on 2021/6/15.
//  Copyright © 2021年 airmey. All rights reserved.
//

import UIKit

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
    public var formater:Formater{
        didSet{
            self.text = self.formater(self.goal)
        }
    }
    public var digit:Int{
        get{
            if self.stack.count>0 {
                return self.stack.last ?? 0
            }
            return self.goal
        }
        set{
            self.stack.append(newValue)
            self.next()
        }
    }
    private func next(){
        if (self.step > 0 || self.stack.count == 0) {
            return;
        }
        let goal = self.stack[0]
        self.stack .remove(at: 0)
        if (self.goal == goal) {
            self.next()
            return
        }
        self.goal = goal;
        if (self.value == 0 || self.value>=self.goal) {
            self.setText(goal)
        }else{
            let delta = Double(self.goal - self.value);
            self.step = delta < self.rate ? 1 : (Int)(delta/self.rate);
            self.timer.start()
        }
    }
    private func setText(_ value:Int){
        if (self.value == value) {
            return;
        }
        self.value = value;
        self.text = self.formater(value);
    }
}
extension AMDigitLabel:AMTimerDelegate{
    public func timer(_ timer: AMTimer, repeated times: Int) {
        var v = value + step
        if v > goal {
            v = goal
        }
        self.setText(v)
        if v == goal {
            step = 0
            self.next()
            self.timer.stop()
        }
    }
}

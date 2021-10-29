//
//  AMTimer.swift
//  Airmey
//
//  Created by supertext on 2020/11/23.
//  Copyright © 2020年 airmey. All rights reserved.
//

import Foundation

extension Thread{
    ///the Airmey inner deamon runloop use for timer etc
    ///you can not stop it
    public static let airmey:Thread = {
        let thread =  Thread(target: Airmey(), selector: #selector(Airmey.entry), object: nil)
        thread.start()
        return thread
    }()
    private class Airmey:NSObject{
        @objc func entry(){
            Thread.current.name = "com.airmey.thread.daemon"
            RunLoop.current.add(NSMachPort(), forMode: .default)
            RunLoop.current.run()
        }
    }
}

///the timer function
public protocol AMTimerDelegate:AnyObject{
    func timer(_ timer:AMTimer,repeated times:Int)
}
///wrap on NSTimer
///this is usefull for record repeat times for the timer
///in order to release itself, stop must be call after start
public class AMTimer :NSObject{
    private var timer:Timer?
    ///the timer work in Thread.main otherwise work in Thread.airmey
    public private(set) var thread:Thread
    ///the timeInterval for NSTimer default is 1
    public let interval:TimeInterval
    ///the repeats flag for NSTimer default is true
    public let repeats:Bool
    ///the current repate times after time runing increasing from zero
    public private(set) var times:Int = 0//reapeatTimes
    ///the AMTimer's delegate is different between NSTimer's target
    ///the NSTimer's target is AMTimer
    ///the AMTimer's delegate never retain
    public weak var delegate:AMTimerDelegate?
    ///create an AMTimer but not creat NSTimer. this is low consumed
    public init(interval:TimeInterval = 1,repeats:Bool = true,inMain:Bool = true) {
        self.thread = inMain ? .main : .airmey
        self.interval = interval
        self.repeats = repeats
    }
    ///this method is realy create an NSTimer and run it
    ///this method will result in retian circel between NSTimer and AMTimer
    ///when the timer is pausing start means resume
    ///the timer work in main runloop
    public var status:Status{
        guard let timer = self.timer else{
            return .stoped
        }
        guard timer.isValid else {
            return .stoped
        }
        guard timer.fireDate < Date() else {
            return .paused
        }
        return .running
    }
    public func start(){
        if self.thread == Thread.current{
            self.innerStart()
            return
        }
        self.perform(#selector(AMTimer.innerStart), on: thread, with: nil, waitUntilDone: true)
    }
    ///pause the timer but not be reset repate times
    public func pause(){
        if self.thread == Thread.current{
            self.innerPause()
            return
        }
        self.perform(#selector(AMTimer.innerPause), on: thread, with: nil, waitUntilDone: true)
    }
    ///releas NSTimer and reset repate times
    ///this method can break the retain circle between NSTimer and AMTimer
    ///this method is the only way to break retain circle
    public func stop(){
        if self.thread == Thread.current{
            self.innerStop()
            return
        }
        self.perform(#selector(AMTimer.innerStop), on: thread, with: nil, waitUntilDone: true)
    }
    
    @objc private func innerPause(){
        self.timer?.fireDate = .distantFuture
    }
    @objc private func innerStop(){
        self.timer?.invalidate()
        self.times = 0
        self.timer = nil
    }
    @objc private func innerStart(){
        if let tmer = self.timer,tmer.isValid{
            tmer.fireDate = Date()
            return
        }
        self.timer = Timer(timeInterval: interval, target: self, selector: #selector(AMTimer.timerFunction(sender:)), userInfo: nil, repeats: repeats)
        RunLoop.current.add(self.timer!, forMode: .common)
        self.timer?.fireDate = Date()
    }
    @objc private func timerFunction(sender:Timer){
        self.times = self.times + 1
        self.delegate?.timer(self, repeated: self.times)
    }
    public enum Status{
        case stoped
        case running
        case paused
    }
}


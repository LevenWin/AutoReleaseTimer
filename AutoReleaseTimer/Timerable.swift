//
//  Timerable.swift
//  niuwa
//
//  Created by leven on 2021/1/19.
//  Copyright © 2021 Knoala. All rights reserved.
//

import Foundation

protocol Timerable: class {
    func schedule(_ time: TimeInterval, ifRepeat: Bool, invoke: @escaping ((Timer) -> Void)) -> Timer
    var autoReleaseTimer: Timer? { get }
}

private class DeallocToken: NSObject {
    let invoke: (Timer) -> Void
    weak var timer: Timer?
    weak var target: AnyObject?
    init(invoke: @escaping (Timer) -> Void) {
        self.invoke = invoke
    }
    @objc func invokeAction() {
        if target == nil {
            timer?.invalidate()
            timer = nil
        } else if let t = timer {
            invoke(t)
        }
    }
    deinit {
        timer?.invalidate()
        timer = nil
    }
}

private var scheduleTimerKey: UInt8 = 0

extension Timerable {
    @discardableResult
    func schedule(_ time: TimeInterval, ifRepeat: Bool, invoke: @escaping ((Timer) -> Void)) -> Timer {
        let deallocToken = DeallocToken(invoke: invoke)
        let timer = Timer.init(timeInterval: time, target: deallocToken, selector: #selector(DeallocToken.invokeAction), userInfo: nil, repeats: ifRepeat)
        RunLoop.current.add(timer, forMode: RunLoop.Mode.common)
        deallocToken.timer = timer
        deallocToken.target = self
        objc_setAssociatedObject(self, &scheduleTimerKey, deallocToken, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return timer
    }
    
    var autoReleaseTimer : Timer? {
        if let token = objc_getAssociatedObject(self, &scheduleTimerKey) as? DeallocToken {
            return token.timer
        }
        return nil
    }
    
}

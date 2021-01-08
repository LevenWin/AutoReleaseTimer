//
//  Timerable.swift
//  AutoReleaseTimer
//
//  Created by leven on 2021/1/8.
//

import Foundation

protocol Timerable: class {
    func schedule(_ time: TimeInterval, ifRepeat: Bool, invoke: @escaping ((Timer) -> Void)) -> Timer
}

private class DeallocToken: NSObject {
    let invoke: (Timer) -> Void
    weak var timer: Timer?
    init(invoke: @escaping (Timer) -> Void) {
        self.invoke = invoke
    }
    @objc func invokeAction() {
        if let t = timer {
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
        RunLoop.current.add(timer, forMode: RunLoop.Mode.commonModes)
        deallocToken.timer = timer
        objc_setAssociatedObject(self, &scheduleTimerKey, deallocToken, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return timer
    }
}

//
//  ViewController.swift
//  AutoReleaseTimer
//
//  Created by leven on 2021/1/8.
//

import UIKit

class TimerTest: Timerable {
    var v = "1"
}

class ViewController: UIViewController {

    var timer = TimerTest()
    override func viewDidLoad() {
        super.viewDidLoad()
        timer.schedule(3, ifRepeat: true) { (timer) in
            print(timer)
        }
    }


}


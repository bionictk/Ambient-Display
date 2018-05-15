//
//  TimeoutController.swift
//  ambientDisplay
//
//  Created by Taeheon Kim on 5/14/18.
//  Copyright © 2018 Taeheon Kim. All rights reserved.
//

import EventKit

enum TimeoutControllerState {
    case idle, counting, paused, finished
}

class TimeoutController {
    
    var currentState: TimeoutControllerState = .idle
    var timer: Timer = Timer()
    let timeout: Int
    var timeRemaining: Int = 0
    
    init(timeout: Double) {
        self.timeout = Int(timeout)
        resetTimer()
    }
    
    func resetTimer() {
        currentState = .idle
        timer.invalidate()
        timeRemaining = 0
    }
    
    @objc func click() -> Bool { // returns whether button view should be updated periodically
        switch currentState {
        case .idle:
            // start countdown
            timeRemaining = timeout
            currentState = .counting
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
            return true
        case .counting:
            // pause timer
            timer.invalidate()
            currentState = .paused
            return false
        case .paused:
            // resume timer
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
            currentState = .counting
            return true
        case .finished:
            // reset timer
            resetTimer()
            return false
        }
    }
    
    @objc func updateTimer() {
        if (timeRemaining <= 0) {
            timer.invalidate()
            currentState = .finished
        } else if (currentState == .counting) {
            timeRemaining -= 1
        }
    }
    
    func getCurrentTime() -> Int {
        return timeRemaining
    }
    
    func getCurrentState() -> TimeoutControllerState {
        return currentState
    }

}

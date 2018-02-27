//
//  timeController.swift
//  test1
//
//  Created by Taeheon Kim on 1/23/18.
//  Copyright © 2018 Taeheon Kim. All rights reserved.
//

import Foundation

class TimeController {
    var timeFormatter = DateFormatter()
    var dateFormatter = DateFormatter()
    var date = Date()
    
    init() {
        timeFormatter.timeStyle = DateFormatter.Style.short
        dateFormatter.dateFormat = "E d"
    }
    
    func getCurrentTime() -> String {
        date = Date()
        return timeFormatter.string(from: date as Date)
    }
    
    func getCurrentDate() -> String {
        return dateFormatter.string(from: date as Date)
    }
}

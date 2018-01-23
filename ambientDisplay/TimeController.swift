//
//  timeController.swift
//  test1
//
//  Created by Taeheon Kim on 1/23/18.
//  Copyright © 2018 Taeheon Kim. All rights reserved.
//

import Foundation

class TimeController {
    var formatter = DateFormatter()
    
    init() {
        formatter.timeStyle = DateFormatter.Style.long
    }
    
    func getCurrentTime() -> String {
        let date = Date()
        return formatter.string(from: date as Date)
    }
}

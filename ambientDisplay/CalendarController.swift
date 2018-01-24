//
//  CalendarController.swift
//  ambientDisplay
//
//  Created by Taeheon Kim on 1/23/18.
//  Copyright © 2018 Taeheon Kim. All rights reserved.
//

import EventKit

class CalendarController {
    var eventList: [String] = []
    
    func getTableSize() -> Int {
        return eventList.count
    }
    
    func getTitle(index: Int) -> String {
        return eventList[index]
    }
    
    func updateCalendarEvents() {
        var startDates : [NSDate] = []
        var endDates : [NSDate] = []
        
        let eventStore = EKEventStore()
        let calendars = eventStore.calendars(for: .event)
        
        for calendar in calendars {
            if calendar.title == "Home" {
                
                let oneDayAgo = NSDate(timeIntervalSinceNow: -1*24*3600)
                let oneMonthAfter = NSDate(timeIntervalSinceNow: +30*24*3600)
                
                let predicate = eventStore.predicateForEvents(withStart: oneDayAgo as Date, end: oneMonthAfter as Date, calendars: [calendar])
                
                let events = eventStore.events(matching: predicate)
                
                for event in events {
                    eventList.append(event.title)
                    startDates.append(event.startDate! as NSDate)
                    endDates.append(event.endDate! as NSDate)
                }
            }
        }
        
        dump(eventList)
    }
}

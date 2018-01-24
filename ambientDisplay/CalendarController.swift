//
//  CalendarController.swift
//  ambientDisplay
//
//  Created by Taeheon Kim on 1/23/18.
//  Copyright © 2018 Taeheon Kim. All rights reserved.
//

import EventKit

class CalendarController {
    var listOfCandidateCalendars: [String] = ["Home", "Classes", "Family"]
    
    var eventList: [String] = []
    
    func getTableSize() -> Int {
        return eventList.count
    }
    
    func getTitle(index: Int) -> String {
        return eventList[index]
    }
    
    func updateCalendarEvents() {
        let eventStore = EKEventStore()
        let calendars = eventStore.calendars(for: .event)
        
        for calendar in calendars {
            if listOfCandidateCalendars.contains(calendar.title) {
                
                let oneDayAgo = NSDate(timeIntervalSinceNow: -1*24*3600)
                let oneDayAfter = NSDate(timeIntervalSinceNow: +1*24*3600)
                
                let predicate = eventStore.predicateForEvents(withStart: oneDayAgo as Date, end: oneDayAfter as Date, calendars: [calendar])
                
                let events = eventStore.events(matching: predicate)
                
                for event in events {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "HH:mm"
                    let formattedString = formatter.string(from: event.startDate)
                    eventList.append(formattedString + "\t  " + event.title)

                }
            }
        }
        
        eventList.sort()
    }
}

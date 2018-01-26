//
//  CalendarController.swift
//  ambientDisplay
//
//  Created by Taeheon Kim on 1/23/18.
//  Copyright © 2018 Taeheon Kim. All rights reserved.
//

import EventKit

class CalendarController {
    let listOfCandidateCalendars: [String] = ["Home", "Classes", "Family"]
    
    var eventList: [String] = []
    
    func getTableSize() -> Int {
        return eventList.count
    }
    
    func getTitle(index: Int) -> String {
        return eventList[index]
    }
    
    func updateCalendarEvents() {
        eventList.removeAll()
        let eventStore = EKEventStore()
        let calendars = eventStore.calendars(for: .event)
        
        let today = Date()
        let cal = Calendar.current
        let midnightToday = cal.startOfDay(for: today)
        let midnightTomorrow = midnightToday.addingTimeInterval(24*3600)
        let midnightDayAfterTomorrow = midnightTomorrow.addingTimeInterval(24*3600)
        
        for calendar in calendars {
            if listOfCandidateCalendars.contains(calendar.title) {
                var predicate: NSPredicate
                if areEventsFromToday() {
                    predicate = eventStore.predicateForEvents(withStart: midnightToday, end: midnightTomorrow, calendars: [calendar])
                } else {
                    predicate = eventStore.predicateForEvents(withStart: midnightTomorrow, end: midnightDayAfterTomorrow, calendars: [calendar])
                }
                
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
    
    func areEventsFromToday() -> Bool {
        let changeDateThreshold = Calendar.current.date(bySettingHour: 21, minute: 0, second: 0, of: Date())!
        return Date() <= changeDateThreshold
    }
}

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
    let changeDateThreshold: Date = Calendar.current.date(bySettingHour: 21, minute: 0, second: 0, of: Date())!
    
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
                let today = Date()
                let cal = Calendar.current
                let midnightToday = cal.startOfDay(for: today)
                let midnightTomorrow = midnightToday.addingTimeInterval(24*3600)
                let midnightDayAfterTomorrow = midnightTomorrow.addingTimeInterval(24*3600)
                
                var predicate = eventStore.predicateForEvents(withStart: midnightToday, end: midnightTomorrow, calendars: [calendar])
                if !areEventsFromToday() {
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
        return Date() <= changeDateThreshold
    }
}

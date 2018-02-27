//
//  ReminderController.swift
//  ambientDisplay
//
//  Created by Taeheon Kim on 2/27/18.
//  Copyright © 2018 Taeheon Kim. All rights reserved.
//

import EventKit

class ReminderController {
    let reminderTitle: String = "todo"
    
    let eventStore = EKEventStore()
    var reminder: EKCalendar?
    var predicate: NSPredicate?
    var eventList: [String] = []
    
    func getTableSize() -> Int {
        return eventList.count
    }
    
    func getTitle(index: Int) -> String {
        return eventList[index]
    }
    
    func updateReminderEvents() {
        eventList.removeAll()
        
        if reminder == nil {
            let reminders = eventStore.calendars(for: .reminder)
            for r in reminders {
                if (r.title == reminderTitle) {
                    reminder = r
                    predicate = eventStore.predicateForIncompleteReminders(withDueDateStarting: nil, ending: nil, calendars: [r])
                }
            }
        }
        
        if reminder != nil {
            
            eventStore.fetchReminders(matching: predicate!, completion: {reminderItems in
                for item in reminderItems! {
                    print(item.title)
                    
                }
                
            })
            
//            let formatter = DateFormatter()
//            formatter.dateFormat = "HH:mm"
//            let formattedString = formatter.string(from: event.startDate)
//            eventList.append(formattedString + "\t  " + event.title)
            
        }

    }

}

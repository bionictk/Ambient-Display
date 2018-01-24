//
//  ViewController.swift
//  test1
//
//  Created by Taeheon Kim on 1/22/18.
//  Copyright © 2018 Taeheon Kim. All rights reserved.
//

import UIKit
import EventKit

extension Notification.Name {
    static let errorChannel = Notification.Name("errorChannel")
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var currentTempLabel: UILabel!
    @IBOutlet weak var currentWeatherIcon: UIImageView!
    
    @IBOutlet weak var calendarTableView: UITableView!
    
    var timeController: TimeController = TimeController()
    var weatherController: WeatherController = WeatherController()
    var timeLabelTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Listener for errors
        // Usage: NotificationCenter.default.post(name: .errorChannel, object: "Error message.")
        NotificationCenter.default.addObserver(self, selector: #selector(setErrorMessage(notification:)), name: .errorChannel, object: nil)
        
        // Clear errors on tap
        let errorTap = UITapGestureRecognizer(target: self, action: #selector(clearErrorMessage))
        errorLabel.isUserInteractionEnabled = true
        errorLabel.addGestureRecognizer(errorTap)
        
        // Timer loop for clock
        timeLabelTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(updateTimeLabel), userInfo: nil, repeats: true)
        
        // Timer loop for current weather
        timeLabelTimer = Timer.scheduledTimer(timeInterval: 300, target: self, selector: #selector(updateCurrentWeather), userInfo: nil, repeats: true)
     
        // Init views
        updateTimeLabel()
        updateCurrentWeather()
        updateCalendarEvents()
    }

    @objc func setErrorMessage(notification: NSNotification) {
        errorLabel.text = (notification.object as! String)
    }

    @objc func clearErrorMessage() {
        errorLabel.text = ""
    }

    @objc func updateTimeLabel() {
        timeLabel.text = timeController.getCurrentTime()
    }
    
    @objc func updateCurrentWeather() {
        weatherController.getCurrentWeather(finished: { temp, icon in
            self.currentTempLabel.text = "Outside: \(temp)°C"
            self.currentWeatherIcon.image = icon
        })
    }
    
    @objc func updateCalendarEvents() {
        
        var titles : [String] = []
//        var startDates : [NSDate] = []
//        var endDates : [NSDate] = []
//
//        let eventStore = EKEventStore()
//        let calendars = eventStore.calendars(for: .event)
//
//        for calendar in calendars {
//            if calendar.title == "Work" {
//
//                let oneMonthAgo = NSDate(timeIntervalSinceNow: -30*24*3600)
//                let oneMonthAfter = NSDate(timeIntervalSinceNow: +30*24*3600)
//
//                let predicate = eventStore.predicateForEvents(withStart: oneMonthAgo as Date, end: oneMonthAfter as Date, calendars: [calendar])
//
//                let events = eventStore.events(matching: predicate)
//
//                for event in events {
//                    titles.append(event.title)
//                    startDates.append(event.startDate! as NSDate)
//                    endDates.append(event.endDate! as NSDate)
//                }
//            }
//        }
        titles = ["Item1", "Item 2", "Item number 3!!"]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let titles = ["Item1", "Item 2", "Item number 3!!"]
        let cell = tableView.dequeueReusableCell(withIdentifier: "CalendarCell")!
        
        cell.textLabel?.text = titles[indexPath.row]
        cell.detailTextLabel?.text = "details!!"
        cell.textLabel?.textColor = .white
        return cell
    }
}


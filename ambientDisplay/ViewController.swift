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

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var currentTempLabel: UILabel!
    @IBOutlet weak var currentWeatherIcon: UIImageView!
    
    @IBOutlet weak var calendarTopLabel: UILabel!
    @IBOutlet weak var calendarTableView: UITableView!
    @IBOutlet weak var reminderTableView: UITableView!
    
    var timeController: TimeController = TimeController()
    var weatherController: WeatherController = WeatherController()
    var calendarController: CalendarController = CalendarController()
    var reminderController: ReminderController = ReminderController()
    
    var clockUpdateTimer: Timer?
    var weatherUpdateTimer: Timer?
    var calendarUpdateTimer: Timer?
    var reminderUpdateTimer: Timer?
    
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
        clockUpdateTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(updateTimeLabel), userInfo: nil, repeats: true)
        
        // Timer loop for current weather
        weatherUpdateTimer = Timer.scheduledTimer(timeInterval: 935, target: self, selector: #selector(updateCurrentWeather), userInfo: nil, repeats: true)
        
        // Timer loop for calendar events
        calendarUpdateTimer = Timer.scheduledTimer(timeInterval: 300, target: self, selector: #selector(updateCalendarEvents), userInfo: nil, repeats: true)
     
        // Timer loop for reminder events
        reminderUpdateTimer = Timer.scheduledTimer(timeInterval: 7, target: self, selector: #selector(updateReminderEvents), userInfo: nil, repeats: true)
        
        // Init views
        updateTimeLabel()
        updateCurrentWeather()
        updateCalendarEvents()
        updateReminderEvents()
    }

    @objc func setErrorMessage(notification: NSNotification) {
        DispatchQueue.main.async {
            self.errorLabel.text = self.errorLabel.text! + "/" + (notification.object as! String)
        }
    }

    @objc func clearErrorMessage() {
        DispatchQueue.main.async {
            self.errorLabel.text = ""
        }
    }

    @objc func updateTimeLabel() {
        DispatchQueue.main.async {
            self.dateLabel.text = self.timeController.getCurrentDate()
            self.timeLabel.text = self.timeController.getCurrentTime()
        }
    }
    
    @objc func updateCurrentWeather() {
        weatherController.getCurrentWeather(finished: { tempC, tempF, icon in
            DispatchQueue.main.async {
                self.currentTempLabel.text = "\(tempC)°C / \(tempF)°F"
                self.currentWeatherIcon.image = icon
            }
        })
    }
    
    @objc func updateCalendarEvents() {
        let group = DispatchGroup()
        group.enter()
        calendarController.updateCalendarEvents(group: group)
        group.notify(queue: .global()) {
            DispatchQueue.main.async {
                if self.calendarController.areEventsFromToday() {
                    self.calendarTopLabel.text = "Today"
                } else {
                    self.calendarTopLabel.text = "Tomorrow"
                }
                self.calendarTableView.reloadData()
            }
        }
    }
    
    @objc func updateReminderEvents() {
        let group = DispatchGroup()
        group.enter()
        reminderController.updateReminderEvents(group: group)
        group.notify(queue: .global()) {
            DispatchQueue.main.async {
                self.reminderTableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Request access to calendar
        let eventStore = EKEventStore()
        eventStore.requestAccess(to: EKEntityType.event, completion: {
            (accessGranted: Bool, error: Error?) in
        })
        eventStore.requestAccess(to: EKEntityType.reminder, completion: {
            (accessGranted: Bool, error: Error?) in
        })
    }
    
    // table view controller functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == calendarTableView {
            return calendarController.getTableSize()
        } else {
            return reminderController.getTableSize()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == calendarTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CalendarCell")!
            
            cell.textLabel?.text = calendarController.getTitle(index: indexPath.row)
            //        cell.detailTextLabel?.text = "details!!"
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = UIFont.systemFont(ofSize: 20)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReminderCell")!
            
            cell.textLabel?.text = reminderController.getTitle(index: indexPath.row)
            //        cell.detailTextLabel?.text = "details!!"
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = UIFont.systemFont(ofSize: 20)
            return cell
        }
    }
    
}


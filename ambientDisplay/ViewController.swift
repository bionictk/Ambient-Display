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
    
    @IBOutlet weak var calendarTopLabel: UILabel!
    @IBOutlet weak var calendarTableView: UITableView!
    
    var timeController: TimeController = TimeController()
    var weatherController: WeatherController = WeatherController()
    var calendarController: CalendarController = CalendarController()
    
    var clockUpdateTimer: Timer?
    var weatherUpdateTimer: Timer?
    var calendarUpdateTimer: Timer?
    
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
     
        // Init views
        updateTimeLabel()
        updateCurrentWeather()
        updateCalendarEvents()
    }

    @objc func setErrorMessage(notification: NSNotification) {
        errorLabel.text = errorLabel.text! + "/" + (notification.object as! String)
    }

    @objc func clearErrorMessage() {
        errorLabel.text = ""
    }

    @objc func updateTimeLabel() {
        timeLabel.text = timeController.getCurrentTime()
    }
    
    @objc func updateCurrentWeather() {
        weatherController.getCurrentWeather(finished: { temp, icon in
            self.currentTempLabel.text = "Now: \(temp) °C"
            self.currentWeatherIcon.image = icon
        })
    }
    
    @objc func updateCalendarEvents() {
        calendarController.updateCalendarEvents()
        if calendarController.areEventsFromToday() {
            calendarTopLabel.text = "Today"
        } else {
            calendarTopLabel.text = "Tomorrow"
        }
        calendarTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calendarController.getTableSize()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CalendarCell")!
        
        cell.textLabel?.text = calendarController.getTitle(index: indexPath.row)
//        cell.detailTextLabel?.text = "details!!"
        cell.textLabel?.textColor = .white
        cell.textLabel?.font = UIFont.systemFont(ofSize: 20)
        return cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Request access to calendar
        let eventStore = EKEventStore()
        eventStore.requestAccess(to: EKEntityType.event, completion: {
            (accessGranted: Bool, error: Error?) in
        })
    }
    
}


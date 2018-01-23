//
//  ViewController.swift
//  test1
//
//  Created by Taeheon Kim on 1/22/18.
//  Copyright © 2018 Taeheon Kim. All rights reserved.
//

import UIKit

extension Notification.Name {
    static let errorChannel = Notification.Name("errorChannel")
}

class ViewController: UIViewController {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var currentTempLabel: UILabel!
    @IBOutlet weak var currentWeatherIcon: UIImageView!
    
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
}


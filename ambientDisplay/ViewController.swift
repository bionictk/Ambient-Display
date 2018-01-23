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
    
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var currentWeatherIcon: UIImageView!
    
    var timeController: TimeController = TimeController()
    var timeLabelTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Listener for errors
        // Usage: NotificationCenter.default.post(name: .errorChannel, object: "Error message.")
        NotificationCenter.default.addObserver(self, selector: #selector(setErrorMessage(notification:)), name: .errorChannel, object: nil)
        
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
    
    @objc func updateTimeLabel() {
        timeLabel.text = timeController.getCurrentTime()
    }
    
    @objc func updateCurrentWeather() {
        let session = URLSession.shared

        let weatherURL = URL(string: "https://api.openweathermap.org/data/2.5/weather?id=4180439&appid=29536689fa5bbed8e7e72f7d8dfc106c&units=metric")!

        let dataTask = session.dataTask(with: weatherURL) {
            (data: Data?, response: URLResponse?, error: Error?) in

            if error != nil {
                NotificationCenter.default.post(name: .errorChannel, object: "Weather: No response.")
            } else {
                if let data = data {
                    let dataString = String(data: data, encoding: String.Encoding.utf8)
                    print("Current weather data:\n\(dataString!)")

                    if let dictionary = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
                    
                        if let tempMain = dictionary!["main"] as? [String: Any]{
                            
                            let temperature = tempMain["temp"] as! Float
                            
                            DispatchQueue.main.async {
                                self.weatherLabel.text = "Current: \(temperature)°C"
                            }
                        }
                        
                        if let weatherArray = dictionary!["weather"] as? [Any] {
                            if weatherArray.count != 1 {
                                NotificationCenter.default.post(name: .errorChannel, object: "\(weatherArray.count) weather info!")
                            }
                            
                            let currentWeather = weatherArray[0] as? [String: Any]
                            
                            let url = URL(string: "https://openweathermap.org/img/w/" + (currentWeather!["icon"] as! String) + ".png")
                            let data = try? Data(contentsOf: url!)
                            self.currentWeatherIcon.image = UIImage(data: data!)
                        }
                        
                        
                    } else {
                        NotificationCenter.default.post(name: .errorChannel, object: "Weather: JSON parsing failed")
                    }
                } else {
                    NotificationCenter.default.post(name: .errorChannel, object: "Weather: No data received.")
                }
            }
        }
        
        dataTask.resume()
    }
}


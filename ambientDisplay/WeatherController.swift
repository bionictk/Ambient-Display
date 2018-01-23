//
//  CurrentWeatherController.swift
//  ambientDisplay
//
//  Created by Taeheon Kim on 1/23/18.
//  Copyright © 2018 Taeheon Kim. All rights reserved.
//

import UIKit

class WeatherController {
    
    var currentWeatherURL: String = "https://api.openweathermap.org/data/2.5/weather?id=4180439&appid=29536689fa5bbed8e7e72f7d8dfc106c&units=metric"
    
    func getCurrentWeather(finished: @escaping ((_ temp: Float, _ icon: UIImage)->Void)) {
        
        let session = URLSession.shared
    
        let weatherURL = URL(string: currentWeatherURL)!
        
        let dataTask = session.dataTask(with: weatherURL) {
            (data: Data?, response: URLResponse?, error: Error?) in
            
            if error != nil {
                NotificationCenter.default.post(name: .errorChannel, object: "Weather: No response from server.")
            } else {
                if let data = data {
                    let dataString = String(data: data, encoding: String.Encoding.utf8)
                    print("Current weather data:\n\(dataString!)")
                    
                    if let dictionary = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
                        
                        var temperature: Float = 99.99, icon: UIImage?
                        
                        if let tempMain = dictionary!["main"] as? [String: Any]{
                            
                            temperature = tempMain["temp"] as! Float
                            
                        }
                        
                        if let weatherArray = dictionary!["weather"] as? [Any] {
                            if weatherArray.count != 1 {
                                NotificationCenter.default.post(name: .errorChannel, object: "\(weatherArray.count) weather info!")
                            }
                            
                            let currentWeather = weatherArray[0] as? [String: Any]
                            
                            let url = URL(string: "https://openweathermap.org/img/w/" + (currentWeather!["icon"] as! String) + ".png")
                            let data = try? Data(contentsOf: url!)
                            icon = UIImage(data: data!)!
                        }
                        
                        finished(temperature, icon!)
                        
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
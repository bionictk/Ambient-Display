//
//  CurrentWeatherController.swift
//  ambientDisplay
//
//  Created by Taeheon Kim on 1/23/18.
//  Copyright © 2018 Taeheon Kim. All rights reserved.
//

import UIKit

class WeatherController {
    
//    let currentWeatherURL: String = "https://api.openweathermap.org/data/2.5/weather?id=4180439&appid=29536689fa5bbed8e7e72f7d8dfc106c&units=metric"    // Atlanta
//    let currentWeatherURL: String = "https://api.openweathermap.org/data/2.5/weather?id=5391997&appid=29536689fa5bbed8e7e72f7d8dfc106c&units=metric"    // San Francisco
//    let currentWeatherURL: String = "https://api.wunderground.com/api/9450e3262240980a/conditions/q/GA/Atlanta.json"
    let currentWeatherURL: String = "https://api.wunderground.com/api/9450e3262240980a/conditions/q/NY/NewYork.json"
    
    func getCurrentWeather(finished: @escaping ((_ tempC: Int, _ tempF: Int, _ icon: UIImage)->Void)) {
        
        let session = URLSession.shared
    
        let weatherURL = URL(string: currentWeatherURL)!
        
        let dataTask = session.dataTask(with: weatherURL) {
            (data: Data?, response: URLResponse?, error: Error?) in
            
            if error != nil {
                NotificationCenter.default.post(name: .errorChannel, object: "Weather: No response from server.")
            } else {
                if let data = data {
//                    let dataString = String(data: data, encoding: String.Encoding.utf8)
//                    print("Current weather data:\n\(dataString!)")
                    
                    if let dictionary = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
                        
                        var temperatureC: Int = 99, temperatureF: Int = 99, icon: UIImage?
                        
                        // OpenWeatherMap
//                        if let tempMain = dictionary!["main"] as? [String: Any]{
//
//                            var rawTemp = tempMain["temp"] as! Float
//                            rawTemp.round()
//                            temperature = Int(rawTemp)
//
//                        }
//
//                        if let weatherArray = dictionary!["weather"] as? [[String: Any]] {
//                            var weatherIconArray: [String] = []
//                            for weatherElement in weatherArray {
//                                let weatherIcon = weatherElement["icon"] as! String
//                                if !weatherIconArray.contains(weatherIcon) {
//                                    weatherIconArray.append(weatherIcon)
//                                }
//                            }
//
//                            if weatherIconArray.count != 1 {
//                                NotificationCenter.default.post(name: .errorChannel, object: "\(weatherArray.count) icons!")
//                            }
//
//                            let currentWeatherIcon = weatherIconArray[0]
//                            let url = URL(string: "https://openweathermap.org/img/w/" + currentWeatherIcon + ".png")
//                            let data = try? Data(contentsOf: url!)
//                            icon = UIImage(data: data!)!
//                        }
                        
                        // Wunderground
                        if let tempMain = dictionary!["current_observation"] as? [String: Any]{
                            
                            var rawTempC = (tempMain["feelslike_c"] as! NSString).floatValue
                            rawTempC.round()
                            temperatureC = Int(rawTempC)
                            var rawTempF = (tempMain["feelslike_f"] as! NSString).floatValue
                            rawTempF.round()
                            temperatureF = Int(rawTempF)

                            var urlComponents = URLComponents(string: tempMain["icon_url"] as! String)
                            urlComponents?.scheme = "https"
                            let data = try? Data(contentsOf: (urlComponents?.url)!)
                            let source = CGImageSourceCreateWithData(data! as CFData, nil)
                            icon = animatedImageWithSource(source!)
                        }
                        
                        finished(temperatureC, temperatureF, icon!)
                        
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

func animatedImageWithSource(_ source: CGImageSource) -> UIImage? {
    let count = CGImageSourceGetCount(source)
    var images = [CGImage]()
    var delays = [Int]()
    
    // Fill arrays
    for i in 0..<count {
        // Add image
        if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
            images.append(image)
        }
        
        // At it's delay in cs
        let delaySeconds = delayForImageAtIndex(Int(i),
                                                        source: source)
        delays.append(Int(delaySeconds * 1000.0)) // Seconds to ms
    }
    
    // Calculate full duration
    let duration: Int = {
        var sum = 0
        
        for val: Int in delays {
            sum += val
        }
        
        return sum
    }()
    
    // Get frames
    let gcd = gcdForArray(delays)
    var frames = [UIImage]()
    
    var frame: UIImage
    var frameCount: Int
    for i in 0..<count {
        frame = UIImage(cgImage: images[Int(i)])
        frameCount = Int(delays[Int(i)] / gcd)
        
        for _ in 0..<frameCount {
            frames.append(frame)
        }
    }
    
    // Heyhey
    let animation = UIImage.animatedImage(with: frames,
                                          duration: Double(duration) / 1000.0)
    
    return animation
}

func delayForImageAtIndex(_ index: Int, source: CGImageSource!) -> Double {
    var delay = 0.1
    
    // Get dictionaries
    let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
    let gifPropertiesPointer = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 0)
    if CFDictionaryGetValueIfPresent(cfProperties, Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque(), gifPropertiesPointer) == false {
        return delay
    }
    
    let gifProperties:CFDictionary = unsafeBitCast(gifPropertiesPointer.pointee, to: CFDictionary.self)
    
    // Get delay time
    var delayObject: AnyObject = unsafeBitCast(
        CFDictionaryGetValue(gifProperties,
                             Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
        to: AnyObject.self)
    if delayObject.doubleValue == 0 {
        delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                                                         Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
    }
    
    delay = delayObject as? Double ?? 0
    
    if delay < 0.1 {
        delay = 0.1 // Make sure they're not too fast
    }
    
    return delay
}

func gcdForArray(_ array: Array<Int>) -> Int {
    if array.isEmpty {
        return 1
    }
    
    var gcd = array[0]
    
    for val in array {
        gcd = gcdForPair(val, gcd)
    }
    
    return gcd
}

func gcdForPair(_ a: Int?, _ b: Int?) -> Int {
    var a = a
    var b = b
    // Check if one of them is nil
    if b == nil || a == nil {
        if b != nil {
            return b!
        } else if a != nil {
            return a!
        } else {
            return 0
        }
    }
    
    // Swap for modulo
    if a! < b! {
        let c = a
        a = b
        b = c
    }
    
    // Get greatest common divisor
    var rest: Int
    while true {
        rest = a! % b!
        
        if rest == 0 {
            return b! // Found it
        } else {
            a = b
            b = rest
        }
    }
}

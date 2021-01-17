//
//  WeatherManager.swift
//  Weatherly
//
//  Created by Anshu Vij on 1/16/21.
//

import Foundation
import CoreLocation
import Firebase

struct WeatherManager {
    
    var delegate : WeatherManagerDelegate?
    
    func fetchWeather(cityName : String)
    {
        let urlString = "\(Constants.base_url)&q=\(cityName)"
        print(urlString)
        performRequest(with: urlString)
    }
    func fetchWeather(latitude : CLLocationDegrees, longitude : CLLocationDegrees)
    {
        let urlString = "\(Constants.base_url)&lat=\(latitude)&lon=\(longitude)"
        print(urlString)
        
        
        performRequest(with: urlString)
    }
    
    func saveLastData(latitude : CLLocationDegrees, longitude : CLLocationDegrees) {
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        let data : [String : Any] = ["latitude":latitude, "longitude" : longitude]
        
        Constants.COLLECTION_USERS.document(uid).setData(data, completion: nil)
        
    }
    
    
    func performRequest(with urlString : String)
    {
        if let url  = URL(string: urlString){
            let session = URLSession(configuration: .default)
            
            let task = session.dataTask(with: url) { (data, response, error) in
                
                
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data
                {
                    if let weather = self.parseJSON(safeData) {
                        self.delegate?.didUpdateWeather(self, weather)
                    }
                }
            }
            
            task.resume()
        }
    }
    
    
    func parseJSON( _ weatherData : Data) -> [WeatherModel]? {
        
        let dataString = String(data: weatherData, encoding: String.Encoding.utf8)
        var temperatureArray: Array<Double> = Array()
        var dayNumber = 0
        var readingNumber = 0
        var cityName = String()
        var weatherModelData = [WeatherModel]()
        var weatherID : Int?
        var minTempArray: Array<Double> = Array()
        var maxTempArray: Array<Double> = Array()
        if let jsonObj = try? JSONSerialization.jsonObject(with: weatherData, options: .allowFragments) as? NSDictionary {
            if let cityArray = jsonObj.value(forKey: "city") as? Dictionary<String,Any> {
                cityName = (cityArray["name"] as? String)!
            }
            
            if let mainArray = jsonObj.value(forKey: "list") as? NSArray {
                for dict in mainArray {
                    
                    if let mainDictionary = (dict as! NSDictionary).value(forKey: "weather") as? [NSDictionary] {
                        
                        let main = mainDictionary[0]
                        weatherID = main["id"] as? Int
                    }
                    if let mainDictionary = (dict as! NSDictionary).value(forKey: "main") as? NSDictionary {
                        if let temperature = mainDictionary.value(forKey: "temp") as? Double {
                            if readingNumber == 0 {
                                temperatureArray.append(temperature)
                            } else if temperature > temperatureArray[dayNumber] {
                                temperatureArray[dayNumber] = temperature
                            }
                            
                        } else {
                            print("Error: unable to find temperture in dictionary")
                        }
                        
                        if let minTemperature = mainDictionary.value(forKey: "temp_min") as? Double {
                            if readingNumber == 0 {
                                minTempArray.append(minTemperature)
                            } else if minTemperature < minTempArray[dayNumber] {
                                minTempArray[dayNumber] = minTemperature
                            }
                            
                        } else {
                            print("Error: unable to find temperture in dictionary")
                        }
                        
                        if let maxTemperature = mainDictionary.value(forKey: "temp_max") as? Double {
                            if readingNumber == 0 {
                                maxTempArray.append(maxTemperature)
                            } else if maxTemperature > maxTempArray[dayNumber] {
                                maxTempArray[dayNumber] = maxTemperature
                            }
                            
                        } else {
                            print("Error: unable to find temperture in dictionary")
                        }
                        
                    } else {
                        print("Error: unable to find main dictionary")
                    }
                    
                    
                    
                    readingNumber += 1
                    if readingNumber == 8 {
                        readingNumber = 0
                        dayNumber += 1
                    }
                }
                
            }
        }
        
        
        print("weatherId:\(weatherID)")
        
        for i in 0..<temperatureArray.count {
            weatherModelData.append(WeatherModel(conditionId: weatherID ?? 800 , cityName: cityName, temprature: temperatureArray[i], min_temp: minTempArray[i], max_temp: maxTempArray[i]))
        }
        return weatherModelData
        
    }
    
}


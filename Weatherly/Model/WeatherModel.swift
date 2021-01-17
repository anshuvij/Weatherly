//
//  WeatherModel.swift
//  Weatherly
//
//  Created by Anshu Vij on 1/16/21.
//

import Foundation

struct WeatherModel {
    
    let conditionId : Int
    let cityName : String
    let temprature : Double
    let min_temp : Double
    let max_temp : Double
    
    var tempratureString : String {
        
        return String(format: "%.1f", temprature)
    }
    var conditionName : String {
        switch conditionId {
            case 200...232:
                return "cloud.bolt"
            case 300...321:
                return "cloud.drizzle"
            case 500...531:
                return "cloud.rain"
            case 600...622:
                return "cloud.snow"
            case 701...781:
                return "cloud.fog"
            case 800:
                return "sun.max"
            case 801...804:
                return "cloud.bolt"
            default:
                return "cloud"
            }

    }
    
    
   
}


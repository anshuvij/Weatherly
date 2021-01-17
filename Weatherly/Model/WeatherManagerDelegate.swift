//
//  WeatherManagerDelegate.swift
//  Weatherly
//
//  Created by Anshu Vij on 1/16/21.
//

import Foundation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager : WeatherManager, _ weather: [WeatherModel])
    func didFailWithError(error : Error)
}


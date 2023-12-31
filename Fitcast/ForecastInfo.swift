//
//  ForeCastInfo.swift
//  WeatherFit
//
//  Created by Hyun on 10/26/23.
//

import Foundation
import WeatherKit

struct ForecastInfo{
    private (set) var currTemperature: Measurement<UnitTemperature>
    private (set) var currCondition: WeatherCondition
    private (set) var currSymbol: String
    private (set) var hourlyWeather: Array<WeatherInfo>
    private (set) var closet: Array<Clothes>
    private (set) var now: Int
    
    struct WeatherInfo: Identifiable{
        var id: Int
        var date: Date
        var condition: WeatherCondition
        var temp: Measurement<UnitTemperature>
        var symbolName: String
    }
    
    struct Clothes: Identifiable{
        var id: Int
        var tempRange: String
        var recommendFit: String
    }
    
    init(currTemperature: Measurement<UnitTemperature>, currSymbol: String, currCondition: WeatherCondition, createForecastInfo: (Int) -> WeatherInfo, createCloset: (Int) -> Clothes) {
        self.currTemperature = currTemperature
        self.currSymbol = currSymbol
        self.currCondition = currCondition
        hourlyWeather = Array<WeatherInfo>()
        closet = Array<Clothes>()
        
        self.now = Int(Calendar.current.component(.hour, from: Date()))
        for time in now+1..<now+26{
            let weatherInfo = createForecastInfo(time)
            hourlyWeather.append(weatherInfo)
        }
        
        for idx in 0..<8{
            let clothes = createCloset(idx)
            closet.append(clothes)
        }
    }
}

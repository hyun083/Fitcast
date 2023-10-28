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
    
    struct WeatherInfo: Identifiable{
        var id: Int
        var date: Date
        var condition: WeatherCondition
        var temp: Measurement<UnitTemperature>
        var symbolName: String
    }
    
    init(currTemperature: Measurement<UnitTemperature>, currSymbol: String, currCondition: WeatherCondition, createForecastInfo: (Int) -> WeatherInfo) {
        self.currTemperature = currTemperature
        self.currSymbol = currSymbol
        self.currCondition = currCondition
        hourlyWeather = Array<WeatherInfo>()
        
        let now = Int(Calendar.current.component(.hour, from: Date()))+1
        for time in now..<now+25{
            let weatherInfo = createForecastInfo(time)
            hourlyWeather.append(weatherInfo)
        }
    }
}

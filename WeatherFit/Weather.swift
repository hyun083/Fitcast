//
//  Weather.swift
//  WeatherFit
//
//  Created by Hyun on 10/17/23.
//

import Foundation
import WeatherKit
import CoreLocation
import SwiftUI

struct Weather{
    private var location: CLLocation
    private (set) var currTemp: Measurement<UnitTemperature>
    private (set) var currCondition: WeatherCondition
    private (set) var hourlyWeather = [WeatherInfo]()
    private (set) var avgTemp = 0
    
    var startTime = ""
    var endTime = ""
    private (set) var timeRange = 20...21
    
    init(location: CLLocation, currTemp: Measurement<UnitTemperature>, currCondition: WeatherCondition) {
        self.location = location
        self.currTemp = currTemp
        self.currCondition = currCondition
    }
    
    init(){
        self.location = CLLocation(latitude: 37.27807821976637, longitude: 127.15216520791188)
        self.currTemp = Measurement<UnitTemperature>(value: 0.00, unit: UnitTemperature.celsius)
        self.currCondition = WeatherCondition(rawValue: "cloudy") ?? .clear
    }
    
    mutating func update(by service:WeatherService) async{
        guard let info = try? await service.weather(for: location) else{
            print("service error")
            return
        }
        
        currCondition = info.currentWeather.condition
        currTemp = info.currentWeather.temperature
        
        var tmp = [WeatherInfo]()
        let now = Int(Calendar.current.component(.hour, from: Date()))+1
        var sum = 0
        
        for id in now..<now+25{
            let info = info.hourlyForecast[id]
            let hour = Int(Calendar.current.component(.hour, from: info.date))
            
            if timeRange.contains(hour) {
                sum += Int(info.temperature.value.rounded())
            }
            
            let newWeather = WeatherInfo(id:id, date: info.date, condition: info.condition, temp: info.temperature)
            tmp.append(newWeather)
        }
        
        avgTemp = sum/timeRange.count
        hourlyWeather = tmp
    }
    
    mutating func changeTimeRange() {
//        var sum = 0
//        var start = Int(startTime.split(separator: ":")[0])!
//        var end = Int(endTime.split(separator: ":")[0])!
//        let range = start...end
        print("timeRange:")
        for info in hourlyWeather{
            print(info.id)
        }
//        avgTemp = sum/range.count
    }
}

struct WeatherInfo: Identifiable{
    var id: Int
    var date = Date()
    var condition = WeatherCondition(rawValue: "cloudy") ?? .clear
    var temp = Measurement(value: 0.00, unit: UnitTemperature.celsius)
    
    init(id:Int, date: Date, condition: WeatherCondition, temp: Measurement<UnitTemperature>) {
        self.id = id
        self.date = date
        self.condition = condition
        self.temp = temp
    }
}

enum WeatherType {
    case sunny
    case cloud
    case rain
    case snow
    case hail
    case lightning
    
    var systemNameIcon: String {
        switch self {
        case .sunny:
            return "sun.min.fill"
        case .cloud:
            return "cloud.fill"
        case .rain:
            return "cloud.rain.fill"
        case .snow:
            return "cloud.sleet.fill"
        case .hail:
            return "cloud.hail.fill"
        case .lightning:
            return "cloud.bolt.fill"
        }
    }
}

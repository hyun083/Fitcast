//
//  WeatherFitViewModel.swift
//  WeatherFit
//
//  Created by Hyun on 10/18/23.
//

import Foundation
import WeatherKit
import CoreLocation

class Closet: ObservableObject{
    static let weatherService = WeatherService()
    static let locationManager = CLLocationManager()
    @Published private var model = Weather(startTime: "13:00", endTime: "14:00")
        
    var hourlyWeather: Array<WeatherInfo>{
        return model.hourlyWeather
    }
    
    var recommendFit: String{
        return model.recommendFit
    }
    
    func update() async{
        await model.update(by: Closet.weatherService)
    }
    
    func currTemp() -> Measurement<UnitTemperature>{
        return model.currTemp
    }
    
    func currCondition() -> String{
        return model.currCondition.description
    }
    
    func avgTemperature() -> Int{
        return model.avgTemp
    }
    
    func timeRange() -> ClosedRange<Int>{
        return model.timeRange
    }
    
    var startTime: String{
        willSet{
            model.startTime = newValue
        }
    }
    
    var endTime: String{
        willSet{
            model.endTime = newValue
        }
    }
    
    func changeTimeRange(){
        model.changeTimeRange()
    }
    
    init(model: Weather = Weather(startTime: "13:00", endTime: "14:00")) {
        self.model = model
        self.startTime = model.startTime
        self.endTime = model.endTime
    }
}

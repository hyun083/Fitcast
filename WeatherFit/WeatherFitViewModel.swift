//
//  WeatherFitViewModel.swift
//  WeatherFit
//
//  Created by Hyun on 10/18/23.
//

import Foundation
import WeatherKit
import CoreLocation

class WeatherFitViewModel: ObservableObject{
    static let winter = ["패딩, 두꺼운 코트, 누빔 옷, 기모, 목도리", "코트, 가죽 자켓, 기모"]
    static let autumn = ["코트, 야상, 점퍼, 스타킹, 기모바지", "자켓, 가디건, 청자켓, 니트, 스타킹, 청바지"]
    static let spring = ["가디건, 니트, 맨투맨, 후드, 긴바지", "블라우스, 긴팔티, 면바지, 슬랙스"]
    static let summer = ["반팔, 얆은 셔츠, 반바지, 면바지", "민소매, 반팔, 반바지, 치마, 린넨 옷"]
    
    static let weatherService = WeatherService()
    static let locationManager = CLLocationManager()
    @Published private var model = Weather()
    
    var hourlyWeather: Array<WeatherInfo>{
        return model.hourlyWeather
    }
    
    func update() async{
        await model.update(by: WeatherFitViewModel.weatherService)
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
            print("startTime set",model.startTime)
        }
    }
    
    var endTime: String{
        willSet{
            model.endTime = newValue
            print("endTime set",model.endTime)
        }
    }
    
    func changeTimeRange(){
        model.changeTimeRange()
    }
    
    init(model: Weather = Weather(), startTime: String, endTime: String) {
        self.model = model
        self.startTime = startTime
        self.endTime = endTime
    }
}

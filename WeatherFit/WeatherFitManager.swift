//
//  WeatherFitManager.swift
//  WeatherFit
//
//  Created by Hyun on 10/26/23.
//

import Foundation
import WeatherKit
import CoreLocation

@MainActor class WeatherFitManager: ObservableObject{
    var weather: Weather?
    @Published private var model: ForecastInfo?
    @Published private var locationManager = LocationManager()
    
    private static let winter = ["패딩, 두꺼운 코트, 누빔 옷, 기모, 목도리", "코트, 가죽 자켓, 기모"]
    private static let autumn = ["코트, 야상, 점퍼, 스타킹, 기모바지", "자켓, 가디건, 청자켓, 니트, 스타킹, 청바지"]
    private static let spring = ["가디건, 니트, 맨투맨, 후드, 긴바지", "블라우스, 긴팔티, 면바지, 슬랙스"]
    private static let summer = ["반팔, 얆은 셔츠, 반바지, 면바지", "민소매, 반팔, 반바지, 치마, 린넨 옷"]
    private static let seasons = winter + autumn + spring + summer
    private static let tempRange = ["~ 4º","5 ~ 8º","9 ~ 11º","12 ~ 16º","17 ~ 19º","20 ~ 22º","23 ~ 27º","28º ~"]
    
    func getWeather() async{
        do{
            weather = try await Task.detached(priority: .userInitiated, operation: {
                return try await WeatherService.shared.weather(for:.init(latitude: self.locationManager.lastLocation?.coordinate.latitude ?? 37.27807821976637,longitude: self.locationManager.lastLocation?.coordinate.longitude ?? 127.15216520791188))
            }).value
            model = createForecastInfo()
        } catch{
            fatalError("\(error)")
        }
    }
    
    func updateLocation(){
        self.locationManager = LocationManager()
    }
    
    func createForecastInfo() -> ForecastInfo?{
        guard let weather else {
            print("no weatherService")
            return nil
        }
        
        return ForecastInfo(currTemperature: weather.currentWeather.temperature, currSymbol: weather.currentWeather.symbolName, currCondition: weather.currentWeather.condition, createForecastInfo: { time in
            ForecastInfo.WeatherInfo(id: time, date: weather.hourlyForecast[time].date, condition: weather.hourlyForecast[time].condition, temp: weather.hourlyForecast[time].temperature, symbolName: weather.hourlyForecast[time].symbolName)
        }, createCloset: { idx in
            ForecastInfo.Clothes(id: idx, tempRange: WeatherFitManager.tempRange[idx], recommendFit: WeatherFitManager.seasons[idx])
        })
    }
    
    var closet: [ForecastInfo.Clothes]{
        model?.closet ?? [ForecastInfo.Clothes]()
    }
    
    var currAddress: String{
        locationManager.userAddress ?? "--"
    }
    
    var currSymbolName: String{
        model?.currSymbol ?? "xmark"
    }
    
    var currTemp: Int{
        Int(model?.currTemperature.value.rounded() ?? 0)
    }
    
    var currCondition: String{
        model?.currCondition.description ?? "Loading..."
    }
    
    var hourlyWeatherInfo: Array<ForecastInfo.WeatherInfo>{
        model?.hourlyWeather ?? Array<ForecastInfo.WeatherInfo>()
    }
    
    var currHour:Int{
        model?.now ?? Int(Calendar.current.component(.hour, from: Date()))
    }
    
    var startTime: Int = UserDefaults.shared.integer(forKey: "startTime"){
        willSet{
            UserDefaults.shared.set(newValue, forKey: "startTime")
            objectWillChange.send()
        }
    }
    
    var endTime: Int = UserDefaults.shared.integer(forKey: "endTime"){
        willSet{
            UserDefaults.shared.set(newValue, forKey: "endTime")
            objectWillChange.send()
        }
    }
    
    var avgTemp: Int{
        get{
            let hourlyForecast = model?.hourlyWeather ?? [ForecastInfo.WeatherInfo]()
            let now = Int(Calendar.current.component(.hour, from: Date()))

            var lower = startTime
            var upper = endTime
            
            lower += lower<now ? 24:0
            upper += upper<now ? 24:0
            upper += upper<lower ? 24:0
            print(lower,upper)
            var tmp = [Int]()
            
            for info in hourlyForecast{
                if (lower...upper).contains(info.id-1){
//                    print(info.id, info.date, info.temp.value.rounded())
                    tmp.append(Int(info.temp.value.rounded()))
                }
            }
            
            let res = tmp.reduce(0, +)/(tmp.count==0 ? 1:tmp.count)
            UserDefaults.standard.set(res, forKey: "avgTemp")
            return(res)
        }
    }
}

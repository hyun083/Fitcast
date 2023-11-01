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
    @Published var model: ForecastInfo?
    @Published var locationManager = LocationManager()
    
    private static let winter = ["패딩, 두꺼운 코트, 누빔 옷, 기모, 목도리", "코트, 가죽 자켓, 기모"]
    private static let autumn = ["코트, 야상, 점퍼, 스타킹, 기모바지", "자켓, 가디건, 청자켓, 니트, 스타킹, 청바지"]
    private static let spring = ["가디건, 니트, 맨투맨, 후드, 긴바지", "블라우스, 긴팔티, 면바지, 슬랙스"]
    private static let summer = ["반팔, 얆은 셔츠, 반바지, 면바지", "민소매, 반팔, 반바지, 치마, 린넨 옷"]
    private static let closet = [winter[0], winter[1], autumn[0], autumn[1], spring[0], spring[1], summer[0], summer[1]]
    
    func getWeather() async{
        do{
            weather = try await Task.detached(priority: .userInitiated, operation: {
                return try await WeatherService.shared.weather(for:.init(latitude: self.locationManager.lastLocation?.coordinate.latitude ?? 37.27807821976637, longitude: self.locationManager.lastLocation?.coordinate.longitude ?? 127.15216520791188))
//                return try await WeatherService.shared.weather(for:.init(latitude: , longitude: 127.15216520791188))
            }).value
            
            model = createForecastInfo()
        } catch{
            fatalError("\(error)")
        }
    }
    
    func createForecastInfo() -> ForecastInfo?{
        guard let weather else {
            print("no weatherService")
            return nil
        }
        
        return ForecastInfo(currTemperature: weather.currentWeather.temperature, currSymbol: weather.currentWeather.symbolName, currCondition: weather.currentWeather.condition, createForecastInfo: { time in
            ForecastInfo.WeatherInfo(id: time, date: weather.hourlyForecast[time].date, condition: weather.hourlyForecast[time].condition, temp: weather.hourlyForecast[time].temperature, symbolName: weather.hourlyForecast[time].symbolName)
        })
    }
    
    var currAddress: String{
        locationManager.userAddress
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
    
    var startTime: Int = UserDefaults.standard.integer(forKey: "startTime"){
        willSet{
            UserDefaults.standard.set(newValue, forKey: "startTime")
            objectWillChange.send()
        }
    }
    
    var endTime: Int = UserDefaults.standard.integer(forKey: "endTime"){
        willSet{
            UserDefaults.standard.set(newValue, forKey: "endTime")
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
            var res = [Int]()
            
            for info in hourlyForecast{
                if (lower...upper).contains(info.id-1){
                    print(info.id, info.date, info.temp.value.rounded())
                    res.append(Int(info.temp.value.rounded()))
                }
            }
            
            return(res.reduce(0, +)/(res.count==0 ? 1:res.count))
        }
    }
    
    var recommendFit: String{
        get{
            var res = String()
            if avgTemp <= 4{
                res = WeatherFitManager.winter[0]
            }else if avgTemp <= 8{
                res =  WeatherFitManager.winter[1]
            }else if avgTemp <= 11{
                res =  WeatherFitManager.autumn[0]
            }else if avgTemp <= 16{
                res =  WeatherFitManager.autumn[1]
            }else if avgTemp <= 19{
                res =  WeatherFitManager.spring[0]
            }else if avgTemp <= 22{
                res =  WeatherFitManager.spring[1]
            }else if avgTemp <= 27{
                res =  WeatherFitManager.summer[0]
            }else{
                res =  WeatherFitManager.summer[1]
            }
            return res
        }
        set{
            objectWillChange.send()
        }
    }
}

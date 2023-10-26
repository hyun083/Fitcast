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

struct CustomWeather{
    var userAddress = "초기값"
    
    private (set) var currTemp: Measurement<UnitTemperature>
    private (set) var currCondition: WeatherCondition
    private (set) var hourlyWeather = [WeatherInfo]()
    
    var startTime:String
    var endTime: String
    var timeRange:ClosedRange<Int>{
        get{
            Int(startTime.split(separator: ":")[0])!...Int(endTime.split(separator: ":")[0])!
        }
    }
    private (set) var avgTemp = 0
    private let winter = ["패딩, 두꺼운 코트, 누빔 옷, 기모, 목도리", "코트, 가죽 자켓, 기모"]
    private let autumn = ["코트, 야상, 점퍼, 스타킹, 기모바지", "자켓, 가디건, 청자켓, 니트, 스타킹, 청바지"]
    private let spring = ["가디건, 니트, 맨투맨, 후드, 긴바지", "블라우스, 긴팔티, 면바지, 슬랙스"]
    private let summer = ["반팔, 얆은 셔츠, 반바지, 면바지", "민소매, 반팔, 반바지, 치마, 린넨 옷"]
    var recommendFit: String{
        get{
            if avgTemp <= 4{
                return winter[0]
            }else if avgTemp <= 8{
                return winter[1]
            }else if avgTemp <= 11{
                return autumn[0]
            }else if avgTemp <= 16{
                return autumn[1]
            }else if avgTemp <= 19{
                return spring[0]
            }else if avgTemp <= 22{
                return spring[1]
            }else if avgTemp <= 27{
                return summer[0]
            }else{
                return summer[1]
            }
        }
    }
    
    init(startTime:String, endTime:String){
        self.currTemp = Measurement<UnitTemperature>(value: 0.00, unit: UnitTemperature.celsius)
        self.currCondition = WeatherCondition(rawValue: "cloudy") ?? .clear
        self.startTime = startTime
        self.endTime = endTime
    }
    
    mutating func update(by info:Weather){
        currCondition = info.currentWeather.condition
        currTemp = info.currentWeather.temperature
        
        var tmp = [WeatherInfo]()
        let now = Int(Calendar.current.component(.hour, from: Date()))+1
        var sum = 0
        
        for id in now..<now+25{
            let info = info.hourlyForecast[id]
            let hour = Int(Calendar.current.component(.hour, from: info.date))
            
            //            print(id-1, hour)
            if timeRange.contains(hour) {
                sum += Int(info.temperature.value.rounded())
            }
            
            let newWeather = WeatherInfo(id:id-1, date: info.date, condition: info.condition, temp: info.temperature)
            tmp.append(newWeather)
        }
        
        avgTemp = sum/timeRange.count
        hourlyWeather = tmp
    }
    
    mutating func changeTimeRange() {
        var sum = 0
        let now = Int(Calendar.current.component(.hour, from: Date()))
        var start = Int(startTime.split(separator: ":")[0]) ?? 7
        let end = Int(endTime.split(separator: ":")[0]) ?? 9
        print(start, end)
        start += start<now ? 24:0
        let range = start<=end ? start...end:start...end+24

        for info in hourlyWeather{
            if range.contains(info.id){
                sum += Int(info.temp.value.rounded())
            }
        }
        print(now,range,sum)
        avgTemp = sum/range.count
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

//
//  WeatherFitManager.swift
//  WeatherFit
//
//  Created by Hyun on 10/26/23.
//

import Foundation
import WeatherKit

@MainActor class WeatherFitManager: ObservableObject{
    var weather: Weather?
    @Published var model: ForecastInfo?
    
    var avgTemp: Int{
        get{
            var sum = 0
            let hourlyForecast = model?.hourlyWeather ?? [ForecastInfo.WeatherInfo]()
            for info in hourlyForecast{
                if (startTime...endTime).contains(info.id){
                    sum += Int(info.temp.value.rounded())
                }
            }
            return sum/(startTime...endTime).count
        }
    }
    
    var startTime: Int = 7
    var endTime: Int = 9
    
    func getWeather() async{
        do{
            weather = try await Task.detached(priority: .userInitiated, operation: {
                return try await WeatherService.shared.weather(for:.init(latitude: 37.27807821976637, longitude: 127.15216520791188))
            }).value
            
            model = createForeCastInfo()
        } catch{
            fatalError("\(error)")
        }
    }
    
    func createForeCastInfo() -> ForecastInfo?{
        guard let weather else {
            print("no weatherService")
            return nil
        }
        
        return ForecastInfo(currTemperature: weather.currentWeather.temperature, currCondition: weather.currentWeather.condition, createForecastInfo: { time in
            ForecastInfo.WeatherInfo(id: time, date: weather.hourlyForecast[time].date, condition: weather.hourlyForecast[time].condition, temp: weather.hourlyForecast[time].temperature, symbolName: weather.hourlyForecast[time].symbolName+".fill")
        })
    }
    
    var symbol: String{
        weather?.currentWeather.symbolName ?? "xmark"
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

}

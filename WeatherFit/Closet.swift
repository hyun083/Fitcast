//
//  WeatherFitViewModel.swift
//  WeatherFit
//
//  Created by Hyun on 10/18/23.
//

import Foundation
import WeatherKit
import CoreLocation

@MainActor class Closet: ObservableObject{
//    static let weatherService = WeatherService()
    static let locationManager = CLLocationManager()
    @Published private var model = CustomWeather(startTime: "13:00", endTime: "14:00")
    private var location = CLLocation(latitude: 37.27807821976637, longitude: 127.15216520791188)
    
    var hourlyWeather: Array<WeatherInfo>{
        return model.hourlyWeather
    }
    
    var recommendFit: String{
        return model.recommendFit
    }
    
    func update() async{
        do {
            let info = try await Task.detached(priority: .userInitiated) { [self] in
                return try await WeatherService.shared.weather(for: location)
            }.value
            model.update(by: info)
            setUserAddress(to: location)
        } catch {
            fatalError("\(error)")
        }
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
            model.changeTimeRange()
        }
    }
    
    var endTime: String{
        willSet{
            model.endTime = newValue
            model.changeTimeRange()
        }
    }
    
    func changeTimeRange(){
        model.changeTimeRange()
    }
    
    init(model: CustomWeather) {
        self.model = model
        self.startTime = model.startTime
        self.endTime = model.endTime
    }
    
    func userAddress() -> String{
        return model.userAddress
    }
    
    func setUserAddress(to location:CLLocation){
        let findLocation = location
        let locale = Locale(identifier: "ko_KR")
        let geocoder = CLGeocoder()
        
        //지오코더 사용 국가체계에 맞는 주소정보를 반환해준다.
        geocoder.reverseGeocodeLocation(findLocation, preferredLocale: locale, completionHandler: { [self](placemarks, error) -> Void in
            if let address: [CLPlacemark] = placemarks {
                //도시 ex)제주시, 서귀포시...
                if let area: String = address.last?.locality{
                    model.userAddress = area
                }
            }
        })
    }
}

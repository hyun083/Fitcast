//
//  FitcastWidgetManager.swift
//  FitcastWidgetExtension
//
//  Created by Hyun on 4/27/24.
//

import Foundation
import CoreLocation
import SwiftUI
import WidgetKit
import Combine
import WeatherKit
//37.27807800,+127.15216521

class FitcastWidgetManager: NSObject, CLLocationManagerDelegate{
    //location
    let locationManager = CLLocationManager()
    private var locationStatus: CLAuthorizationStatus?
    private (set) var lastLocation: CLLocation = CLLocation(latitude: 0, longitude: 0)
    
    //weather
    let weatherService = WeatherService()
    var weather: CurrentWeather?
    
    //closet
    private static let winter = ["패딩, 두꺼운 코트, 누빔 옷, 기모, 목도리", "코트, 가죽 자켓, 기모"]
    private static let autumn = ["코트, 야상, 점퍼, 스타킹, 기모바지", "자켓, 가디건, 청자켓, 니트, 스타킹, 청바지"]
    private static let spring = ["가디건, 니트, 맨투맨, 후드, 긴바지", "블라우스, 긴팔티, 면바지, 슬랙스"]
    private static let summer = ["반팔, 얆은 셔츠, 반바지, 면바지", "민소매, 반팔, 반바지, 치마, 린넨 옷"]
    private let seasons = winter + autumn + spring + summer
    
    //MARK: -init
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        WidgetCenter.shared.reloadAllTimelines()
        print(#function,"locationManager init")
    }
    
    //MARK: -location
    var statusString: String {
        guard let status = locationStatus else {
            return "unknown"
        }
        
        switch status {
        case .notDetermined: return "notDetermined"
        case .authorizedWhenInUse: return "authorizedWhenInUse"
        case .authorizedAlways: return "authorizedAlways"
        case .restricted: return "restricted"
        case .denied: return "denied"
        default: return "unknown"
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationStatus = status
        print(#function, statusString)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            print(#function, "location update error")
            return
        }
        lastLocation = location
        print(#function,": \(lastLocation)")
        locationManager.stopUpdatingLocation()
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func updateLocation(){
        locationManager.startUpdatingLocation()
        print(#function,lastLocation)
    }
    
    func updateLocation(to location: CLLocation){
        lastLocation = location
        print(#function,lastLocation)
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func updateAddress() async -> String {
        let locale = Locale(identifier: UserDefaults.standard.stringArray(forKey: "AppleLanguages")?.first ?? "ko_KR")
        let geocoder = CLGeocoder()
        
        do{
            let placemark = try await geocoder.reverseGeocodeLocation(lastLocation, preferredLocale: locale).last!
            print(#function,"location: \(lastLocation), placemark:\(placemark.name!)")
            return placemark.locality ?? placemark.subAdministrativeArea ?? placemark.administrativeArea ?? "--"
        }catch{
            fatalError("error on useraddress")
        }
    }
    
    //MARK: -closet
    func recommendFit(on temp:Int) -> String {
        return seasons[temp.position]
    }
    //MARK: -weather
    
    func getWeather() async {
        do{
            weather = try await Task.detached(priority: .userInitiated, operation: {
                return try await self.weatherService.weather(for: self.lastLocation, including: .current)
            }).value
        }catch{
            fatalError("\(error)")
        }
    }
}

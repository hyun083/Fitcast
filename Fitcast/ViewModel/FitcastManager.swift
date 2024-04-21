//
//  WeatherFitManager.swift
//  WeatherFit
//
//  Created by Hyun on 10/26/23.
//

import Foundation
import WeatherKit
import CoreLocation
import WidgetKit

@MainActor
class FitcastManager: NSObject, ObservableObject, CLLocationManagerDelegate{
    private var locationStatus: CLAuthorizationStatus?
    private let locationManager = CLLocationManager()
    var locationList = getLocationList()
    
    @Published var locationSearchService: LocationSearchService
    @Published private (set) var publishedLocation: CLLocation
    @Published private (set) var addressLabel: String
    @Published private var forecast: ForecastInfo?
    
    private var weather: Weather?
    
    private static let winter = ["패딩, 두꺼운 코트, 누빔 옷, 기모, 목도리", "코트, 가죽 자켓, 기모"]
    private static let autumn = ["코트, 야상, 점퍼, 스타킹, 기모바지", "자켓, 가디건, 청자켓, 니트, 스타킹, 청바지"]
    private static let spring = ["가디건, 니트, 맨투맨, 후드, 긴바지", "블라우스, 긴팔티, 면바지, 슬랙스"]
    private static let summer = ["반팔, 얆은 셔츠, 반바지, 면바지", "민소매, 반팔, 반바지, 치마, 린넨 옷"]
    private static let seasons = winter + autumn + spring + summer
    private static let tempRange = ["~ 4º","5 ~ 8º","9 ~ 11º","12 ~ 16º","17 ~ 19º","20 ~ 22º","23 ~ 27º","28º ~"]
    
    override init() {
        self.locationSearchService = LocationSearchService()
        self.publishedLocation = CLLocation(latitude: 0, longitude: 0)
        self.addressLabel = "--"
        
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        print(#function,"locationManager init")
        
        publishedCurrLocation = (publishedLocationIdx >= locationList.count)||(locationList.isEmpty) ?
        true:publishedCurrLocation
        
        Task{
            if publishedCurrLocation{
                await getWeather()
                await updateAddress()
            }else{
                let idx = publishedLocationIdx
                updateLocation(to: locationList[idx])
                await getWeather()
            }
        }
        
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    //MARK: -LocationManager
    
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
            print(#function, "fail error")
            return
        }
        publishedLocation = location
        print(#function,": \(publishedLocation)")
        locationManager.stopUpdatingLocation()
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func updateAddress() async {
        let locale = Locale(identifier: UserDefaults.standard.stringArray(forKey: "AppleLanguages")?.first ?? "ko_KR")
        let geocoder = CLGeocoder()
        
        do{
            let placemark = try await geocoder.reverseGeocodeLocation(publishedLocation, preferredLocale: locale).last!
            print(#function,"location: \(publishedLocation), placemark:\(placemark.name!)")
            addressLabel = placemark.locality ?? placemark.subAdministrativeArea ?? placemark.administrativeArea ?? "--"
        }catch{
            fatalError("error on useraddress")
        }
    }
    
    func updateLocation() {
        self.locationManager.startUpdatingLocation()
    }
    
    func updateLocation(to location: FitcastLocation){
        publishedLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        print(#function,publishedLocation)
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    private static func getLocationList() -> [FitcastLocation]{
        if let data = UserDefaults.shared.data(forKey: "locationList"){
            return try! PropertyListDecoder().decode([FitcastLocation].self, from: data)
        }else{
            return [FitcastLocation]()
        }
    }
    
    func updateLocationList(){
        if let data = try? PropertyListEncoder().encode(locationList){
            UserDefaults.shared.set(data, forKey: "locationList")
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    func addNewLocation(_ newLocation:FitcastLocation){
        if !locationList.contains(where: {$0 == newLocation}){
            locationList.append(newLocation)
            updateLocationList()
        }
    }
    
    func removeLocationAt(index:IndexSet){
        locationList.remove(atOffsets: index)
        updateLocationList()
    }
    
    func moveLocation(From currIndex:IndexSet, to newIndex:Int){
        locationList.move(fromOffsets: currIndex, toOffset: newIndex)
    }
    
    var publishedCurrLocation: Bool = UserDefaults.shared.bool(forKey: "selectedCurrLocation"){
        willSet{
            UserDefaults.shared.set(newValue, forKey: "selectedCurrLocation")
            objectWillChange.send()
        }
    }
    
    var publishedLocationIdx: Int = UserDefaults.shared.integer(forKey: "selectedLoctionIdx"){
        willSet{
            UserDefaults.shared.set(newValue, forKey: "selectedLoctionIdx")
            objectWillChange.send()
        }
    }

    //MARK: - WeatherService
    
    func getWeather() async{
        do{
            weather = try await Task.detached(priority: .userInitiated, operation: {
                return try await WeatherService.shared.weather(for:.init(latitude: self.publishedLocation.coordinate.latitude,longitude: self.publishedLocation.coordinate.longitude))
            }).value
            forecast = createForecastInfo()
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
        }, createCloset: { idx in
            ForecastInfo.Clothes(id: idx, tempRange: FitcastManager.tempRange[idx], recommendFit: FitcastManager.seasons[idx])
        })
    }
    
    var closet: [ForecastInfo.Clothes]{
        forecast?.closet ?? [ForecastInfo.Clothes]()
    }
    
    var currSymbolName: String{
        forecast?.currSymbol ?? "xmark"
    }
    
    var currTemp: Int{
        Int(forecast?.currTemperature.value.rounded() ?? 0)
    }
    
    var currCondition: String{
        forecast?.currCondition.description ?? "Loading..."
    }
    
    var hourlyWeatherInfo: Array<ForecastInfo.WeatherInfo>{
        forecast?.hourlyWeather ?? Array<ForecastInfo.WeatherInfo>()
    }
    
    var currHour:Int{
        forecast?.now ?? Int(Calendar.current.component(.hour, from: Date()))
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
            let hourlyForecast = forecast?.hourlyWeather ?? [ForecastInfo.WeatherInfo]()
            let now = Int(Calendar.current.component(.hour, from: Date()))
            
            var lower = startTime
            var upper = endTime
            
            lower += lower<now ? 24:0
            upper += upper<now ? 24:0
            upper += upper<lower ? 24:0
            
            var tmp = [Int]()
            
            for info in hourlyForecast{
                if (lower...upper).contains(info.id-1){
                    tmp.append(Int(info.temp.value.rounded()))
                }
            }
            
            let res = tmp.reduce(0, +)/(tmp.count==0 ? 1:tmp.count)
            UserDefaults.standard.set(res, forKey: "avgTemp")
            return(res)
        }
    }
}

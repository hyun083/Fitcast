//
//  LocationMananger.swift
//  WeatherFit
//
//  Created by Hyun on 10/31/23.
//

import Foundation
import CoreLocation
import SwiftUI
import WidgetKit
import Combine
//37.27807800,+127.15216521

class WidgetLocationManager: NSObject, CLLocationManagerDelegate{
    let locationManager = CLLocationManager()
    private var locationStatus: CLAuthorizationStatus?
    private (set) var lastLocation: CLLocation = CLLocation(latitude: 0, longitude: 0)

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        WidgetCenter.shared.reloadAllTimelines()
        print(#function,"locationManager init")
    }

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
        lastLocation = location
        print(#function,": \(lastLocation)")
        locationManager.stopUpdatingLocation()
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func updateLocation(to location: FitcastLocation){
        lastLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
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
}

//
//  LocationMananger.swift
//  WeatherFit
//
//  Created by Hyun on 10/31/23.
//

import Foundation
import CoreLocation
import SwiftUI

class LocationManager: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var locationStatus: CLAuthorizationStatus?
    private (set) var lastLocation: CLLocation?
    private (set) var userAddress: String = "현재 위치"

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
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
        guard let location = locations.last else { return }
        lastLocation = location
        print(#function, location)
        getUseraddress()
    }
    
    func getUseraddress(){
        let defaultLocation = CLLocation(latitude: 37.27807821976637, longitude: 127.15216520791188)
        let locale = Locale(identifier: "ko_KR")
        let geocoder = CLGeocoder()
        
        //지오코더 사용 국가체계에 맞는 주소정보를 반환해준다.
        geocoder.reverseGeocodeLocation(lastLocation ?? defaultLocation, preferredLocale: locale, completionHandler: {(placemarks, error) -> Void in
            if let address: [CLPlacemark] = placemarks {
                //행정구역 ex)경기도,경상도,강원도...
//                if let adminArea: String = address.last?.administrativeArea{
//                    self.userAddress += adminArea
//                }
                //도시 ex)제주시, 서귀포시...
                if let area: String = address.last?.locality{
                    self.userAddress = area
                    print("last location:",area)
                }
                //읍면동
//                if let subArea: String = address.last?.subLocality{
//                    self.userAddress += " " + subArea
//                }
            }
        })
    }
}

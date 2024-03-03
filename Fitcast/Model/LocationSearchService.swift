//
//  LocationSearchService.swift
//  Fitcast
//
//  Created by Hyun on 3/3/24.
//

import Foundation
import MapKit
import Combine

class LocationSearchService: NSObject, MKLocalSearchCompleterDelegate{
    @Published var searchQuery = ""
    var completer: MKLocalSearchCompleter
    @Published var completions: [MKLocalSearchCompletion] = []
    var cancellable: AnyCancellable?
    
    override init(){
        completer = MKLocalSearchCompleter()
        completer.resultTypes = .address
        super.init()
        cancellable = $searchQuery.assign(to: \.queryFragment, on: self.completer)
        completer.delegate = self
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.completions = completer.results
    }
    
    func getCoordinate(from address:String) -> CLLocationCoordinate2D{
        var res = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        
        CLGeocoder().geocodeAddressString(address) { (placemarks, error) in
            if let placemarks = placemarks, let location = placemarks.first?.location {
                print(location.coordinate)
                res = location.coordinate
            } else {
                print("주소를 찾을 수 없습니다.")
            }
        }
        
        return res
    }
}

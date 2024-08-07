//
//  AppIntent.swift
//  FitcastWidget
//
//  Created by Hyun on 12/8/23.
//

import WidgetKit
import AppIntents
import CoreLocation

struct WidgetLocation: AppEntity{
    var id: String
    var location: CLLocation
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Location"
    static var defaultQuery = WidgetLocationQuery()
   
    var displayRepresentation: DisplayRepresentation{
        DisplayRepresentation(title: "\(id)")
    }
}

struct WidgetLocationQuery: EntityQuery {
    func getLocationList() -> [FitcastLocation]{
        if let data = UserDefaults.shared.data(forKey: "locationList"){
            return try! PropertyListDecoder().decode([FitcastLocation].self, from: data)
        }else{
            return [FitcastLocation]()
        }
    }
    
    func entities(for identifiers: [WidgetLocation.ID]) async throws -> [WidgetLocation] {
        let locationList = getLocationList().map{WidgetLocation(id: $0.locality, location: CLLocation(latitude: $0.latitude, longitude: $0.longitude))}
        
        let locations: [WidgetLocation] = [
            WidgetLocation(id: "나의 위치", location: CLLocation(latitude: 37.27807821976637, longitude: 127.15216520791188))
        ] + locationList
        
        return locations
    }
    
    func suggestedEntities() async throws -> [WidgetLocation] {
        //widget configuration
        let locationList = getLocationList().map{WidgetLocation(id: $0.locality, location: CLLocation(latitude: $0.latitude, longitude: $0.longitude))}
        
        let locations: [WidgetLocation] = [
            WidgetLocation(id: "나의 위치", location: CLLocation(latitude: 37.27807821976637, longitude: 127.15216520791188))
        ] + locationList
        
        return locations
    }
    
    func defaultResult() async -> WidgetLocation? {
        return WidgetLocation(id: "나의 위치", location: CLLocation(latitude: 37.27807821976637, longitude: 127.15216520791188))
    }
}

struct SelectLocationIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Location"
    static var description = IntentDescription("Location for weather service")
    @Parameter(title: "위치")
    var location: WidgetLocation
}

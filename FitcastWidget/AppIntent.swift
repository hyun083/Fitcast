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
    var locatoin: CLLocation
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Location"
    static var defaultQuery = WidgetLocationQuery()
    
    var displayRepresentation: DisplayRepresentation{
        DisplayRepresentation(title: "\(id)")
    }
    
    static let locations: [WidgetLocation] = [
        WidgetLocation(id: "나의 위치", locatoin: CLLocation(latitude: 37.27807821976637, longitude: 127.15216520791188))
    ]
}

struct WidgetLocationQuery: EntityQuery {
    func entities(for identifiers: [WidgetLocation.ID]) async throws -> [WidgetLocation] {
        WidgetLocation.locations.filter{
            identifiers.contains($0.id)
        }
    }
    
    func suggestedEntities() async throws -> [WidgetLocation] {
        WidgetLocation.locations
    }
    
    func defaultResult() async -> WidgetLocation? {
        WidgetLocation.locations.first
    }
}

struct SelectLocationIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Widget Location"
    static var description = IntentDescription("Select Widget location")

    @Parameter(title: "위치")
    var location: WidgetLocation
}

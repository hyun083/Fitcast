//
//  weatherFitWidget.swift
//  weatherFitWidget
//
//  Created by Hyun on 11/13/23.
//

import WidgetKit
import SwiftUI
import WeatherKit
import CoreLocation

struct Provider: AppIntentTimelineProvider {
    let locationManager = LocationManager()
    let service = WeatherService()
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent(), locationManager: locationManager, currTemp: "--", currSymbolName: "cloud.sun.fill")
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        return SimpleEntry(date: Date(), configuration: configuration, locationManager: locationManager, currTemp: "--", currSymbolName: "cloud.sun.fill")
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let currentWeather = await Task.detached(priority: .userInitiated) {
            let forecast = try? await self.service.weather(
                for: locationManager.lastLocation ?? CLLocation(latitude: 0, longitude: 0),
              including: .current)
            return forecast
          }.value
        
        var entries: [SimpleEntry] = []
        
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration, locationManager: locationManager, currTemp: String(Int(currentWeather?.temperature.value.rounded() ?? 0))+"º", currSymbolName: currentWeather?.symbolName.safeSymbolName() ?? "xmark")
            entries.append(entry)
        }
        
        return Timeline(entries: entries, policy: .atEnd)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let locationManager: LocationManager
    var currTemp: String
    var currSymbolName: String
    
    var minute : Int{
        Int(Calendar.current.component(.minute, from: date))
    }
    
    var hour: Int{
        Int(Calendar.current.component(.hour, from: date))
    }
}

struct weatherFitWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack{
            LinearGradient(gradient: Gradient(colors: colorScheme == .light ? [.blue,.cyan]:[.black,.blue]), startPoint: .top, endPoint: .bottom)
            VStack(alignment: .leading){
                Text(String(entry.hour) + ":" + String(entry.minute))
                Text(entry.locationManager.userAddress ?? "--º")
                HStack{
                    Image(systemName: entry.currSymbolName)
                    Text(entry.currTemp)
                }
                HStack{
                    Text("외출 시간").font(.caption)
                    Text("\(UserDefaults.shared.integer(forKey: "startTime"))")
                    Text("-")
                    Text("\(UserDefaults.shared.integer(forKey: "endTime"))")
                }
            }
            .padding(.all)
            .foregroundStyle(.white)
        }
    }
}

struct weatherFitWidget: Widget {
    let kind: String = "weatherFitWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            weatherFitWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .contentMarginsDisabled()
    }
}

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "😀"
        return intent
    }
    
    fileprivate static var starEyes: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "🤩"
        return intent
    }
}

extension UserDefaults {
    static var shared: UserDefaults {
        let appGroupId = "group.Hyun.Dev.WeatherFit"
        return UserDefaults(suiteName: appGroupId)!
    }
}

extension String{
    func safeSymbolName() -> String{
        let filledSymbolName = self+".fill"
        return UIImage(systemName: filledSymbolName) == nil ? self : filledSymbolName
    }
}

#Preview(as: .systemSmall) {
    weatherFitWidget()
} timeline: {
    SimpleEntry(date: .now, configuration: .smiley, locationManager: LocationManager(), currTemp: "-", currSymbolName: "cloud.sun.fill")
}

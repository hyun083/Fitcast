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
    
    private static let winter = ["패딩, 두꺼운 코트, 누빔 옷, 기모, 목도리", "코트, 가죽 자켓, 기모"]
    private static let autumn = ["코트, 야상, 점퍼, 스타킹, 기모바지", "자켓, 가디건, 청자켓, 니트, 스타킹, 청바지"]
    private static let spring = ["가디건, 니트, 맨투맨, 후드, 긴바지", "블라우스, 긴팔티, 면바지, 슬랙스"]
    private static let summer = ["반팔, 얆은 셔츠, 반바지, 면바지", "민소매, 반팔, 반바지, 치마, 린넨 옷"]
    private static let seasons = winter + autumn + spring + summer
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), currTemp: "--", currSymbolName: "cloud.sun.fill", currAddress: "--", recommandFit: "--")
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        let currentWeather = await Task.detached(priority: .userInitiated) {
            let forecast = try? await self.service.weather(
                for: locationManager.lastLocation ?? CLLocation(latitude: 0, longitude: 0),
              including: .current)
            return forecast
          }.value
        let address = locationManager.userAddress ?? "--"
        let temp = Int(currentWeather?.temperature.value.rounded() ?? 0)
        let symbolName = currentWeather?.symbolName.safeSymbolName() ?? "xmark"
        
        return SimpleEntry(date: Date(), currTemp: "\(temp)º", currSymbolName: symbolName, currAddress: address, recommandFit: Provider.seasons[temp.position])
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
            let address = locationManager.userAddress ?? "--"
            let temp = Int(currentWeather?.temperature.value.rounded() ?? 0)
            let symbolName = currentWeather?.symbolName.safeSymbolName() ?? "xmark"
            
            let entry = SimpleEntry(date: entryDate, currTemp: "\(temp)º", currSymbolName: symbolName, currAddress: address, recommandFit: Provider.seasons[temp.position])
            entries.append(entry)
        }
        
        return Timeline(entries: entries, policy: .atEnd)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    var currTemp: String
    var currSymbolName: String
    var currAddress: String
    var recommandFit: String
}

struct FitcastWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack{
            LinearGradient(gradient: Gradient(colors: colorScheme == .light ? [.blue,.cyan]:[.black,Color(#colorLiteral(red: 0.1437649727, green: 0.2230264843, blue: 0.3401089311, alpha: 1))]), startPoint: .top, endPoint: .bottom)
            GeometryReader{ geo in
                VStack(alignment: .leading){
                    Text(entry.currAddress)
                    HStack{
                        Image(systemName: entry.currSymbolName)
                            .renderingMode(.original)
                        Text(entry.currTemp)
                    }
                    Spacer()
                    Text(entry.recommandFit)
                    Spacer()
                }
                .padding(.all)
                .foregroundStyle(.white)
            }
        }
    }
}

struct FitcastWidget: Widget {
    let kind: String = "FitcastWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            FitcastWidgetEntryView(entry: entry)
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

#Preview(as: .systemSmall) {
    FitcastWidget()
} timeline: {
    SimpleEntry(date: Date(), currTemp: "19º", currSymbolName: "cloud.sun.fill", currAddress: "용인", recommandFit: "--")
}

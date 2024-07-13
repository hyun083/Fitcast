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
    let viewModel = FitcastWidgetManager()
 
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), id: SelectLocationIntent().location.id, coord: CLLocationCoordinate2D(), currTemp: "--", currSymbolName: "cloud.sun.fill", currAddress: "--", recommandFit: "--")
    }

    func snapshot(for configuration: SelectLocationIntent, in context: Context) async -> SimpleEntry {
        let id = configuration.location.id
        var serviceLocation = configuration.location.location
        var serviceAddress = configuration.location.id
        
        if id == "나의 위치"{
            viewModel.updateLocation()
            serviceLocation = viewModel.lastLocation
            serviceAddress = await viewModel.updateAddress()
        }else{
            viewModel.updateLocation(to: serviceLocation)
        }
        
        await viewModel.getWeather()
        let currentWeather = viewModel.weather
        let temp = Int(currentWeather?.temperature.value.rounded() ?? 0)
        let symbolName = currentWeather?.symbolName.safeSymbolName() ?? "xmark"
        let recommendFit = viewModel.recommendFit(on: temp)
        let coord = serviceLocation.coordinate
        
        return SimpleEntry(date: Date(), id: id, coord: coord, currTemp: "\(temp)º", currSymbolName: symbolName, currAddress: serviceAddress, recommandFit: recommendFit)
    }
    
    func timeline(for configuration: SelectLocationIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let id = configuration.location.id
        var serviceLocation = configuration.location.location
        var serviceAddress = configuration.location.id
        var entries: [SimpleEntry] = []
        let currentDate = Date()
        
        if id == "나의 위치"{
            viewModel.updateLocation()
            serviceLocation = viewModel.lastLocation
            serviceAddress = await viewModel.updateAddress()
        }else{
            viewModel.updateLocation(to: serviceLocation)
        }
        
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: hourOffset, to: currentDate)!
            
            if id == "나의 위치"{
                viewModel.updateLocation()
                serviceLocation = viewModel.lastLocation
                serviceAddress = await viewModel.updateAddress()
            }
            
            await viewModel.getWeather()
            let currentWeather = viewModel.weather
            let temp = Int(currentWeather?.temperature.value.rounded() ?? 0)
            let symbolName = currentWeather?.symbolName.safeSymbolName() ?? "xmark"
            let recommendFit = viewModel.recommendFit(on: temp)
            let coord = serviceLocation.coordinate
            
            let entry = SimpleEntry(date: entryDate, id: id, coord: coord, currTemp: "\(temp)º", currSymbolName: symbolName, currAddress: serviceAddress, recommandFit: recommendFit)
            entries.append(entry)
        }
        
        return Timeline(entries: entries, policy: .atEnd)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let id: String
    let coord: CLLocationCoordinate2D
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
                    HStack{
                        Text(entry.currAddress)
                        Image(systemName: entry.id=="나의 위치" ? "location.fill":"")
                            .font(.caption2)
                    }
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
        .widgetURL(URL(string: "widgetLink://LocationInfo/?address=\(entry.id)&latitude=\(entry.coord.latitude)&longitude=\(entry.coord.longitude)"))
    }
}

struct FitcastWidget: Widget {
    let kind: String = "FitcastWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SelectLocationIntent.self, provider: Provider()) { entry in
            FitcastWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .contentMarginsDisabled()
        .supportedFamilies([.systemSmall,.systemMedium])
        .description("특정 지역의 현재 기상 상태와 추천 옷차림을 표시합니다.")
    }
}

#Preview(as: .systemSmall) {
    FitcastWidget()
} timeline: {
    SimpleEntry(date: Date(), id: "나의 위치", coord: CLLocationCoordinate2D(), currTemp: "4º", currSymbolName: "cloud.sun.fill", currAddress: "용인시", recommandFit: "패딩, 두꺼운 코트, 누빔 옷, 기모, 목도리")
}
#Preview(as: .systemMedium) {
    FitcastWidget()
} timeline: {
    SimpleEntry(date: Date(), id: "나의 위치", coord: CLLocationCoordinate2D(), currTemp: "4º", currSymbolName: "cloud.sun.fill", currAddress: "용인시", recommandFit: "패딩, 두꺼운 코트, 누빔 옷, 기모, 목도리")
}

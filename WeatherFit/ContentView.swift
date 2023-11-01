//
//  ContentView.swift
//  WeatherFit
//
//  Created by Hyun on 10/17/23.
//

import SwiftUI
import WeatherKit
import CoreLocation

struct ContentView: View {
    @ObservedObject var viewModel = WeatherFitManager()
    @State private var scrollViewSize: CGSize = .zero
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        VStack {
            Spacer()
            VStack{
                Text("현재 기온")
                Text(("\(viewModel.currTemp)"))
                    .font(.largeTitle)
                Image(systemName: viewModel.currSymbolName)
                    .font(.title)
            }
            
            VStack{
                Text("외출시 평균 기온")
//                Text("\(viewModel.startTime) ~ \(viewModel.endTime)")
                Text("\(viewModel.avgTemp)")
            }
            .padding(.vertical)
            
            ScrollView(.horizontal, showsIndicators: true){
                LazyHStack(alignment: .center, spacing: 24, content: {
                    ForEach(viewModel.hourlyWeatherInfo) { info in
                        WeatherView(date: info.date, condition: info.condition, temp: info.temp, symbol: info.symbolName)
                    }
                })
            }
            .padding(.horizontal)
            .frame(height: 100)
            .onChange(of: scenePhase){
                if scenePhase == .inactive{
                    viewModel.updateForecastInfo()
                }
            }
            
            Spacer()
            Text(viewModel.recommendFit)
            Spacer()
            HStack{
                timePicker(selectedTime: $viewModel.startTime)
                timePicker(selectedTime: $viewModel.endTime)
            }
        }
        .task{
            await viewModel.getWeather()
        }
    }
}

struct WeatherView: View{
    var date: Date
    var condition: WeatherCondition
    var temp: Measurement<UnitTemperature>
    var symbol: String
    
    var body: some View{
        VStack{
            Text("\(Calendar.current.component(.hour, from: date))")
            ZStack{
                // the darker inset image
                Image(systemName: symbol+".fill")
                    .renderingMode(.original)
                
                // black inner shadow
                Rectangle()
                    .inverseMask(Image(systemName: symbol+".fill"))
                    .shadow(color: Color.gray, radius: 1, x: 0, y: 1)
                    .mask(Image(systemName: symbol+".fill"))
                    .clipped()
                
                // white bottom edges
                Image(systemName: symbol+".fill")
                    .shadow(color: Color.white, radius: 1, x: 0, y: 1.3)
                    .inverseMask(Image(systemName: symbol+".fill"))
            }
            .font(.title)
            Text("\(Int(temp.value.rounded()))")
        }
    }
}

struct ClosetView: View{
    
    var body: some View{
        VStack{
            
        }
    }
}

struct timePicker: View{
    @Binding var selectedTime:Int
    let idx = [Int](0...23)
    let times = ["0:00","1:00","2:00","3:00","4:00","5:00","6:00","7:00","8:00","9:00","10:00","11:00","12:00",
                 "13:00","14:00","15:00","16:00","17:00","18:00","19:00","20:00","21:00","22:00","23:00"]
    
    var body: some View{
        VStack{
            Picker("time picker", selection: $selectedTime, content:{
                ForEach(idx, id:\.self){ idx in
                    Text(times[idx])
                }
            })
            .pickerStyle(.wheel)
        }
    }
}

#Preview {
    ContentView()
}

extension View {
    // https://www.raywenderlich.com/7589178-how-to-create-a-neumorphic-design-with-swiftui
    func inverseMask<Mask>(_ mask: Mask) -> some View where Mask: View {
        self.mask(mask
            .foregroundColor(.black)
            .background(Color.white)
            .compositingGroup()
            .luminanceToAlpha()
        )
    }
}

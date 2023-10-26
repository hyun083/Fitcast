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
//    @State var location = ""
    
    var body: some View {
        VStack {
            Spacer()
            VStack{
                VStack{
//                    Text(viewModel.userAddress())
//                        .font(.largeTitle)
//                        .padding()
                    Text("현재 기온")
                    Text(("\(viewModel.currTemp)"))
                        .font(.largeTitle)
                    Image(systemName: viewModel.symbol)
                    VStack{
                        Text("외출시 평균 기온")
                        Text("\(viewModel.startTime) ~ \(viewModel.endTime)")
                        Text("\(viewModel.avgTemp)")
                    }
                    .padding(.vertical)
                    
//                    Button(action: {
//                        viewModel.changeTimeRange()
//                        UserDefaults.standard.setValue(viewModel.startTime, forKey: "StartTime")
//                        UserDefaults.standard.setValue(viewModel.endTime, forKey: "EndTime")
//                    }, label: {
//                        Text("변경")
//                    })
                }
                
                ScrollView(.horizontal, showsIndicators: false){
                    LazyHStack(alignment: .top, spacing: 24, content: {
                        ForEach(viewModel.hourlyWeatherInfo) { info in
                            WeatherView(date: info.date, condition: info.condition, temp: info.temp, symbol: info.symbolName)
                        }
                    })
                    .fixedSize()
                }
                .padding(.all)
                
//                Text(viewModel.recommendFit)
            }
            
            
            Spacer()
            VStack{
                HStack{
                    timePicker(selectedTime: $viewModel.startTime)
                    timePicker(selectedTime: $viewModel.endTime)
                }
            }
        }
        .task{
            await viewModel.getWeather()
        }
//        .onAppear(){
//            viewModel.startTime = UserDefaults.standard.string(forKey: "StartTime") ?? "07:00"
//            viewModel.endTime = UserDefaults.standard.string(forKey: "EndTime") ?? "09:00"
//            print(viewModel.startTime)
//            print(viewModel.endTime)
//            print(viewModel.timeRange())
//        }
//        .onDisappear(){
//            UserDefaults.standard.setValue(viewModel.startTime, forKey: "StartTime")
//            UserDefaults.standard.setValue(viewModel.endTime, forKey: "EndTime")
//        }
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
            Image(systemName: symbol)
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
    let times = [Int](0...23)
//    let times = ["0:00","1:00","2:00","3:00","4:00","5:00","6:00","7:00","8:00","9:00","10:00","11:00","12:00",
//                 "13:00","14:00","15:00","16:00","17:00","18:00","19:00","20:00","21:00","22:00","23:00"]
    
    var body: some View{
        VStack{
            Picker("time picker", selection: $selectedTime, content:{
                ForEach(times, id:\.self){ time in
                    Text("\(time)")
                }
            })
            .pickerStyle(.wheel)
        }
    }
}

#Preview {
    ContentView()
}

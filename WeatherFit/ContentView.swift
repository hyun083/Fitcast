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
    @State var recommendFit:Int?
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack{
            AngularGradient.init(gradient: Gradient(colors: colorScheme == .light ? [.blue,.cyan]:[.black, .gray]), center: .topLeading, angle: .degrees(180+55)).ignoresSafeArea(.all)
            VStack {
                HStack{
                    VStack{
                        Text("현재 기온")
                        HStack{
                            Image(systemName: viewModel.currSymbolName)
                            Text(("\(viewModel.currTemp)º"))
                        }
                    }
                    Spacer()
                    VStack{
                        Text("외출 시간")
                        HStack{
                            Text("\(viewModel.startTime)")
                            Text("~")
                            Text("\(viewModel.endTime)")
                        }
                    }
                }
                .padding(.horizontal)
                
                VStack{
                    Text(viewModel.currAddress)
                        .font(.largeTitle)
                    Text("외출 시 평균 기온")
                    Text("\(viewModel.avgTemp)º")
                        .font(.largeTitle)
                }
                .padding(.vertical)
                ScrollView(.horizontal, showsIndicators: false){
                    LazyHStack(alignment: .center, spacing: 24, content: {
                        ForEach(viewModel.hourlyWeatherInfo) { info in
                            WeatherView(date: info.date, condition: info.condition, temp: info.temp, symbolName: info.symbolName.safeSymbolName())
                        }
                    })
                }
                .padding(.horizontal)
                .frame(height: 100)
                
                GeometryReader { geo in
                    ScrollView(.horizontal, showsIndicators: true){
                        HStack(spacing:0){
                            ForEach(viewModel.closet.indices, id: \.self) { idx in
                                ClosetView(tempRange: viewModel.tempRange[idx], recommendFit: viewModel.closet[idx])
                                    .frame(width: geo.size.width, height: geo.size.height)
                            }
                        }
                    }
                    .scrollTargetBehavior(.paging)
                    .scrollPosition(id: $recommendFit)
                }
                .onChange(of: viewModel.avgTemp, {
                    recommendFit = viewModel.recommendFit
                })
                
                HStack{
                    timePicker(selectedTime: $viewModel.startTime)
                    timePicker(selectedTime: $viewModel.endTime)
                }
            }
            .task{
                await viewModel.getWeather()
            }
            .onChange(of: scenePhase){
                if scenePhase == .inactive{
                    Task{
                        viewModel.updateLocation()
                        await viewModel.getWeather()
                    }
                }
            }
        }
    }
}

struct WeatherView: View{
    var date: Date
    var condition: WeatherCondition
    var temp: Measurement<UnitTemperature>
    var symbolName: String
    
    var body: some View{
        VStack{
            Text("\(Calendar.current.component(.hour, from: date))")
            ZStack{
                Image(systemName: symbolName)
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
            Text("\(Int(temp.value.rounded()))º")
        }
    }
}

struct ClosetView: View{
    var tempRange = "기온 범위"
    var recommendFit = "추천 의상"
    var body: some View{
        VStack(alignment:.leading){
            Text(tempRange)
            Text(recommendFit)
                .font(.title2)
        }
        .padding(.horizontal)
        .shadow(radius: 7, y:9)
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

extension String{
    func safeSymbolName() -> String{
        let filledSymbolName = self+".fill"
        return UIImage(systemName: filledSymbolName) == nil ? self : filledSymbolName
    }
}

//
//  ContentView.swift
//  WeatherFit
//
//  Created by Hyun on 10/17/23.
//

import SwiftUI
import WeatherKit
import CoreLocation
import WidgetKit

struct ContentView: View {
    @ObservedObject var viewModel = FitcastManager()
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.colorScheme) var colorScheme
    @State private var scrollViewSize: CGSize = .zero
    @State var closetPosition: ForecastInfo.Clothes.ID?
    @State var isListViewPresented = false
    @State var isSearchViewPresented = false
    
    var body: some View {
        ZStack{
            //MARK: - GradientBackground
            LinearGradient(gradient: Gradient(colors: colorScheme == .light ? [.blue,.cyan]:[.black,Color(#colorLiteral(red: 0.1437649727, green: 0.2230264843, blue: 0.3401089311, alpha: 1))]), startPoint: .top, endPoint: .bottomLeading).ignoresSafeArea(.all)
            
            VStack {
                //MARK: - CurrTemp and UserTime
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
                            Text("\(viewModel.startTime)시")
                            Text("~")
                            Text("\(viewModel.endTime)시")
                        }
                    }
                }
                .padding(.horizontal)
                .font(.subheadline)
                
                //MARK: - AvgTemp
                VStack{
                    Text(viewModel.addressLabel)
                        .font(.largeTitle)
                    Text("외출 시 평균 기온")
                    Text("\(viewModel.avgTemp)º")
                        .font(.largeTitle)
                }
                .shadow(radius: 1, y:1.3)
                
                //MARK: - HourlyWeather
                ZStack{
                    Color.white
                        .blur(radius: 350)
                    VStack(alignment:.trailing){
                        ScrollView(.horizontal, showsIndicators: false){
                            LazyHStack(alignment: .center, spacing: 25, content: {
                                ForEach(viewModel.hourlyWeatherInfo) { info in
                                    WeatherView(date: info.date, condition: info.condition, temp: info.temp, symbolName: info.symbolName.safeSymbolName())
                                }
                            })
                        }
                        .padding(EdgeInsets(top: 30, leading: 10, bottom: 0, trailing: 10))
                        
                        Link(destination: URL(string: "https://developer.apple.com/weatherkit/data-source-attribution/")!, label: {
                            Text("provided by  Weather")
                                .font(.caption2)
                        })
                        .padding(EdgeInsets(top: 10, leading: 0, bottom: 5, trailing: 15))
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal)
                .frame(height: 160)
                
                //MARK: - Closet
                GeometryReader { geo in
                    ScrollView(.horizontal, showsIndicators: false){
                        LazyHStack(){
                            ForEach(viewModel.closet, id: \.self.id) { closet in
                                ClosetView(tempRange: closet.tempRange, recommendFit: closet.recommendFit)
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .scrollTargetBehavior(.viewAligned)
                    .scrollPosition(id: $closetPosition)
                    .safeAreaPadding(.all)
                    .scrollClipDisabled()
                }
                .onChange(of: viewModel.avgTemp, {
                    withAnimation{
                        closetPosition = viewModel.avgTemp.position
                    }
                })
                .onChange(of: viewModel.startTime + viewModel.endTime, {
                    withAnimation{
                        closetPosition = viewModel.avgTemp.position
                    }
                })
                
                //MARK: - timePicker
                HStack{
                    timePicker(selectedTime: $viewModel.startTime, idx: [Int](0...23))
                    timePicker(selectedTime: $viewModel.endTime, idx: [Int](0...23))
                }
                
                //MARK: - searchView
                HStack{
                    Spacer()
                    Button(action: {
                        self.isSearchViewPresented.toggle()
                    }, label: {
                        Image(systemName: "magnifyingglass")
                    })
                    .fullScreenCover(isPresented: $isSearchViewPresented, content: {
                        SearchView(viewModel: viewModel, isSearchViewVisible: $isSearchViewPresented)
                    })
                    Spacer()
                    Button(action: {
                        self.isListViewPresented.toggle()
                    }, label: {
                        Image(systemName: "list.bullet")
                    })
                    .fullScreenCover(isPresented: $isListViewPresented, content: {
                        ListView(viewModel: viewModel, isListViewVisible: $isListViewPresented)
                    })
                    Spacer()
                }
            }
            }
            .onChange(of: scenePhase){
                if scenePhase == .inactive{
                    viewModel.selectedCurrLocation = viewModel.selectedLocationIdx >= viewModel.locationList.count ? true:viewModel.selectedCurrLocation
                    if viewModel.selectedCurrLocation{
                        print("update location and weather")
                        viewModel.updateLocation()
                        WidgetCenter.shared.reloadAllTimelines()
                    }else{
                        Task{
                            print("update weather")
                            await viewModel.getWeather()
                        }
                    }
                }
            }
            .onChange(of: viewModel.publishedLocation, {
                Task{
                    print("lastLocation changed:")
                    await viewModel.getWeather()
                    await viewModel.updateUserAddress()
                }
            })
        }
        .foregroundStyle(.white)
    }
}

//MARK: - WeatherView
struct WeatherView: View{
    var date: Date
    var condition: WeatherCondition
    var temp: Measurement<UnitTemperature>
    var symbolName: String
    
    var body: some View{
        VStack{
            Text("\(Calendar.current.component(.hour, from: date))시")
            ZStack{
                Image(systemName: symbolName)
                    .renderingMode(.original)
                    .shadow(radius: 1, y:1.3)
                
                Rectangle()
                    .foregroundStyle(.clear)
            }
            .font(.title)
            Text("\(Int(temp.value.rounded()))º")
        }
    }
}

//MARK: - ClosetView
struct ClosetView: View{
    var tempRange: String
    var recommendFit: String
    
    var body: some View{
        ZStack{
            Color.white
                .blur(radius: 350)
            VStack(alignment:.leading){
                Text(tempRange)
                Text(recommendFit)
                    .font(.title2)
            }
            .padding(.horizontal)
            .shadow(radius: 1, y:1.3)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .containerRelativeFrame(.horizontal, count: 1, span: 1, spacing: 10.0)
        .scrollTransition(topLeading: .interactive,
                          bottomTrailing: .interactive,
                          axis: .horizontal,
                          transition: {effect, phase in
            effect
                .scaleEffect(1-abs(phase.value))
                .opacity(1-abs(phase.value))
                .rotation3DEffect(.degrees(phase.value * 90), axis: (0.001, 1, 0.001))
        })
    }
}

//MARK: - TimePickerView
struct timePicker: View{
    @Binding var selectedTime:Int
    let idx: [Int]
    let times = ["0:00","1:00","2:00","3:00","4:00","5:00","6:00","7:00","8:00","9:00","10:00","11:00","12:00",
                 "13:00","14:00","15:00","16:00","17:00","18:00","19:00","20:00","21:00","22:00","23:00"]
    
    var body: some View{
        VStack{
            Picker("time picker", selection: $selectedTime, content:{
                ForEach(idx, id:\.self){ idx in
                    Text(times[idx])
                        .foregroundStyle(.white)
                }
            })
            .pickerStyle(.wheel)
        }
    }
}

//MARK: - PreView
#Preview {
    ContentView()
}

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
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.colorScheme) var colorScheme
    @State private var scrollViewSize: CGSize = .zero
    @State var closetPosition: ForecastInfo.Clothes.ID?
    
    var body: some View {
        ZStack{
            //MARK: - GradientBackground
            LinearGradient(gradient: Gradient(colors: colorScheme == .light ? [.blue,.cyan]:[.black,.blue]), startPoint: .top, endPoint: .bottomLeading).ignoresSafeArea(.all)
            
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
                    Text(viewModel.currAddress)
                        .font(.largeTitle)
                    Text("외출 시 평균 기온")
                    Text("\(viewModel.avgTemp)º")
                        .font(.largeTitle)
                }
                .shadow(radius: 1, y:1.3)
                
                //MARK: - HourlyWeather
                ScrollView(.horizontal, showsIndicators: false){
                    ZStack{
                        Color.white
                            .blur(radius: 350)
                        LazyHStack(alignment: .center, spacing: 27, content: {
                            ForEach(viewModel.hourlyWeatherInfo) { info in
                                WeatherView(date: info.date, condition: info.condition, temp: info.temp, symbolName: info.symbolName.safeSymbolName())
                            }
                        })
                    }
                    .padding(.all)
                }
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal)
                .frame(height: 150)
                
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
                        closetPosition = viewModel.recommendFitPosition
                    }
                })
                .onChange(of: viewModel.startTime + viewModel.endTime, {
                    withAnimation{
                        closetPosition = viewModel.recommendFitPosition
                    }
                })
                
                //MARK: - timePicker
                HStack{
                    timePicker(selectedTime: $viewModel.startTime, idx: [Int](0...23))
                    timePicker(selectedTime: $viewModel.endTime, idx: [Int](0...23))
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

//MARK: - extensions
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

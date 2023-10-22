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
    @ObservedObject var viewModel = WeatherFitViewModel(startTime: "1:00", endTime: "13:00")
//    @State var startTime = viewModel.startTime
//    @State var endTime = viewModel.endTime
//    @State var location = ""
    
    var body: some View {
        VStack {
            Spacer()
            VStack{
                VStack{
                    Text("현재 기온")
                    Text("\(Int(viewModel.currTemp().value.rounded())) \(viewModel.currTemp().unit.symbol)")
                        .font(.largeTitle)
                    Text(viewModel.currCondition())
                    Image(systemName: "cloud.sun.fill")
                    Text("외출시 평균 기온")
                    Text("\(viewModel.startTime) ~ \(viewModel.endTime)")
                    Text("\(viewModel.avgTemperature()) \(viewModel.currTemp().unit.symbol)")
                    Button(action: {
                        viewModel.changeTimeRange()
                    }, label: {
                        /*@START_MENU_TOKEN@*/Text("Button")/*@END_MENU_TOKEN@*/
                    })
                }
                
                ScrollView(.horizontal, showsIndicators: false){
                    LazyHStack(alignment: .top, spacing: 24, content: {
                        ForEach(viewModel.hourlyWeather) { info in
                            WeatherView(date: info.date, condition: info.condition, temp: info.temp)
                        }
                    })
                    .fixedSize()
                }
                .padding(.all)
            }
            
            
            Spacer()
            VStack{
                
                HStack{
                    timePicker(selectedTime: $viewModel.startTime)
                    timePicker(selectedTime: $viewModel.endTime)
                }
            }
//            TextField("location", text: $location)
//                .padding()
//                .background(Color(uiColor: .secondarySystemBackground))
//                .textFieldStyle(.roundedBorder)
        }
        .task {
            await viewModel.update()
        }
    }
}

struct WeatherView: View{
    var date: Date
    var condition: WeatherCondition
    var temp: Measurement<UnitTemperature>
    
    var body: some View{
        VStack{
            Text("\(Calendar.current.component(.hour, from: date))")
            Image(systemName: WeatherType.cloud.systemNameIcon)
                .imageScale(.large)
//            Text("\(condition.accessibilityDescription)")
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
    @Binding var selectedTime:String
    let times = ["0:00","1:00","2:00","3:00","4:00","5:00","6:00","7:00","8:00","9:00","10:00","11:00","12:00",
                 "13:00","14:00","15:00","16:00","17:00","18:00","19:00","20:00","21:00","22:00","23:00"]
    
    var body: some View{
        VStack{
            Picker("time picker", selection: $selectedTime, content:{
                ForEach(times, id:\.self){ time in
                    Text(time)
                }
            })
            .pickerStyle(.wheel)
        }
    }
}

#Preview {
    ContentView()
}

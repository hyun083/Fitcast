//
//  SearchView.swift
//  Fitcast
//
//  Created by Hyun on 1/6/24.
//

import Foundation
import SwiftUI
import CoreLocation
import MapKit
import Combine

struct SearchView: View{
    @ObservedObject var viewModel: FitcastManager
    @Environment(\.colorScheme) var colorScheme
    @Binding var isSearchViewVisible: Bool
    
    var body: some View{
        NavigationView{
            VStack{
                SearchBar(text: $viewModel.locationSearchService.searchQuery)
                
                List(viewModel.locationSearchService.completions){ completion in
                    VStack(alignment: .leading){
                        Button(action: {
                            CLGeocoder().geocodeAddressString(completion.title) { (placemarks, error) in
                                if let placemarks = placemarks, let location = placemarks.first?.location{
                                    let area = placemarks.first?.subLocality ?? placemarks.first?.locality ?? placemarks.first?.administrativeArea ?? completion.title
                                    
                                    let newLocation = FitcastLocation(title: completion.title, locality:  area, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                                    viewModel.addNewLocation(newLocation)
                                    viewModel.updateLocation(to: newLocation)
                                    Task{
                                        await viewModel.getWeather()
                                    }
                                    self.isSearchViewVisible.toggle()
                                } else {
                                    print("주소를 찾을 수 없습니다.")
                                }
                            }
                        }, label: {
                            Text(completion.title + " " + completion.subtitle)
                        })
                    }
                }
                .contentMargins(0)
                .onChange(of: self.isSearchViewVisible, {
                    viewModel.locationSearchService.searchQuery = ""
                    viewModel.locationSearchService.completions = []
                })
            }
            .navigationTitle("지역 정보 추가")
            .toolbar{
                ToolbarItemGroup(placement: .topBarTrailing, content: {
                    Button("완료"){
                        self.isSearchViewVisible.toggle()
                    }
                    .foregroundStyle(Color.accentColor)
                    .font(.title3)
                    .bold()
                })
            }
        }
        .foregroundStyle(colorScheme == .light ? .black : .white)
    }
    
}

struct SearchBar: UIViewRepresentable{
    @Binding var text:String
    
    class Coordinator: NSObject, UISearchBarDelegate{
        @Binding var text: String
        
        init(text: Binding<String>) {
            _text = text
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
            text = searchText
        }
    }
    
    func makeCoordinator() -> SearchBar.Coordinator{
        return Coordinator(text: $text)
    }
    
    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
        let searchBar = UISearchBar(frame:  .zero)
        searchBar.delegate = context.coordinator
        searchBar.searchBarStyle = .minimal
        return searchBar
    }
    
    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
        uiView.text = text
    }
}

struct SearchView_preview: PreviewProvider{
    @State static var flag = true
    
    static var previews: some View {
        SearchView(viewModel: FitcastManager(), isSearchViewVisible: $flag)
    }
}

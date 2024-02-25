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
    @ObservedObject var locationSearchService: LocationSearchService
    @ObservedObject var viewModel: FitcastManager
    @Environment(\.colorScheme) var colorScheme
    @State var target = CLLocationCoordinate2D()
    @Binding var isVisible: Bool
    
    var body: some View{
        NavigationView{
            VStack{
                SearchBar(text: $locationSearchService.searchQuery)
                
                List(locationSearchService.completions){ completion in
                    VStack(alignment: .leading){
                        Button(action: {
                            CLGeocoder().geocodeAddressString(completion.title) { (placemarks, error) in
                                if let placemarks = placemarks, let location = placemarks.first?.location{
                                    self.target = location.coordinate
                                    let area = placemarks.first?.locality ?? "locality error"
                                    let newLocation = FitcastLocation(title: completion.title, locality:  area, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                                    viewModel.addNewLocation(newLocation)
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
                .onChange(of: target, {
                    print("this is listView")
                    print(viewModel.locationList)
                    self.isVisible.toggle()
                })
            }
            .navigationTitle("지역 정보 추가")
            .toolbar{
                ToolbarItemGroup(placement: .topBarTrailing, content: {
                    Button("완료"){
                        self.isVisible.toggle()
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

class LocationSearchService: NSObject, ObservableObject, MKLocalSearchCompleterDelegate{
    @Published var searchQuery = ""
    var completer: MKLocalSearchCompleter
    @Published var completions: [MKLocalSearchCompletion] = []
    var cancellable: AnyCancellable?
    
    override init(){
        completer = MKLocalSearchCompleter()
        completer.resultTypes = .address
        super.init()
        cancellable = $searchQuery.assign(to: \.queryFragment, on: self.completer)
        completer.delegate = self
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.completions = completer.results
    }
    
    func getCoordinate(from address:String) -> CLLocationCoordinate2D{
        var res = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        
        CLGeocoder().geocodeAddressString(address) { (placemarks, error) in
            if let placemarks = placemarks, let location = placemarks.first?.location {
                print(location.coordinate)
                res = location.coordinate
                
            } else {
                print("주소를 찾을 수 없습니다.")
            }
        }
        
        return res
    }
}

struct SearchView_preview: PreviewProvider{
    @State static var flag = true
    
    static var previews: some View {
        SearchView(locationSearchService: LocationSearchService(), viewModel: FitcastManager(), isVisible: $flag)
    }
}

extension MKLocalSearchCompletion: Identifiable{}
extension CLLocationCoordinate2D : Equatable{
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude ? lhs.longitude==rhs.longitude : lhs.latitude==rhs.latitude
    }
}

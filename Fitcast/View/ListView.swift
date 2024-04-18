//
//  ListView.swift
//  Fitcast
//
//  Created by Hyun on 2/6/24.
//

import Foundation
import SwiftUI

struct ListView: View{
    var viewModel:FitcastManager
    @Environment(\.colorScheme) var colorScheme
    @Binding var isListViewVisible:Bool
    @Environment(\.editMode) var editMode
    
    var body: some View{
        NavigationView{
//            VStack(alignment: .leading){
//            }
            List(){
                Button(action: {
                    viewModel.selectedCurrLocation = true
                    viewModel.updateLocation()
                    self.isListViewVisible.toggle()
                }, label: {
                    Text("현재 위치")
                })
                ForEach(viewModel.locationList, id:\.self){ location in
                    Button(action: {
                        viewModel.selectedCurrLocation = false
                        viewModel.updateLocation(to: location)
                        viewModel.selectedLocationIdx = viewModel.locationList.firstIndex(of: location)!
                        self.isListViewVisible.toggle()
                    }, label: {
                        Text(location.title)
                    })
                }
                .onDelete(perform: { indexSet in
                    viewModel.removeLocationAt(index: indexSet)
                })
                .onMove(perform: { indices, newOffset in
                    viewModel.moveLocation(From: indices, to: newOffset)
                })
            }
            .navigationTitle("위치")
//            .toolbar{
//                EditButton()
//                    .foregroundStyle(Color.accentColor)
//                    .font(.title3)
//                    .bold()
//            }
            .contentMargins(10)
            .listStyle(InsetGroupedListStyle())
        }
        .foregroundStyle(colorScheme == .light ? .black : .white)
    }
}

struct ListView_preview: PreviewProvider{
    @State static var flag = true
    
    static var previews: some View {
        ListView(viewModel: FitcastManager(), isListViewVisible: $flag)
    }
}

//
//  WeatherFitApp.swift
//  WeatherFit
//
//  Created by Hyun on 10/17/23.
//

import SwiftUI

@main
struct FitcastApp: App {
    @AppStorage("selectedCurrLocation") var selectedCurrLocation:Bool = true
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

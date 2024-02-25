//
//  FitcastLocation.swift
//  Fitcast
//
//  Created by Hyun on 2/8/24.
//

import Foundation

struct FitcastLocation: Codable, Hashable{
    let title:String
    let locality:String
    let latitude:Double
    let longitude:Double
}

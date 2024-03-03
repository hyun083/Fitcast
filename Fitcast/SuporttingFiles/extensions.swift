//
//  extensions.swift
//  WeatherFit
//
//  Created by Hyun on 11/28/23.
//

import Foundation
import UIKit
import MapKit

extension UserDefaults {
    static var shared: UserDefaults {
        let appGroupId = "group.Hyun.Dev.WeatherFit"
        return UserDefaults(suiteName: appGroupId)!
    }
}

extension String{
    func safeSymbolName() -> String{
        let filledSymbolName = self+".fill"
        return UIImage(systemName: filledSymbolName) == nil ? self : filledSymbolName
    }
}

extension Int{
    var position: Int{
        get{
            if self <= 4{
                return 0
            }else if self <= 8{
                return 1
            }else if self <= 11{
                return 2
            }else if self <= 16{
                return 3
            }else if self <= 19{
                return 4
            }else if self <= 22{
                return 5
            }else if self <= 27{
                return 6
            }else{
                return 7
            }
        }
    }
}

extension MKLocalSearchCompletion: Identifiable{}
extension CLLocationCoordinate2D : Equatable{
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude ? lhs.longitude==rhs.longitude : lhs.latitude==rhs.latitude
    }
}

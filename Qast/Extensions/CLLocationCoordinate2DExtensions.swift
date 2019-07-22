//
//  CLLocationCoordinate2DExtensions.swift
//  Qast
//
//  Created by Austin Welch on 7/11/19.
//  Copyright © 2019 Qast. All rights reserved.
//

import CoreLocation.CLLocation
import FirebaseFirestore.FIRGeoPoint

extension CLLocationCoordinate2D {
    var geopoint: GeoPoint {
        return GeoPoint(latitude: latitude, longitude: longitude)
    }
        
    /// Compare two coordinates
    /// - parameter coordinate: another coordinate to compare
    /// - return: bool value
    func isEqual(to coordinate: CLLocationCoordinate2D) -> Bool {
        
        if self.latitude != coordinate.latitude &&
            self.longitude != coordinate.longitude {
            return false
        }
        return true
    }
    
    /// check the coordinate is empty or default
    /// return Bool value
    var isDefaultCoordinate: Bool {
        
        if self.latitude == 0.0 && self.longitude == 0.0 {
            return true
        }
        return false
    }
    
}

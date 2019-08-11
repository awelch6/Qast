//
//  GeoPointExtensions.swift
//  Qast
//
//  Created by Austin Welch on 7/11/19.
//  Copyright © 2019 Qast. All rights reserved.
//

import CoreLocation.CLLocation
import FirebaseFirestore.FIRGeoPoint

extension GeoPoint {
    var location: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}



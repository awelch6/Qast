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
}

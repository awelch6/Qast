//
//  SoundZone.swift
//  Qast
//
//  Created by Austin Welch on 7/6/19.
//  Copyright © 2019 Qast. All rights reserved.
//

import FirebaseFirestore.FIRGeoPoint
import CoreLocation.CLLocation

struct SoundZone {
    let id: String
    let center: GeoPoint
    let radius: Double
    let trackId: String
    
    var bufferRadius: Double {
        return radius + 10 //add 10 meters for now.
    }
    
    init?(dictionary: [String: Any]) {
        guard
            let id = dictionary["id"] as? String,
            let center = dictionary["center"] as? GeoPoint,
            let radius = dictionary["radius"] as? Double,
            let trackId = dictionary["trackId"] as? String
            else {
                return nil
        }
        self.id = id
        self.center = center
        self.radius = radius
        self.trackId = trackId
    }
}

// MARK: Volume Control

extension SoundZone {
    
    /// Returns the correct volume level for distance away from sound zone
    func volume(from location: CLLocation) -> Float {
        let zoneCenter = CLLocation(latitude: center.latitude, longitude: center.longitude)
        
        let distance = zoneCenter.distance(from: location)
        
        if distance <= radius {
            return 1
        } else if distance > bufferRadius {
            return 0
        } else {
            return Float(1 - ((distance - radius) / (bufferRadius - radius)))
        }
    }
}

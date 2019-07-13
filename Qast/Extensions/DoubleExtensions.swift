//
//  DoubleExtensions.swift
//  Qast
//
//  Created by Austin Welch on 7/5/19.
//  Copyright © 2019 Qast. All rights reserved.
//

extension Double {
    /// Converts a double in degrees to radians
    func toRadians() -> Double {
        return self * .pi / 180
    }
    
    /// Converts a double in radians to degrees
    func toDegrees() -> Double {
        return self * 180 / .pi
    }
    
    /// converts miles to meters
    func toMeters() -> Double {
        return self / 6371000.0
    }
    
    /// meters to points
    func toPoints() -> Double {
        // MGLAnnotationViews are defined in pixels. We use meters in SoundZone
        // Approximated a conversion factor based on 90 meters (1 block) at zoom level 15
        // Would require a zoom-level divisor and tweening to update annotation radius with zoom
        return self * 0.55
    }
    
}

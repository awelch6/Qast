//
//  VisionManager.swift
//  Qast
//
//  Created by Austin Welch on 7/5/19.
//  Copyright © 2019 Qast. All rights reserved.
//

import Mapbox
import BoseWearable

struct VisionManager {
    
    public let viewingAngle: Double = 90
    
    public var radius: Double = 10
    
    private(set) public var visionPolygon: MGLPolygon?
    
    public mutating func updateVisionPolygon(center: CLLocationCoordinate2D, orientation: Double) {
        let radiusInMeters = radius.toMeters()
        
        let centerLatRadians = center.latitude.toRadians()
        let centerLonRadians = center.longitude.toRadians()
        
        let pointLatRadians = asin(sin(centerLatRadians) * cos(radiusInMeters) + cos(centerLatRadians) * sin(radiusInMeters) * cos(leftOffset(orientation)))
        let pointLonRadians = centerLonRadians - atan2(sin(leftOffset(orientation)) * sin(radiusInMeters) * cos(centerLatRadians), cos(radiusInMeters) - sin(centerLatRadians) * sin(pointLatRadians))
        let leftPoint = CLLocationCoordinate2D(latitude: pointLatRadians.toDegrees(), longitude: pointLonRadians.toDegrees())
        
        let pointLatRadians2 = asin(sin(centerLatRadians) * cos(radiusInMeters) + cos(centerLatRadians) * sin(radiusInMeters) * cos(rightOffset(orientation)))
        let pointLonRadians2 = centerLonRadians - atan2(sin(rightOffset(orientation)) * sin(radiusInMeters) * cos(centerLatRadians), cos(radiusInMeters) - sin(centerLatRadians) * sin(pointLatRadians))
        let rightPoint = CLLocationCoordinate2D(latitude: pointLatRadians2.toDegrees(), longitude: pointLonRadians2.toDegrees())
        
        visionPolygon = MGLPolygon(coordinates: [center, leftPoint, rightPoint], count: 3)
    }
    
    private func leftOffset(_ orientation: Double) -> Double {
        return (orientation - (viewingAngle / 2)).toRadians()
    }
    
    private func rightOffset(_ orientation: Double) -> Double {
        return (orientation + (viewingAngle / 2)).toRadians()
    }
}

private extension Double {
    /// Converts a double in degrees to radians
    func toRadians() -> Double {
        return self * .pi / 180
    }
    
    /// Converts a double in radians to degrees
    func toDegrees() -> Double {
        return self * 180 / .pi
    }
    
    /// converts
    func toMeters() -> Double {
        return self / 6371000.0
    }
}

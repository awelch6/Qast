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
    
    public let viewingAngle: Double
    
    public var radius: Double
    
    private(set) public var visionPath: UIBezierPath?
    
    init(viewingAngle: Double = 90, radius: Double = 10) {
        self.viewingAngle = viewingAngle
        self.radius = radius
    }
    
    public mutating func updateVisionPath(center: CLLocationCoordinate2D, orientation: Double) {
        let radiusInMeters = radius.toMeters()
        
        let centerLatRadians = center.latitude.toRadians()
        let centerLonRadians = center.longitude.toRadians()
        
        let pointLatRadians = asin(sin(centerLatRadians) * cos(radiusInMeters) + cos(centerLatRadians) * sin(radiusInMeters) * cos(leftOffset(orientation)))
        let pointLonRadians = centerLonRadians - atan2(sin(leftOffset(orientation))
            * sin(radiusInMeters) * cos(centerLatRadians), cos(radiusInMeters) - sin(centerLatRadians) * sin(pointLatRadians))

        let pointLatRadians2 = asin(sin(centerLatRadians) * cos(radiusInMeters) + cos(centerLatRadians) * sin(radiusInMeters) * cos(rightOffset(orientation)))
        let pointLonRadians2 = centerLonRadians - atan2(sin(rightOffset(orientation))
            * sin(radiusInMeters) * cos(centerLatRadians), cos(radiusInMeters) - sin(centerLatRadians) * sin(pointLatRadians))

        let path = UIBezierPath()
        path.move(to: CGPoint(x: center.latitude, y: center.longitude))
        path.addLine(to: CGPoint(x: pointLatRadians.toDegrees(), y: pointLonRadians.toDegrees()))
        path.addLine(to: CGPoint(x: pointLatRadians2.toDegrees(), y: pointLonRadians2.toDegrees()))
        path.close()
        
        visionPath = path
    }
    
    ///This function is just for showing viewing angle.
    public mutating func updateVisionPolygon(center: CLLocationCoordinate2D, orientation: Double) -> MGLPolygon {
        let radiusInMeters = radius.toMeters()
        
        let centerLatRadians = center.latitude.toRadians()
        let centerLonRadians = center.longitude.toRadians()
        
        let pointLatRadians = asin(sin(centerLatRadians) * cos(radiusInMeters) + cos(centerLatRadians) * sin(radiusInMeters) * cos(leftOffset(orientation)))
        let pointLonRadians = centerLonRadians - atan2(sin(leftOffset(orientation))
            * sin(radiusInMeters) * cos(centerLatRadians), cos(radiusInMeters) - sin(centerLatRadians) * sin(pointLatRadians))
        let leftPoint = CLLocationCoordinate2D(latitude: pointLatRadians.toDegrees(), longitude: pointLonRadians.toDegrees())
        
        let pointLatRadians2 = asin(sin(centerLatRadians) * cos(radiusInMeters) + cos(centerLatRadians) * sin(radiusInMeters) * cos(rightOffset(orientation)))
        let pointLonRadians2 = centerLonRadians - atan2(sin(rightOffset(orientation))
            * sin(radiusInMeters) * cos(centerLatRadians), cos(radiusInMeters) - sin(centerLatRadians) * sin(pointLatRadians))
        let rightPoint = CLLocationCoordinate2D(latitude: pointLatRadians2.toDegrees(), longitude: pointLonRadians2.toDegrees())
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: center.latitude, y: center.longitude))
        path.addLine(to: CGPoint(x: pointLatRadians.toDegrees(), y: pointLonRadians.toDegrees()))
        path.addLine(to: CGPoint(x: pointLatRadians2.toDegrees(), y: pointLonRadians2.toDegrees()))
        path.close()
        
        return MGLPolygon(coordinates: [center, leftPoint, rightPoint], count: 3)
    }
    
    public func contains(_ coordinate: CLLocationCoordinate2D) -> Bool {
        if let visionPath = visionPath {
            return visionPath.contains(CGPoint(x: coordinate.latitude, y: coordinate.longitude))
        }
        return false
    }
}

// MARK: Utilities
extension VisionManager {
    
    private func leftOffset(_ orientation: Double) -> Double {
        return (orientation - (viewingAngle / 2)).toRadians()
    }
    
    private func rightOffset(_ orientation: Double) -> Double {
        return (orientation + (viewingAngle / 2)).toRadians()
    }
}

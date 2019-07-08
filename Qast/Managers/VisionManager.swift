//
//  VisionManager.swift
//  Qast
//
//  Created by Austin Welch on 7/5/19.
//  Copyright © 2019 Qast. All rights reserved.
//

import Mapbox
import BoseWearable

enum VisionOffsetType {
    case left
    case right
    
    public func offset(viewingAngle: Double, orientation: Double) -> Double {
        switch self {
        case .left:
            return (orientation - (viewingAngle / 2)).toRadians()
        case .right:
            return (orientation + (viewingAngle / 2)).toRadians()
        }
    }
}

struct VisionManager {
    
    public let viewingAngle: Double
    
    public var radius: Double
    
    private(set) public var visionPath: UIBezierPath?
    
    init(viewingAngle: Double = 90, radius: Double = 10) {
        self.viewingAngle = viewingAngle
        self.radius = radius
    }
    
    public mutating func updateVisionPath(center: CLLocationCoordinate2D, orientation: Double) {

        let leftPoint = offsetPoint(for: .left, center: center, orientation: orientation)
        let rightPoint = offsetPoint(for: .right, center: center, orientation: orientation)
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: center.latitude, y: center.longitude))
        path.addLine(to: CGPoint(x: leftPoint.x, y: leftPoint.y))
        path.addLine(to: CGPoint(x: rightPoint.x, y: rightPoint.y))
        path.close()
        
        visionPath = path
    }
    
    ///This function is just for showing viewing angle.
    public mutating func updateVisionPolygon(center: CLLocationCoordinate2D, orientation: Double) -> MGLPolygon {
        let leftPoint = offsetPoint(for: .left, center: center, orientation: orientation)
        let rightPoint = offsetPoint(for: .right, center: center, orientation: orientation)

        let coordinates = [center, CLLocationCoordinate2D(latitude: Double(leftPoint.x), longitude: Double(leftPoint.y)),
                           CLLocationCoordinate2D(latitude: Double(rightPoint.x), longitude: Double(rightPoint.y))]
        
        return MGLPolygon(coordinates: coordinates, count: 3)
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
    
    private func offsetPoint(for type: VisionOffsetType, center: CLLocationCoordinate2D, orientation: Double) -> CGPoint {
        let radiusInMeters = radius.toMeters()
        
        let centerLatRadians = center.latitude.toRadians()
        let centerLonRadians = center.longitude.toRadians()
        
        let pointLatRadians = asin(sin(centerLatRadians) * cos(radiusInMeters) + cos(centerLatRadians)
            * sin(radiusInMeters) * cos(type.offset(viewingAngle: viewingAngle, orientation: orientation)))
        
        let pointLonRadians = centerLonRadians - atan2(sin(type.offset(viewingAngle: viewingAngle, orientation: orientation))
            * sin(radiusInMeters) * cos(centerLatRadians), cos(radiusInMeters) - sin(centerLatRadians) * sin(pointLatRadians))
        
        return CGPoint(x: pointLatRadians.toDegrees(), y: pointLonRadians.toDegrees())
    }
}

//
//  SoundZone.swift
//  Qast
//
//  Created by Austin Welch on 7/6/19.
//  Copyright © 2019 Qast. All rights reserved.
//

import FirebaseFirestore.FIRGeoPoint
import CoreLocation.CLLocation
import Mapbox

/// MapBox is great for rendering, but can't geoquery well. CoreLocation can query, but can't render onto MGLMapView
/// This protocol is to enforce both behaviors on any Zones we use in the future
protocol GeoQueryable {
    var renderableGeofence: MGLPolygonFeature { get }
    var queryableGeofence: CLCircularRegion { get }
}

struct SoundZone: GeoQueryable {
    
    let mapView = MGLMapView()
    
    let name: String
    let id: String
    let center: GeoPoint
    let radius: Double
    let streamId: String
    let tracks: [String]
    let description: String
    let imageURL: String

    var renderableGeofence: MGLPolygonFeature {
        return polygonFeatureCircleForCoordinate(coordinate: self.center.location, withMeterRadius: self.radius)
    }
    
    var queryableGeofence: CLCircularRegion {
        return CLCircularRegion(center: self.center.location, radius: radius, identifier: self.id)
    }
    
    var bufferRadius: Double {
        return radius + 10 //add 10 meters for now.
    }
    
    var data: [String: Any] {
        return ["id": id, "streamId": streamId, "center": center, "radius": radius, "tracks": tracks, "description": description, "imageURL": imageURL, "name": name]
    }
    
    init?(dictionary: [String: Any]) {
        guard
            let id = dictionary["id"] as? String,
            let center = dictionary["center"] as? GeoPoint,
            let radius = dictionary["radius"] as? Double,
            let streamId = dictionary["streamId"] as? String,
            let tracks = dictionary["tracks"] as? [String],
            let description = dictionary["description"] as? String,
            let imageURL = dictionary["imageURL"] as? String,
            let name = dictionary["name"] as? String
            
            else {
                return nil
        }
        self.id = id
        self.center = center
        self.radius = radius
        self.streamId = streamId
        self.tracks = tracks
        self.description = description
        self.imageURL = imageURL
        self.name = name
    }
}

// MARK: Volume Control

extension SoundZone {
    
    /// Returns the correct volume level for distance away from sound zone
    func volume(from location: CLLocation) -> Float {
        let zoneCenter = CLLocation(latitude: center.latitude, longitude: center.longitude)
        
        let distance = zoneCenter.distance(from: location)
        
        //there is probably a better mathematical equation to handle this, but i don't know maths so this works fine for now
        if distance <= radius {
            return 1
        } else if distance > bufferRadius {
            return 0
        } else {
            return Float(1 - ((distance - radius) / (bufferRadius - radius)))
        }
    }
    
    /// Approximate a circle using a 45-sided MGLPolygon
    private func polygonFeatureCircleForCoordinate(coordinate: CLLocationCoordinate2D, withMeterRadius: Double) -> MGLPolygonFeature {
        let SHRINK_OFFSET: Double = 43.5
        let degreesBetweenPoints = 8.0
        //45 sides
        let numberOfPoints = floor(360.0 / degreesBetweenPoints)
        let distRadians: Double = (withMeterRadius - SHRINK_OFFSET) / 6371000.0
        
        // earth radius in meters
        let centerLatRadians: Double = coordinate.latitude * Double.pi / 180
        let centerLonRadians: Double = coordinate.longitude * Double.pi / 180
        var coordinates = [CLLocationCoordinate2D]()
        //array to hold all the points
        for index in 0 ..< Int(numberOfPoints) {
            let degrees: Double = Double(index) * Double(degreesBetweenPoints)
            let degreeRadians: Double = degrees * Double.pi / 180
            let pointLatRadians: Double = asin(sin(centerLatRadians) * cos(distRadians) + cos(centerLatRadians) * sin(distRadians) * cos(degreeRadians))
            let pointLonRadians: Double =
                centerLonRadians + atan2(sin(degreeRadians) * sin(distRadians) * cos(centerLatRadians), cos(distRadians) - sin(centerLatRadians) * sin(pointLatRadians))
            let pointLat: Double = pointLatRadians * 180 / Double.pi
            let pointLon: Double = pointLonRadians * 180 / Double.pi
            let point: CLLocationCoordinate2D = CLLocationCoordinate2DMake(pointLat, pointLon)
            coordinates.append(point)
        }
        let polygon = MGLPolygonFeature(coordinates: &coordinates, count: UInt(coordinates.count))
        polygon.identifier = self.id
        return polygon
    }
}

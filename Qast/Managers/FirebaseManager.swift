//
//  FirebaseManager.swift
//  Qast
//
//  Created by Austin Welch on 7/5/19.
//  Copyright © 2019 Qast. All rights reserved.
//

import FirebaseFirestore
import CoreLocation.CLLocation

struct FirebaseManager: SoundZoneAPI {

    private let datastore = Firestore.firestore()
    
    func soundZones(nearby location: CLLocationCoordinate2D, distance: Double = 30, _ completion: @escaping SoundZoneCompletionBlock) {
        
        let bounds = FirebaseManager.boundingPoints(for: location, distance: distance)
        
        datastore.collection("sound_zones")
            .whereField("center", isGreaterThan: bounds.lesserPoint)
            .whereField("center", isLessThan: bounds.greaterPoint)
            .getDocuments { (snapshot, error) in
                if let error = error {
                    completion([], error)
                } else if let snapshot = snapshot {
                    completion(snapshot.documents.compactMap({ SoundZone(dictionary: $0.data()) }), nil)
                }
        }
    }
}

// MARK: Utility Functions

extension FirebaseManager {

    /// Returns a lower geopoint, and a greater geopoint based on the given distance
    public static func boundingPoints(for location: CLLocationCoordinate2D, distance: Double) -> (lesserPoint: GeoPoint, greaterPoint: GeoPoint) {
        let lat = 0.0144927536231884
        let lon = 0.0181818181818182

        let lowerLat = location.latitude - (lat * distance)
        let lowerLon = location.longitude - (lon * distance)

        let greaterLat = location.latitude + (lat * distance)
        let greaterLon = location.longitude + (lon * distance)

        return (GeoPoint(latitude: lowerLat, longitude: lowerLon), GeoPoint(latitude: greaterLat, longitude: greaterLon))
    }
}

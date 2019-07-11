//
//  FirebaseManager.swift
//  Qast
//
//  Created by Austin Welch on 7/5/19.
//  Copyright © 2019 Qast. All rights reserved.
//

import FirebaseFirestore
import CoreLocation.CLLocation
import GeoFire

struct FirebaseManager: SoundZoneAPI {

    private let datastore = Firestore.firestore()
    
    func soundZones(nearby location: CLLocationCoordinate2D, distance: Double = 30, _ completion: @escaping SoundZoneCompletionBlock) {
        guard let queries = GFGeoHashQuery.queries(forLocation: location, radius: distance) else {
            return completion([], NSError())
        }
        
        for query in queries {
            guard let query = query as? GFGeoHashQuery else {
                continue
            }
            
            convert(query).getDocuments { (snapshot, error) in
                guard let documents = snapshot?.documents, error == nil else {
                    return completion([], error ?? NSError())
                }
                completion(documents.compactMap { SoundZone(dictionary: $0.data()) }, nil)
            }
        }
    }
    
    func create(_ soundZone: SoundZone, completion: @escaping (Error?) -> Void) {
        guard let geohash = GFGeoHash(location: soundZone.center.location).geoHashValue  else {
            return completion(NSError())
        }
        
        let data: [String: Any] = soundZone.data.merging(["l": soundZone.center, "g": geohash]) { $1 } //merging geopoint data into soundZone
        
        datastore.collection("sound_zones").addDocument(data: data) { (error) in
            completion(error)
        }
    }
}

// MARK: Utility Functions

extension FirebaseManager {

    func convert(_ query: GFGeoHashQuery) -> Query {
        return datastore.collection("sound_zones").order(by: "g")
            .whereField("g", isGreaterThan: query.startValue)
            .whereField("g", isLessThan: query.endValue)
            .limit(to: 10)
    }
}

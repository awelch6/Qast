import Foundation
import Firebase
import FirebaseFirestore
import CoreLocation.CLLocation

let DB_BASE = Firestore.firestore()

typealias SoundZoneCompletionBlock = ([SoundZone], Error?) -> Void

class FirebaseManager {
    static let instance = FirebaseManager()
    
    private var _REF_BASE = DB_BASE
    private var _REF_SOUNDZONE = DB_BASE.collection("sound_zones")
    
    var REF_BASE: Firestore {
        return _REF_BASE
    }
    
    var REF_SOUNDZONES: CollectionReference {
        return _REF_SOUNDZONE
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

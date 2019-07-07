import Foundation
import Firebase
import CoreLocation
import CoreLocation.CLLocation

protocol SoundZoneRepository {
    func getSoundZone(id: String, completion: @escaping (Result<SoundZone>) -> Void)
    func createSoundZone(_ soundZone: SoundZone, completion: @escaping (Result<SoundZone>) -> Void)
    func getNearbySoundZones(nearby location: CLLocationCoordinate2D, distance: Double, _ completion: @escaping SoundZoneCompletionBlock) -> Void
}

class FirebaseSoundZoneRepository: SoundZoneRepository {
    let soundZoneRef = FirebaseManager.instance.REF_SOUNDZONES
    
    func getSoundZone(id: String, completion: @escaping (Result<SoundZone>) -> Void) {
        
    }
    
    func getNearbySoundZones(nearby location: CLLocationCoordinate2D, distance: Double = 30, _ completion: @escaping SoundZoneCompletionBlock) {
        
        let bounds = FirebaseManager.boundingPoints(for: location, distance: distance)
        
        soundZoneRef
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
    
    func createSoundZone(_ soundZone: SoundZone, completion: @escaping (Result<SoundZone>) -> Void) {

    }

}

// Injectable mock repo for testing purposes

class MockSoundZoneRepository: SoundZoneRepository {
    func getNearbySoundZones(nearby location: CLLocationCoordinate2D, distance: Double, _ completion: @escaping SoundZoneCompletionBlock) {
        
    }
    
    func getSoundZone(id: String, completion: @escaping (Result<SoundZone>) -> Void) {
        
    }
    
    func createSoundZone(_ soundZone: SoundZone, completion: @escaping (Result<SoundZone>) -> Void) {
        
    }
    
    public func soundZones(nearby location: CLLocationCoordinate2D, distance: Double = 30, _ completion: @escaping SoundZoneCompletionBlock) {
        
    }
    
}

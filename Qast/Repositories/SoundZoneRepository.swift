import Foundation
import Firebase
import CoreLocation

protocol SoundZoneRepository {
    func getSoundZone(id: String, completion: @escaping (Result<SoundZone>) -> Void)
    func createSoundZone(_ soundZone: SoundZone, completion: @escaping (Result<SoundZone>) -> Void)
}

class FirebaseSoundZoneRepository: SoundZoneRepository {
    let soundZoneRef = FirestoreDataService.instance.REF_SOUNDZONES
    
    func getSoundZone(id: String, completion: @escaping (Result<SoundZone>) -> Void) {
        
    }
    
    func createSoundZone(_ soundZone: SoundZone, completion: @escaping (Result<SoundZone>) -> Void) {
        soundZoneRef.addDocument(data: soundZone.documentData) { (error) in
            if let error = error {
                completion(.error(error))
            } else {
                completion(.value(soundZone))
            }
        }
    }

}

class MockSoundZoneRepository: SoundZoneRepository {
    func getSoundZone(id: String, completion: @escaping (Result<SoundZone>) -> Void) {
        
    }
    
    func createSoundZone(_ soundZone: SoundZone, completion: @escaping (Result<SoundZone>) -> Void) {
        
    }
    
}

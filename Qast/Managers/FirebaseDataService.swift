import Foundation
import Firebase
import FirebaseFirestore

let DB_BASE = Firestore.firestore()

class FirestoreDataService {
    static let instance = FirestoreDataService()
    
    private var _REF_BASE = DB_BASE
    private var _REF_SOUNDZONE = DB_BASE.collection("SoundZones")
    
    var REF_BASE: Firestore {
        return _REF_BASE
    }
    
    var REF_SOUNDZONES: CollectionReference {
        return _REF_SOUNDZONE
    }
    
}

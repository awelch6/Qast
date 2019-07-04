import MapKit
import FirebaseFirestore

class SoundZone: CLCircularRegion {
    var soundUrl: String = ""
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(soundUrl: String, center: CLLocationCoordinate2D, radius: CLLocationDistance, identifier: String) {
        self.soundUrl = soundUrl
        super.init(center: center, radius: radius, identifier: identifier)
    }
    
    convenience init(documentId: String, dictionary: [String:Any]) {
        let soundUrl = dictionary["soundUrl"] as? String
        let center = dictionary["center"] as? CLLocationCoordinate2D
        let radius = dictionary["radius"] as? Double
        let identifier = dictionary["identifier"] as? String
        self.init(soundUrl: soundUrl!, center: center!, radius: radius!, identifier: identifier!)
    }
}

extension SoundZone {
    
    convenience init?(document: QueryDocumentSnapshot) {
        self.init(documentId: document.documentID, dictionary: document.data())
    }
    
    convenience init?(document: DocumentSnapshot) {
        guard let data = document.data() else { return nil }
        self.init(documentId: document.documentID, dictionary: data)
    }
    
    var documentData: [String: Any] {
        return [
            "soundUrl": soundUrl,
            "center": GeoPoint(latitude: center.latitude, longitude: center.longitude),
            "radius": radius as? Double,
            "identifier": identifier as? String
        ]
    }
}

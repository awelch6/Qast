import UIKit
import Mapbox
import BoseWearable
import simd

class MapViewController: UIViewController {
    
    let soundZoneRepository = FirebaseSoundZoneRepository()
    
    let mapView = MGLMapView(frame: UIScreen.main.bounds, styleURL: URL(string: "mapbox://styles/mapbox/streets-v11"))
    
    lazy var vision = VisionManager()

    var sensorDispatch = SensorDispatch(queue: .main)
    
    public let session: WearableDeviceSession
    
    init(session: WearableDeviceSession) {
        self.session = session
        super.init(nibName: nil, bundle: nil)
        
        SessionManager.shared.configureSensors([.rotation, .accelerometer, .gyroscope, .magnetometer, .orientation])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()

        sensorDispatch.handler = self
        
        FirebaseManager.shared.soundZones(nearby: CLLocationCoordinate2D(latitude: 42.334811, longitude: -83.052395)) { (soundZones, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print(soundZones)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: UI Setup

extension MapViewController {
    
    private func setupMapView() {
        view.addSubview(mapView)
        mapView.showsUserLocation = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.zoomLevel = 20
        mapView.delegate = self
    }
}

// MARK: MGLMapView Delegate

extension MapViewController: MGLMapViewDelegate {
    
    func mapView(_ mapView: MGLMapView, didUpdate userLocation: MGLUserLocation?) {
        guard let location = userLocation?.location, location.horizontalAccuracy > 0 else {
            return
        }
        
        /// Calculate sound volume here?

        mapView.setCenter(location.coordinate, animated: true)
    }
    
    func visionPolygon(for coordinate: CLLocationCoordinate2D, orientation: Double) {
        self.mapView.annotations?.forEach { mapView.removeAnnotation($0) }
        
        self.mapView.addAnnotation(vision.updateVisionPolygon(center: coordinate, orientation: orientation))
    }
    
    func mapView(_ mapView: MGLMapView, alphaForShapeAnnotation annotation: MGLShape) -> CGFloat {
        return 0.5
    }
    
    func mapView(_ mapView: MGLMapView, lineWidthForPolylineAnnotation annotation: MGLPolyline) -> CGFloat {
        return 5
    }
    
    func mapView(_ mapView: MGLMapView, fillColorForPolygonAnnotation annotation: MGLPolygon) -> UIColor {
        return UIColor.blue
    }
}

extension MapViewController: SensorDispatchHandler {
    
    func receivedRotation(quaternion: Quaternion, accuracy: QuaternionAccuracy, timestamp: SensorTimestamp) {
        let qMap = Quaternion(ix: 1, iy: 0, iz: 0, r: 0)
        let qResult = quaternion * qMap
        let yaw: Double = (-qResult.zRotation).toDegrees()
        
        guard let userLocation = mapView.userLocation?.location, userLocation.horizontalAccuracy > 0 else {
            return
        }
        
        let magneticDegrees: Double = (yaw < 0) ? 360 + yaw : yaw
        
        visionPolygon(for: userLocation.coordinate, orientation: 360 - magneticDegrees)
    }
}

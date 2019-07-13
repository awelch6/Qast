//
//  MapViewController.swift
//  Qast
//
//  Created by Austin Welch on 7/5/19.
//  Copyright © 2019 Qast. All rights reserved.
//

import UIKit
import Mapbox
import BoseWearable
import simd

class MapViewController: UIViewController {

    let mapView = QastMapView()
    
    lazy var vision = VisionManager()

    var sensorDispatch = SensorDispatch(queue: .main)
    
    public let session: WearableDeviceSession
    public let networker: SoundZoneAPI
    
    init(session: WearableDeviceSession, networker: SoundZoneAPI = FirebaseManager()) {
        self.session = session
        self.networker = networker
        super.init(nibName: nil, bundle: nil)
        SessionManager.shared.configureSensors([.rotation, .accelerometer, .gyroscope, .magnetometer, .orientation])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()

        sensorDispatch.handler = self
        
        networker.soundZones(nearby: CLLocationCoordinate2D(latitude: 42.334811, longitude: -83.052395), distance: 10000) { (soundZones, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                self.mapView.addAnnotations(soundZones.map { $0.renderableGeofence })
                self.mapView.addAnnotations(soundZones.map { SoundZoneAnnotation(soundZone: $0) })
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
        mapView.delegate = self
    }
    
}

// MARK: MGLMapView Delegate

extension MapViewController: MGLMapViewDelegate {
    
    func mapView(_ mapView: MGLMapView, didUpdate userLocation: MGLUserLocation?) {
        guard let location = userLocation?.location, location.horizontalAccuracy > 0 else {
            return
        }
        mapView.setCenter(location.coordinate, zoomLevel: 12, animated: true)
    }
    
    func visionPolygon(for coordinate: CLLocationCoordinate2D, orientation: Double) {
//        if let annotation = mapView.annotations?.first(where: { $0 is MGLPolygon }) {
//            mapView.removeAnnotation(annotation)
//        }
//        self.mapView.addAnnotation(vision.updateVisionPolygon(center: coordinate, orientation: orientation))
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
        
        vision.updateVisionPath(center: userLocation.coordinate, orientation: 360 - magneticDegrees)
        visionPolygon(for: userLocation.coordinate, orientation: 360 - magneticDegrees)
        
        guard let annotations = mapView.annotations?.filter({ $0 is SoundZoneAnnotation }) else { return }

        for annotation in annotations {
            if vision.contains(annotation.coordinate) {
                title = "Found Sound Zone!"
            } else {
                 title = "Did not find Sound Zone"
            }
        }
    }
}

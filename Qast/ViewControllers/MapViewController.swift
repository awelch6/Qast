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
import CoreGraphics

class MapViewController: UIViewController {

    let locationManager: LocationManager = LocationManager()
    
    var isInitialLocationUpdate: Bool = true
    
    var nearbySoundZones: [SoundZone]?
    
    var mapView: MGLMapView = QastMapView()
    
    lazy var vision = VisionManager()

    var notificationManager = NotificationManager()
    let streamingManager = StreamManager()
    
    var sensorDispatch = SensorDispatch(queue: .main)
    
//    public let session: WearableDeviceSession
    
//    session: WearableDeviceSession
    init() {
//        self.session = session
        locationManager.getNearbySoundZones()
        super.init(nibName: nil, bundle: nil)
//        SessionManager.shared.configureSensors([.rotation, .accelerometer, .gyroscope, .magnetometer, .orientation])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        setupCenterOnUserButton()
        
        sensorDispatch.handler = self
        
//        let soundZoneDict: [String: Any] = ["id": "andrews_apartment", "center": CLLocationCoordinate2D(latitude: 42.331424, longitude:  -83.041958).geopoint, "radius": 90.0, "streamId": "USCA20100402"]
//
//        networker.create(SoundZone(dictionary: soundZoneDict)!) { (error) in
//            if let error = error {
//                print("SoundZone creation error \(error)")
//            }
//            print("Created SoundZone")
//        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: UI Setup

extension MapViewController {
    
    private func setupMapView() {
        view.addSubview(mapView)
        
        // This sets up the two way street between MapViewController and LocationManager
        mapView.delegate = locationManager
        locationManager.delegate = self
    }
    
    private func setupCenterOnUserButton() {
        let imageView: UIImageView = UIImageView(frame: CGRect(x: 30.0, y: 65.0, width: 50.0, height: 50.0))
        imageView.image = UIImage(named: "centerOnUser")
        imageView.isUserInteractionEnabled = true
        
        view.addSubview(imageView)
        
        let singleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.singleTapping(recognizer:)))
        singleTap.numberOfTapsRequired = 1
        imageView.addGestureRecognizer(singleTap)
    }
    
    @objc func singleTapping(recognizer: UIGestureRecognizer) {
        guard let location = mapView.userLocation else { return }
        mapView.setCenter(location.coordinate, zoomLevel: 15, animated: true)
    }
    
    func handleMapViewTap(_ gesture: UITapGestureRecognizer) {
        let tapSpot = gesture.location(in: mapView)
        print(tapSpot)
        guard let annotations = mapView.annotations else { return }
//
//        for annotation in annotations {
//            if annotation is SoundZonePolygonView {
//                if let soundZonePolygon = annotation as? SoundZonePolygonView {
//                    if locationManager.soundZoneRect(soundZonePolygon: soundZonePolygon).contains(tapSpot) {
//                        guard let correspondingAnnotation = annotations.filter({ $0.title == soundZonePolygon.id }).first else { return }
//                        mapView.selectAnnotation(correspondingAnnotation, animated: true)
//                    }
//                }
//            }
//        }
        
    }
    
}

// MARK: LocationManager Delegate

extension MapViewController: LocationManagerDelegate {
    func qastMap(didUpdate userLocation: CLLocation) {
        // I really want MapViewController to well...control the MapView and nothing else
        // This could be in LocationManager, but feels more semantically at home here
        if isInitialLocationUpdate { mapView.setCenter(userLocation.coordinate, zoomLevel: 15, animated: true) }
        isInitialLocationUpdate = false
    }
    
    func qastMap(didReceive nearbySoundZones: [SoundZone]) {
        self.mapView.addAnnotations(nearbySoundZones.map { $0.renderableGeofence })
        self.mapView.addAnnotations(nearbySoundZones.map { SoundZoneAnnotation(soundZone: $0) })
    }
    
    func qastMap(didUpdate currentSoundZone: SoundZone?) {
        if let currentSoundZone = currentSoundZone {
            self.title = currentSoundZone.id
            notificationManager.displaySoundZoneChangeNotification(currentSoundZone, spoken: true)
            streamingManager.stop()
            streamingManager.enqueue(currentSoundZone.streamId)
        } else {
            self.title = "Not in any SoundZone"
            notificationManager.displaySoundZoneChangeNotification(currentSoundZone, spoken: false)
            streamingManager.stop()
        }
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
        locationManager.visionPolygon(for: userLocation.coordinate, orientation: 360 - magneticDegrees)
        
        guard let annotations = mapView.annotations?.filter({ $0 is SoundZoneAnnotation }) else { return }

        for annotation in annotations {
            if vision.contains(annotation.coordinate) {
//                title = "Found Sound Zone!"
            } else {
//                 title = "Did not find Sound Zone"
            }
        }
    }
}

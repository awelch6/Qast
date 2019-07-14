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

    var currentSoundZone: SoundZone? {
        didSet {
            if let currentSoundZone = currentSoundZone {
                self.title = currentSoundZone.id
                notificationManager.displaySoundZoneChangeNotification(currentSoundZone, spoken: true)
                streamingManager.stop()
                streamingManager.enqueue(currentSoundZone.streamId)
            } else {
                self.title = "Not in any SoundZone"
                notificationManager.displaySoundZoneChangeNotification(currentSoundZone, spoken: true)
                streamingManager.stop()
            }
        }
    }
    
    var isInitialLocationUpdate: Bool = true
    
    var nearbySoundZones: [SoundZone]?
    
    let mapView = QastMapView()
    
    lazy var vision = VisionManager()

    var notificationManager = NotificationManager()
    let streamingManager = StreamManager()
    
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
        setupCenterOnUserButton()
        
        sensorDispatch.handler = self
        
        networker.soundZones(nearby: CLLocationCoordinate2D(latitude: 42.334811, longitude: -83.052395), distance: 10000) { (soundZones, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                self.mapView.addAnnotations(soundZones.map { $0.renderableGeofence })
                self.mapView.addAnnotations(soundZones.map { SoundZoneAnnotation(soundZone: $0) })
                self.nearbySoundZones = soundZones
            }
        }
        
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
        mapView.delegate = self
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
    
}

// MARK: MGLMapView Delegate

extension MapViewController: MGLMapViewDelegate {
    
    func mapView(_ mapView: MGLMapView, didUpdate userLocation: MGLUserLocation?) {
        guard let location = userLocation?.location, location.horizontalAccuracy > 0 else {
            return
        }
        if isInitialLocationUpdate { mapView.setCenter(location.coordinate, zoomLevel: 15, animated: true) }
        isInitialLocationUpdate = false
        
        let soundZoneContainingUser = determineWhichSoundZoneContainsUser(for: location)
        updateCurrentSoundZone(currentSoundZone: self.currentSoundZone, soundZoneContainingUser: soundZoneContainingUser)
    }
    
    func determineWhichSoundZoneContainsUser(for location: CLLocation) -> SoundZone? {
        guard let nearbySoundZones = nearbySoundZones else { return nil }
        
        let cgLocationPoint = mapView.convert(location.coordinate, toPointTo: mapView)
        
        // OPTION 1: CoreGraphics using CGRect.contains. Most accurate, particularly excelled in smaller SoundZones
        return nearbySoundZones.filter({ soundZoneRect(soundZonePolygon: $0.renderableGeofence).contains(cgLocationPoint) }).first
        
//        // OPTION 2: Mapbox using MGLCoordinateInCoordinateBounds. Fairly accurate in open spaces, excelled in Medium SoundZones
//        return nearbySoundZones.filter({ MGLCoordinateInCoordinateBounds(location.coordinate, $0.renderableGeofence.overlayBounds) }).first
//
//        // OPTION 3: CoreLocation using CLCircularRegion.contains. This was least accurate. Only worked in large SoundZones
//        return nearbySoundZones.filter({ $0.queryableGeofence.contains(location.coordinate) }).first
    }
    
    func soundZoneRect(soundZonePolygon: MGLPolygon) -> CGRect {
        return mapView.convert(soundZonePolygon.overlayBounds, toRectTo: nil)
    }
    
    func determineSoundZoneTransitionType(currentSoundZone: SoundZone?, soundZoneContainingUser: SoundZone?) -> SoundZoneTransitionType {
        if currentSoundZone == nil && soundZoneContainingUser == nil { return .NIL_TO_NIL }
        if currentSoundZone == nil && soundZoneContainingUser != nil { return .NIL_TO_SOME }
        if currentSoundZone != nil && soundZoneContainingUser == nil { return .SOME_TO_NIL }
        if currentSoundZone != nil && soundZoneContainingUser != nil { return .SOME_TO_SOME }
        fatalError()
    }
    
    func updateCurrentSoundZone(currentSoundZone: SoundZone?, soundZoneContainingUser: SoundZone?) {
        // logic for updating soundzone
        let transitionType = determineSoundZoneTransitionType(currentSoundZone: currentSoundZone, soundZoneContainingUser: soundZoneContainingUser)
        
        switch transitionType {
        case .NIL_TO_NIL:
            self.title = "Not in any SoundZone"
            return
        case .NIL_TO_SOME:
            self.currentSoundZone = soundZoneContainingUser
        case .SOME_TO_NIL:
            self.currentSoundZone = soundZoneContainingUser
        case .SOME_TO_SOME:
            if currentSoundZone!.id == soundZoneContainingUser!.id {
                return
            } else {
                self.currentSoundZone = soundZoneContainingUser
            }
        }
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
//                title = "Found Sound Zone!"
            } else {
//                 title = "Did not find Sound Zone"
            }
        }
    }
}

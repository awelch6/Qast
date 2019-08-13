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

protocol MapViewControllerDelegate: class {
    func mapViewController(_ mapViewController: MapViewController, shouldStartPlaying soundZone: SoundZone)
    func mapViewController(_ mapViewController: MapViewController, shouldStopPlaying soundZone: SoundZone?)
    func mapViewController(_ mapViewController: MapViewController, receivedGesture gestureType: GestureType)
}

class MapViewController: NiblessViewController {
    
    var isInitialLocationUpdate: Bool = true
    
    var nearbySoundZones: [SoundZone]?
    
    var mapView: MGLMapView = QastMapView()
    
    let soundZonePicker: UIView = UIView()
    
    var sensorDispatch = SensorDispatch(queue: .main)
    
    weak var delegate: MapViewControllerDelegate?
    
    // MARK: Dependencies
    var visionManager: VisionManager
    var notificationManager: NotificationManager
    var locationManager: LocationManager
    var soundZoneDetailViewControllerFactory: (SoundZone) -> SoundZoneDetailViewController
    let networker: SoundZoneAPI
    
    init(
        locationManager: LocationManager,
        soundZoneDetailViewControllerFactory: @escaping (SoundZone) -> SoundZoneDetailViewController,
        networker: SoundZoneAPI,
        notificationManager: NotificationManager,
        visionManager: VisionManager = VisionManager()
        ) {
        self.networker = networker
        self.locationManager = locationManager
        self.visionManager = visionManager
        self.notificationManager = notificationManager
        self.soundZoneDetailViewControllerFactory = soundZoneDetailViewControllerFactory
        super.init()
        
        locationManager.getNearbySoundZones()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        setupSoundZonePicker()
        setupCenterOnUserButton()
        
        sensorDispatch.handler = self
        
//        let soundZoneDict: [String: Any] =
//            ["id": "andrews_apartment_large",
//             "center": CLLocationCoordinate2D(latitude: 42.331424, longitude:  -83.041958).geopoint,
//             "radius": 90.0,
//             "streamId": "USCA20100402",
//             "description": "Short description",
//             "imageURL": "myUrl",
//             "tracks": ["track1", "track2"]]
//
//        networker.create(SoundZone(dictionary: soundZoneDict)!) { (error) in
//            if let error = error {
//                print("SoundZone creation error \(error)")
//            }
//            print("Created SoundZone")
//        }
        
    }
    
}

// MARK: UI Setup

extension MapViewController {
    
    private func setupMapView() {
        view.addSubview(mapView)
        
        mapView.delegate = locationManager
        locationManager.delegate = self
    }
    
    private func setupSoundZonePicker() {
        soundZonePicker.backgroundColor = UIColor.init(hexString: "F96170", alpha: 0.5)
        soundZonePicker.frame = CGRect.zero
        
        view.addSubview(soundZonePicker)
        
        soundZonePicker.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(100)
        }
        
        let michaelJackson = UIImageView(image: UIImage(named: "mihcael_jackson"))
        michaelJackson.frame = CGRect.zero
        michaelJackson.contentMode = .scaleAspectFill
        
        let dianaRoss = UIImageView(image: UIImage(named: "diana_ross"))
        dianaRoss.frame = CGRect.zero
        dianaRoss.contentMode = .scaleAspectFill
        
        let temptations = UIImageView(image: UIImage(named: "temptations"))
        temptations.frame = CGRect.zero
        temptations.contentMode = .scaleAspectFill
        
        soundZonePicker.addSubview(michaelJackson)
        soundZonePicker.addSubview(dianaRoss)
        soundZonePicker.addSubview(temptations)
        
        dianaRoss.snp.makeConstraints { (make) in
            make.height.equalTo(70)
            make.width.equalTo(50)
            make.center.equalToSuperview()
        }
        
        michaelJackson.snp.makeConstraints { (make) in
            make.height.equalTo(70)
            make.width.equalTo(50)
            make.right.equalTo(dianaRoss.snp.left).offset(-70)
            make.centerY.equalToSuperview()
        }
        
        temptations.snp.makeConstraints { (make) in
            make.height.equalTo(70)
            make.width.equalTo(50)
            make.left.equalTo(dianaRoss.snp.right).offset(70)
            make.centerY.equalToSuperview()
        }

    }
    
    @objc func focusSoundZone(recognizer: UITapGestureRecognizer) {
        let tappedImage = recognizer.view as? SoundZonePickerView
        
        guard let annotations = mapView.annotations else { return }
        guard let annotation = annotations.first else { return }
        mapView.selectAnnotation(annotation, animated: true)
        mapView.setCenter(annotation.coordinate, zoomLevel: 15, animated: true)
    }
    
    private func setupCenterOnUserButton() {
        let imageView: UIImageView = UIImageView(frame: CGRect(x: 30.0, y: 65.0, width: 50.0, height: 50.0))
        imageView.image = UIImage(named: "centerOnUser")
        imageView.isUserInteractionEnabled = true
        
        view.addSubview(imageView)
        
        let singleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.centerUser(recognizer:)))
        singleTap.numberOfTapsRequired = 1
        imageView.addGestureRecognizer(singleTap)
    }
    
    @objc func centerUser(recognizer: UIGestureRecognizer) {
        guard let location = mapView.userLocation else { return }
        mapView.setCenter(location.coordinate, zoomLevel: 15, animated: true)
    }
    
}

// MARK: LocationManager Delegate

extension MapViewController: LocationManagerDelegate {
    func qastMap(didTap soundZone: SoundZone) {
        self.present(SoundZoneDetailViewController(soundZone), animated: true, completion: nil)
    }
    
    func qastMap(didUpdate userLocation: CLLocation) {
        // I really want MapViewController to well...control the MapView and nothing else
        // This could be in LocationManager, but feels more semantically at home here
        if isInitialLocationUpdate { mapView.setCenter(userLocation.coordinate, zoomLevel: 15, animated: true) }
        isInitialLocationUpdate = false
    }
    
    func qastMap(didReceive nearbySoundZones: [SoundZone]) {
        self.mapView.addAnnotations(nearbySoundZones.map { $0.renderableGeofence })
        self.mapView.addAnnotations(nearbySoundZones.map { SoundZoneAnnotation(soundZone: $0) })
        self.populateSoundZonePicker(nearbySoundZones)
    }
    
    func populateSoundZonePicker(_ nearbySoundZones: [SoundZone]) {
        for zone in nearbySoundZones {
            let tempt = UIImageView(image: UIImage(named: "temptations_rect_vertical"))
            
            switch zone.name {
            case "The Temptations":
                tempt.frame = CGRect(x: 0, y: 0, width: 50, height: 70)
                tempt.contentMode = .scaleAspectFit
                tempt.isUserInteractionEnabled = true
                
                let singleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(focusSoundZone(recognizer:)))
                singleTap.numberOfTapsRequired = 1
                tempt.addGestureRecognizer(singleTap)
                
                tempt.snp.makeConstraints { (make) in
                    make.left.equalToSuperview().offset(10)
                    make.width.equalTo(80)
                    make.height.equalTo(100)
                    make.bottom.equalToSuperview().offset(20)
                }
            default:
                print("Not temptations")
            }
//            let soundZonePickerView = SoundZonePickerView(zone, tempt)
//            soundZonePicker.addSubview(soundZonePickerView)
        }
        
    }
    
    func qastMap(didUpdate currentSoundZone: SoundZone?) {
        if let currentSoundZone = currentSoundZone {
            self.title = currentSoundZone.id
            notificationManager.displaySoundZoneChangeNotification(currentSoundZone, spoken: true)
            delegate?.mapViewController(self, shouldStartPlaying: currentSoundZone)
        } else {
            self.title = "Not in any SoundZone"
            notificationManager.displaySoundZoneChangeNotification(currentSoundZone, spoken: false)
            delegate?.mapViewController(self, shouldStopPlaying: currentSoundZone)
        }
    }
}

extension MapViewController: SensorDispatchHandler {
    
    func receivedGesture(type: GestureType, timestamp: SensorTimestamp) {
        delegate?.mapViewController(self, receivedGesture: type)
    }
    
    func receivedRotation(quaternion: Quaternion, accuracy: QuaternionAccuracy, timestamp: SensorTimestamp) {
        let qMap = Quaternion(ix: 1, iy: 0, iz: 0, r: 0)
        let qResult = quaternion * qMap
        let yaw: Double = qResult.zRotation.toDegrees()
        
        guard let userLocation = mapView.userLocation?.location, userLocation.horizontalAccuracy > 0 else {
            return
        }
        
        visionManager.updateVisionPath(center: userLocation.coordinate, orientation: yaw)
        
        locationManager.visionPolygon(for: userLocation.coordinate, orientation: yaw)
    }
}

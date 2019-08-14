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
    
    // MARK: Dependencies
    var visionManager: VisionManager
    var notificationManager: NotificationManager
    var locationManager: LocationManager
    var soundZoneDetailViewControllerFactory: (SoundZone) -> SoundZoneDetailViewController
    let networker: SoundZoneAPI
    
    var isInitialLocationUpdate: Bool = true
    
    var nearbySoundZones: [SoundZone]?
    
    var mapView: MGLMapView = QastMapView()
    
    var sensorDispatch = SensorDispatch(queue: .main)
    
    weak var delegate: MapViewControllerDelegate?
    
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
        setupUI()
        
        sensorDispatch.handler = self
        
        var tracks: [String] = [String]()
        tracks.append("track one")
        tracks.append("track two")
        
        let soundZoneDict: [String: Any] =
            ["name": "Diana Rosss",
             "id": "Diana Ross",
             "center": CLLocationCoordinate2D(latitude: 42.331424, longitude:  -83.041958).geopoint,
             "radius": 100.0,
             "streamId": "USCA20100402",
             "tracks": ["track1", "track2"],
             "description": "Short description",
             "imageURL": "myUrl"
        ]

        networker.create(SoundZone(dictionary: soundZoneDict)!) { (error) in
            if let error = error {
                print("SoundZone creation error \(error)")
            }
            print("Created SoundZone")
        }
        
    }
    
}

// MARK: UI Setup

extension MapViewController {
    
    private func setupUI() {
        setupMapView()
        setupSoundZonePicker()
        setupCenterOnUserButton()
    }
    
    private func setupMapView() {
        view.addSubview(mapView)
        
        mapView.delegate = locationManager
        locationManager.delegate = self
    }
    
    private func setupSoundZonePicker() {
        let soundZonePicker: UIView = UIView()
        
        soundZonePicker.backgroundColor = UIColor.init(hexString: "F96170", alpha: 0.5)
        soundZonePicker.frame = CGRect.zero
        
        view.addSubview(soundZonePicker)
        
        soundZonePicker.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(100)
        }
        
        let michaelJackson = UIImageView(image: UIImage(named: "michael_jackson"))
        michaelJackson.frame = CGRect.zero
        michaelJackson.contentMode = .scaleAspectFill
        michaelJackson.isUserInteractionEnabled = true
        
        let dianaRoss = UIImageView(image: UIImage(named: "diana_ross"))
        dianaRoss.frame = CGRect.zero
        dianaRoss.contentMode = .scaleAspectFill
        dianaRoss.isUserInteractionEnabled = true
        
        let temptations = UIImageView(image: UIImage(named: "temptations"))
        temptations.frame = CGRect.zero
        temptations.contentMode = .scaleAspectFill
        temptations.isUserInteractionEnabled = true
        
        soundZonePicker.addSubview(michaelJackson)
        soundZonePicker.addSubview(dianaRoss)
        soundZonePicker.addSubview(temptations)
        
        // DIANA ROSS
        dianaRoss.snp.makeConstraints { (make) in
            make.height.equalTo(70)
            make.width.equalTo(70)
            make.center.equalToSuperview()
        }
        dianaRoss.layoutIfNeeded()
        
        dianaRoss.layer.borderWidth = 1
        dianaRoss.layer.masksToBounds = false
        dianaRoss.layer.borderColor = UIColor.init(hexString: "F96170").cgColor
        dianaRoss.layer.cornerRadius = dianaRoss.frame.width/2
        dianaRoss.clipsToBounds = true
        
        let dianaRossTapped: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(focusSoundZone_dianaRoss(recognizer:)))
        dianaRoss.addGestureRecognizer(dianaRossTapped)
        
        // MICHAEL JACKSON
        michaelJackson.snp.makeConstraints { (make) in
            make.height.equalTo(70)
            make.width.equalTo(70)
            make.right.equalTo(dianaRoss.snp.left).offset(-40)
            make.centerY.equalToSuperview()
        }
        michaelJackson.layoutIfNeeded()
        
        michaelJackson.layer.borderWidth = 1
        michaelJackson.layer.masksToBounds = false
        michaelJackson.layer.borderColor = UIColor.init(hexString: "F96170").cgColor
        michaelJackson.layer.cornerRadius = michaelJackson.frame.width/2
        michaelJackson.clipsToBounds = true
        
        let michaelJacksonTapped: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(focusSoundZone_michaelJackson(recognizer:)))
        michaelJackson.addGestureRecognizer(michaelJacksonTapped)
        
        temptations.snp.makeConstraints { (make) in
            make.height.equalTo(70)
            make.width.equalTo(70)
            make.left.equalTo(dianaRoss.snp.right).offset(40)
            make.centerY.equalToSuperview()
        }
        temptations.layoutIfNeeded()

        temptations.layer.borderWidth = 1
        temptations.layer.masksToBounds = false
        temptations.layer.borderColor = UIColor.init(hexString: "F96170").cgColor
        temptations.layer.cornerRadius = temptations.frame.width/2
        temptations.clipsToBounds = true
        
        let temptationsTapped: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(focusSoundZone_temptations(recognizer:)))
        temptations.addGestureRecognizer(temptationsTapped)
    }
    
    private func setupCenterOnUserButton() {
        let centerOnUserIcon: UIImageView = UIImageView(frame: CGRect(x: 30.0, y: 65.0, width: 50.0, height: 50.0))
        centerOnUserIcon.image = UIImage(named: "centerOnUser")
        centerOnUserIcon.isUserInteractionEnabled = true
        
        view.addSubview(centerOnUserIcon)
        
        let centerOnUserTapped: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.centerMapOnUserLocation(recognizer:)))
        centerOnUserTapped.numberOfTapsRequired = 1
        centerOnUserIcon.addGestureRecognizer(centerOnUserTapped)
    }
    
}

// MARK: Event Handlers
extension MapViewController {
    @objc func focusSoundZone_dianaRoss(recognizer: UITapGestureRecognizer) {
        guard let annotations = mapView.annotations else { return }
        let annotation = annotations.filter({ (annotation) -> Bool in
            return annotation.title == "Diana Ross"
        })
        guard let dianaRossAnnotation = annotation.first else { return }
        mapView.selectAnnotation(dianaRossAnnotation, animated: true)
        mapView.setCenter(dianaRossAnnotation.coordinate, zoomLevel: 15, animated: true)
    }
    
    @objc func focusSoundZone_temptations(recognizer: UITapGestureRecognizer) {
        guard let annotations = mapView.annotations else { return }
        let annotation = annotations.filter({ (annotation) -> Bool in
            return annotation.title == "The Temptations"
        })
        guard let dianaRossAnnotation = annotation.first else { return }
        mapView.selectAnnotation(dianaRossAnnotation, animated: true)
        mapView.setCenter(dianaRossAnnotation.coordinate, zoomLevel: 15, animated: true)
    }
    
    @objc func focusSoundZone_michaelJackson(recognizer: UITapGestureRecognizer) {
        guard let annotations = mapView.annotations else { return }
        let annotation = annotations.filter({ (annotation) -> Bool in
            return annotation.title == "Michael Jackson"
        })
        guard let dianaRossAnnotation = annotation.first else { return }
        mapView.selectAnnotation(dianaRossAnnotation, animated: true)
        mapView.setCenter(dianaRossAnnotation.coordinate, zoomLevel: 15, animated: true)
    }
    
    @objc func centerMapOnUserLocation(recognizer: UIGestureRecognizer) {
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

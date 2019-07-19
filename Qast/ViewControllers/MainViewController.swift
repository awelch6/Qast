//
//  MainViewController.swift
//  Qast
//
//  Created by Austin Welch on 7/19/19.
//  Copyright © 2019 Qast. All rights reserved.
//

import BoseWearable
import CoreLocation.CLLocation
import UIKit

class MainViewController: UIViewController {
    
    public lazy var mapViewController = MapViewController(networker: networker)
    
    public var currentSoundZones: SoundZone? {
        didSet {
            
        }
    }
    
    let session: WearableDeviceSession
    let streamManager: StreamManager
    let networker: SoundZoneAPI
    
    init(session: WearableDeviceSession, streamManager: StreamManager = StreamManager(), networker: SoundZoneAPI = FirebaseManager()) {
        self.session = session
        self.streamManager = streamManager
        self.networker = networker
        super.init(nibName: nil, bundle: nil)

        mapViewController.delegate = self
        
        SessionManager.shared.delegate = self
        SessionManager.shared.configureSensors([.rotation, .accelerometer, .gyroscope, .magnetometer, .orientation])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        add(mapViewController)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        mapViewController.remove()
    }
}

// MARK: MapViewControllerDelegate

extension MainViewController: MapViewControllerDelegate {
    func mapViewController(_ mapViewController: MapViewController, shouldStartPlaying soundZone: SoundZone) {
        streamManager.start(playing: soundZone)
    }
    
    func mapViewController(_ mapViewController: MapViewController, shouldStopPlaying soundZone: SoundZone) {
         streamManager.stop()
    }
}

// MARK: SessionManager Delegate
extension MainViewController: SessionManagerDelegate {
    func session(_ session: WearableDeviceSession, didOpen: Bool) {
        //
    }
    
    func session(_ session: WearableDeviceSession, didClose: Bool) {
        //something happened, show connection screen
    }
}

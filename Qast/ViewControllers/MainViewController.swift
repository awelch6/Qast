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

enum PreviewModeTransitionType {
    case NO_ZONE_TO_NO_ZONE
    case NO_ZONE_TO_PREVIEW_ZONE
    case CURRENT_ZONE_TO_NO_ZONE
    case CURRENT_ZONE_TO_PREVIEW_ZONE
}

class MainViewController: UIViewController {
    
    public var currentSoundZone: SoundZone?
    
    public var isPreviewing: Bool = false
    
    let session: WearableDeviceSession
    
    let streamManager: StreamManager
    let networker: SoundZoneAPI
    public var mapViewController: MapViewController
    
    init(session: WearableDeviceSession, mapViewController: MapViewController, streamManager: StreamManager = StreamManager(), networker: SoundZoneAPI = FirebaseManager()) {
        self.session = session
        self.mapViewController = mapViewController
        self.streamManager = streamManager
        self.networker = networker
        super.init(nibName: nil, bundle: nil)
        
        mapViewController.delegate = self
        
        SessionManager.shared.delegate = self
        SessionManager.shared.configureSensors([.rotation, .accelerometer, .gyroscope, .magnetometer, .orientation])
        SessionManager.shared.configureGestures([.doubleTap])
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
        currentSoundZone = soundZone
        streamManager.start(playing: soundZone)
    }
    
    func mapViewController(_ mapViewController: MapViewController, shouldStopPlaying soundZone: SoundZone?) {
        currentSoundZone = nil
        streamManager.stop()
    }
    
    func determinePreviewModeTransitionType(currentSoundZone: SoundZone?, potentialPreviewSoundZone: SoundZone?) -> PreviewModeTransitionType {
        if currentSoundZone == nil && potentialPreviewSoundZone == nil { return .NO_ZONE_TO_NO_ZONE }
        if currentSoundZone == nil && potentialPreviewSoundZone != nil { return .NO_ZONE_TO_PREVIEW_ZONE }
        if currentSoundZone != nil && potentialPreviewSoundZone == nil { return .CURRENT_ZONE_TO_NO_ZONE }
        if currentSoundZone != nil && potentialPreviewSoundZone != nil { return .CURRENT_ZONE_TO_PREVIEW_ZONE }
        fatalError()
    }
    
    func determineSoundZoneToPreview() -> SoundZone? {
        guard let annotations = mapViewController.mapView.annotations?.filter({ $0 is SoundZoneAnnotation }) as? [SoundZoneAnnotation] else {
            NotificationManager().noPreview()
            return nil
        }
        
        for annotation in annotations {
            if mapViewController.visionManager.intersects(soundZone: annotation.soundZone) && annotation.soundZone.id != currentSoundZone?.id {
                return annotation.soundZone
            }
        }
        
        return nil
    }
    
    func playSoundZonePreview(for soundZone: SoundZone) {
        NotificationManager().preview(soundZone: soundZone)
        streamManager.markCurrentPlaybackTime()
        streamManager.start(playing: soundZone)
    }
    
    func attemptToEnterPreviewMode() {
        let soundZoneToPreview: SoundZone? = determineSoundZoneToPreview()
        let transitionType: PreviewModeTransitionType = determinePreviewModeTransitionType(currentSoundZone: currentSoundZone, potentialPreviewSoundZone: soundZoneToPreview)
        
        switch transitionType {
        
        case .NO_ZONE_TO_NO_ZONE:
            print("NO_ZONE_TO_NO_ZONE")
            NotificationManager().noPreview()
            
        case .CURRENT_ZONE_TO_NO_ZONE:
            print("CURRENT_ZONE_TO_NO_ZONE")
            NotificationManager().noPreview()
            
        case .NO_ZONE_TO_PREVIEW_ZONE:
            print("NO_ZONE_TO_PREVIEW_ZONE")
            
            guard let soundZoneToPreview = soundZoneToPreview else { fatalError("Expected NO_ZONE_TO_PREVIEW_ZONE but determinePreviewModeTransitionType returned nil") }
            
            isPreviewing = true
            playSoundZonePreview(for: soundZoneToPreview)
        case .CURRENT_ZONE_TO_PREVIEW_ZONE:
            print("CURRENT_ZONE_TO_PREVIEW_ZONE")
            
            guard let soundZoneToPreview = soundZoneToPreview else { fatalError("Expected CURRENT_ZONE_TO_PREVIEW_ZONE but determinePreviewModeTransitionType returned nil") }
            
            isPreviewing = true
            playSoundZonePreview(for: soundZoneToPreview)
        }
    }
    
    func exitPreviewMode() {
        isPreviewing = false
        
        guard let currentSoundZone = currentSoundZone else {
            streamManager.stop()
            return
        }
        
        NotificationManager().exitingPreview()
        streamManager.start(playing: currentSoundZone, startingAt: streamManager.currentSoundZonePlaybackTime)
    }
    
    func mapViewController(_ mapViewController: MapViewController, receivedGesture gestureType: GestureType) {
        switch gestureType {
        case .doubleTap:
            print("Received double tap")
            if isPreviewing {
                exitPreviewMode()
            } else {
                attemptToEnterPreviewMode()
            }
        default:
            break
        }
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

//
//  SessionManager.swift
//  Qast
//
//  Created by Austin Welch on 7/5/19.
//  Copyright © 2019 Qast. All rights reserved.
//

import BoseWearable

typealias ConnectManagerCompletion = ((WearableDeviceSession?, Error?) -> Void)

class SessionManager {
    
    static let shared = SessionManager()
    
    private(set) public var session: WearableDeviceSession?
    
    weak var delegate: SessionManagerDelegate?
}

/// MARK: Session Manager

extension SessionManager {
    
    public func startConnection() {
        let gestureIntent = GestureIntent(gestures: [.doubleTap, .headNod])
        
        BoseWearable.shared.startConnection(mode: .alwaysShow, gestureIntent: gestureIntent) { [weak self] result in
            switch result {
            case .success(let session):
                // A device was selected, a session was created and opened. Show
                // a view controller that will become the session delegate.
                self?.session = session
                self?.session?.delegate = self
                self?.delegate?.session(session, didOpen: true)
            case .failure(let error):
                // An error occurred when searching for or connecting to a
                // device. Present an alert showing the error.
                print("Did fail to connect \(error.localizedDescription)")
            case .cancelled:
                print("Connection Cancelled")
                // The user cancelled the search operation.
            }
        }
    }
}

// MARK: Gesture/Sensor Setup
extension SessionManager {
    
    /// Enables all given gestures on the current session. Disables all gestures previous gestures on the current session
    public func configureGestures(_ gestures: [GestureType]) {
        session?.device?.configureGestures({ (config) in
            config.disableAll()
            gestures.forEach { config.set(gesture: $0, enabled: true) }
        })
    }
    
    /// Enables all given sensors on the current session. Disables all sensors previous gestures on the current session
    public func configureSensors(_ sensors: [SensorType]) {
        session?.device?.configureSensors({ (config) in
            config.disableAll()
            sensors.forEach { config.enable(sensor: $0, at: ._320ms) }
        })
    }
}

// MARK: Wearable Device Session Delegate

extension SessionManager: WearableDeviceSessionDelegate {
    // MARK: Do not use this function.
    func sessionDidOpen(_ session: WearableDeviceSession) {
        print("Session started")
    }
    
    func session(_ session: WearableDeviceSession, didFailToOpenWithError error: Error?) {
        // Have to restart connection when this happens
        print("Session fail to open with error \(error?.localizedDescription ?? "Failed to open.")")
    }
    
    func session(_ session: WearableDeviceSession, didCloseWithError error: Error?) {
        // Have to restart connection when this happens
        print("Session did close with error \(error?.localizedDescription ?? "Closed with some error")")
    }
}

//
//  SoundZoneAPI.swift
//  Qast
//
//  Created by Austin Welch on 7/7/19.
//  Copyright © 2019 Qast. All rights reserved.
//

import CoreLocation.CLLocation

typealias SoundZoneCompletionBlock = ([SoundZone], Error?) -> Void

protocol SoundZoneAPI {
    func soundZones(nearby location: CLLocationCoordinate2D, distance: Double, _ completion: @escaping SoundZoneCompletionBlock)
    func create(_ soundZone: SoundZone, completion: @escaping (Error?) -> Void)

    func getSoundZone(id: String, completion: @escaping (Result<SoundZone>) -> Void)
}

extension SoundZoneAPI {
    func getSoundZone(id: String, completion: @escaping (Result<SoundZone>) -> Void) { }
    func create(_ soundZone: SoundZone, completion: @escaping (Error?) -> Void) { }
}

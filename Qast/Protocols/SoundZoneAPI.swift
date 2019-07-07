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
}

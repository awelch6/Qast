//
//  SoundZoneAnnotation.swift
//  Qast
//
//  Created by Austin Welch on 7/6/19.
//  Copyright © 2019 Qast. All rights reserved.
//

import Mapbox

class SoundZoneAnnotation: NSObject, MGLAnnotation {
    var coordinate: CLLocationCoordinate2D
    
    public let soundZone: SoundZone
    
    init(soundZone: SoundZone) {
        self.coordinate = CLLocationCoordinate2D(latitude: soundZone.center.latitude, longitude: soundZone.center.longitude)
        self.soundZone = soundZone
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

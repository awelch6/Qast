//
//  SoundZoneTransitionType.swift
//  Qast
//
//  Created by Andrew O'Brien on 7/13/19.
//  Copyright © 2019 Qast. All rights reserved.
//

import Foundation

enum SoundZoneTransitionType {
    /// User was in dead space; entering dead space
    case NIL_TO_NIL
    
    /// User was in dead space; entering a new SoundZone
    case NIL_TO_SOME
    
    /// User was in SoundZone; entering dead space
    case SOME_TO_NIL
    
    /// User was in SoundZone; entering a new SoundZone
    case SOME_TO_SOME
}

//
//  SessionManagerDelegate.swift
//  Qast
//
//  Created by Austin Welch on 7/5/19.
//  Copyright © 2019 Qast. All rights reserved.
//

import BoseWearable

protocol SessionManagerDelegate: class {
    func session(_ session: WearableDeviceSession, didOpen: Bool)
    func session(_ session: WearableDeviceSession, didClose: Bool)
}

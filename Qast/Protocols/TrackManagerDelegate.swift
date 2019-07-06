//
//  TrackManagerDelegate.swift
//  Qast
//
//  Created by Austin Welch on 7/6/19.
//  Copyright © 2019 Qast. All rights reserved.
//

import AVFoundation

protocol TrackManagerDelegate: class {
    func player(_ player: AVPlayer, didFinishPlaying: Bool)
}

//
//  StreamingManager.swift
//  Qast
//
//  Created by Austin Welch on 7/6/19.
//  Copyright © 2019 Qast. All rights reserved.
//

import AVFoundation

var player: AVQueuePlayer?

class StreamManager {
    
    public func start(playing soundZone: SoundZone) {
        if player == nil {
            player = makePlayer()
        }
        
        var previous: AVPlayerItem?
        
        for track in soundZone.tracks {
            guard let playerItem = playerItem(for: track) else { continue }
            
            player?.insert(playerItem, after: previous)
            
            previous = playerItem
        }
    }
    
    public func stop() {
        player?.pause()
    }
    
    private func makePlayer() -> AVQueuePlayer {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers, .allowAirPlay])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error {
            print(error.localizedDescription)
        }
       return AVQueuePlayer()
    }

    private func playerItem(for isrc: String) -> AVPlayerItem? {
        let urlString = "https://hackathon.umusic.com/prod/v1/isrc/\(isrc)/stream.m3u8"
        
        guard let url = URL(string: urlString) else {
            return nil
        }
        
        let keyHeader = ["x-api-key": "5dsb3jqxzX8D5dIlJzWoTaTM2TzcKufq1geS1SSb"]
        
        let asset = AVURLAsset(url: url, options: ["AVURLAssetHTTPHeaderFieldsKey": keyHeader])
        
        return AVPlayerItem(asset: asset)
    }
}

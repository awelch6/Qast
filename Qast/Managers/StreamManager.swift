//
//  StreamingManager.swift
//  Qast
//
//  Created by Austin Welch on 7/6/19.
//  Copyright © 2019 Qast. All rights reserved.
//

import AVFoundation
import UIKit
import SDWebImage
import Alamofire

var player: AVQueuePlayer?

class StreamManager {
    
    weak var delegate: TrackManagerDelegate?
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    public func stop() {
        player?.removeAllItems()
    }
    
    public func enqueue(_ isrc: String) {
        guard let playerItem = playerItem(for: isrc) else {
            return
        }
        
        guard let p = player else {
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers, .allowAirPlay])
                try AVAudioSession.sharedInstance().setActive(true)
            } catch let error {
                print(error.localizedDescription)
            }
            player = AVQueuePlayer(playerItem: playerItem)
            player?.play()
            return
        }
        
        p.insert(playerItem, after: nil)
        p.play()
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
    
    public func fetchCoverArtUrl(for isrc: String, _ completion: @escaping (Result<URL>) -> Void) {
        let urlString = "https://hackathon.umusic.com/prod/v1/isrc/\(isrc)/cover"
        
        guard let url = URL(string: urlString) else {
            return completion(.error(NSError(domain: "Error", code: 303, userInfo: nil)))
        }
        
        let headers = ["x-api-key": "5dsb3jqxzX8D5dIlJzWoTaTM2TzcKufq1geS1SSb"]
        
        Alamofire.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            if let error = response.error {
                print(error.localizedDescription)
                return completion(.error(error))
            } else if let data = response.data {
                guard let coverArtResponse = try? JSONDecoder().decode(CoverArtResponse.self, from: data) else {
                    return completion(.error(NSError(domain: "Error", code: 303, userInfo: nil)))
                }
                print("Got URL: \(coverArtResponse.coverUrl)")
                
                guard let coverUrl = URL(string: coverArtResponse.coverUrl) else {
                    return completion(.error(NSError(domain: "Error", code: 303, userInfo: nil)))
                }
                
                return completion(.value(coverUrl))
            }
        }
                
        
    }
    
    @objc public func playerDidFinishPlaying() {
        guard let player = player else {
            return
        }

        delegate?.player(player, didFinishPlaying: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

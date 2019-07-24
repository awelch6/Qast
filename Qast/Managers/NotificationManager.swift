//
//  NotificationManager.swift
//  Qast
//
//  Created by Andrew O'Brien on 7/14/19.
//  Copyright © 2019 Qast. All rights reserved.
//

import Foundation
import UserNotifications
import AVFoundation

public enum PreviewType {
    case preview
    case noPreview
}

class NotificationManager {
    
    func preview(soundZone: SoundZone) {
        let title  = "You are now previewing \(soundZone.id)"
        let content = makeNotificationContent(title: title, body: "Enjoy these amazing tracks", sound: .default)
        let utterance = AVSpeechUtterance(string: title)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        AVSpeechSynthesizer().speak(utterance)
        
        let request = UNNotificationRequest(identifier: "preview", content: content, trigger: nil)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func noPreview() {
        let utterance = AVSpeechUtterance(string: "Preview Unavailable")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        AVSpeechSynthesizer().speak(utterance)
    }
    
    func exitingPreview() {
        let utterance = AVSpeechUtterance(string: "You are now exiting preview mode")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        AVSpeechSynthesizer().speak(utterance)
    }
    
    func displaySoundZoneChangeNotification(_ currentSoundZone: SoundZone?, spoken: Bool = false) {
        var notificationTitle = ""
        var notificationBody = ""
        
        if let currentSoundZone = currentSoundZone {
            notificationTitle = "Welcome to \(currentSoundZone.id)"
            notificationBody = "Enjoy these amazing tracks"
        } else {
            notificationTitle = "You have left the SoundZone"
        }
        let content = makeNotificationContent(title: notificationTitle, body: notificationBody, sound: .default)
        
        if spoken == true {
            let utterance = AVSpeechUtterance(string: notificationTitle)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            utterance.rate = AVSpeechUtteranceDefaultSpeechRate
            let synthesizer = AVSpeechSynthesizer()
            synthesizer.speak(utterance)
        }
        
        let request = UNNotificationRequest(identifier: "notification", content: content, trigger: nil)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    
    func makeNotificationContent(title: String, body: String, sound: UNNotificationSound) -> UNNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = sound
        return content
    }
}

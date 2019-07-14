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

class NotificationManager {
    func displaySoundZoneChangeNotification(_ currentSoundZone: SoundZone?, spoken: Bool = false) {
        var notificationTitle = ""
        var notificationBody = ""
        
        if let currentSoundZone = currentSoundZone {
            notificationTitle = "Welcome to \(currentSoundZone.id)"
            notificationBody = "Enjoy these amazing tracks"
        } else {
            notificationTitle = "You have left the SoundZone"
        }
        
        let content = UNMutableNotificationContent()
        content.title = notificationTitle
        content.body = notificationBody
        content.sound = UNNotificationSound.default
        
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
}

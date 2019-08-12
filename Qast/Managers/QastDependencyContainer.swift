//
//  QastDependencyContainer.swift
//  Qast
//
//  Created by Andrew O'Brien on 8/12/19.
//  Copyright © 2019 Qast. All rights reserved.
//

import Foundation
import BoseWearable
import UIKit

class QastDependencyContainer {
    
    let locationManager: LocationManager = LocationManager()
    let networker: SoundZoneAPI = FirebaseManager()
    let notificationManager: NotificationManager = NotificationManager()
    
    func makeMainViewController(session: WearableDeviceSession) -> MainViewController {
        let mapViewController = self.makeMapViewController()
        return MainViewController(session: session, mapViewController: mapViewController)
    }
    
    func makeQastNavigationController(rootViewController: UIViewController) -> QastNavigationViewController {
        return QastNavigationViewController(rootViewController: rootViewController)
    }
    
    func makeConnectionViewController() -> ConnectionViewController {
        
        let mainViewControllerFactory: (WearableDeviceSession) -> MainViewController = { (session) in
            return self.makeMainViewController(session: session)
        }
        
        return ConnectionViewController(mainViewControllerFactory: mainViewControllerFactory)
    }
    
    func makeTutorialCardOne() -> TutorialCardOneViewController {
        return TutorialCardOneViewController()
    }
    
    func makeMapViewController() -> MapViewController {
        let soundZoneDetailViewControllerFactory: (SoundZone) -> SoundZoneDetailViewController = { (soundZone) in
            return self.makeSoundZoneDetailViewController(soundZone: soundZone)
        }
        
        return MapViewController(locationManager: locationManager, soundZoneDetailViewControllerFactory: soundZoneDetailViewControllerFactory, networker: networker, notificationManager: notificationManager)
    }
    
    func makeSoundZoneDetailViewController(soundZone: SoundZone) -> SoundZoneDetailViewController {
        return SoundZoneDetailViewController(soundZone)
    }
    
    func makeTutorialCardTwo() -> TutorialCardTwo {
        return TutorialCardTwo()
    }
    
    func makePopupTutorialPageViewController() -> PopupTutorialPageViewController {
        let viewControllers = [makeTutorialCardOne(), makeTutorialCardTwo(), makeConnectionViewController()]
        return PopupTutorialPageViewController(viewControllerFlow: viewControllers)
    }
}

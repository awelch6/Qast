//
//  CardOneViewController.swift
//  Qast
//
//  Created by Andrew O'Brien on 7/6/19.
//  Copyright © 2019 Qast. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import BoseWearable

class TutorialCardThreeViewController: UIViewController {
    
    private var session: WearableDeviceSession?
    
    let connectButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SessionManager.shared.delegate = self
        setupConnectButton()
        view.backgroundColor = .clear
    }
    
}

// MARK: UI Setup

extension TutorialCardThreeViewController {
    
    private func setupConnectButton() {
        view.addSubview(connectButton)
        connectButton.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(60)
        }
        connectButton.setTitle("Connect", for: .normal)
        connectButton.addTarget(self, action: #selector(connectButtonPressed), for: .touchUpInside)
    }
}

// MARK: Button Actions

extension TutorialCardThreeViewController {
    
    @objc func connectButtonPressed() {
        SessionManager.shared.startConnection()
    }
}

extension TutorialCardThreeViewController: SessionManagerDelegate {
    
    func session(_ session: WearableDeviceSession, didOpen: Bool) {
        navigationController?.pushViewController(MapViewController(session: session), animated: true)
    }
    
    func session(_ session: WearableDeviceSession, didClose: Bool) {
        
    }
}

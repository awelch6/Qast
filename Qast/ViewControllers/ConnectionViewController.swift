//
//  ConnectionViewController.swift
//  Qast
//
//  Created by Austin Welch on 7/5/19.
//  Copyright © 2019 Qast. All rights reserved.
//

import UIKit
import SnapKit
import BoseWearable
import CoreLocation
import FirebaseFirestore

class ConnectionViewController: UIViewController {

    private var session: WearableDeviceSession?
    
    let connectButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SessionManager.shared.delegate = self
        setupConnectButton()
    }
}

// MARK: UI Setup

extension ConnectionViewController {
    
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

extension ConnectionViewController {
    
    @objc func connectButtonPressed() {
        SessionManager.shared.startConnection()
    }
}

extension ConnectionViewController: SessionManagerDelegate {
    
    func session(_ session: WearableDeviceSession, didOpen: Bool) {
        let mainViewController = MainViewController(session: session)
        navigationController?.pushViewController(mainViewController, animated: true)
    }
    
    func session(_ session: WearableDeviceSession, didClose: Bool) {
        
    }
}

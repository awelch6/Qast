//
//  SoundZoneDetailViewController.swift
//  Qast
//
//  Created by Andrew O'Brien on 7/22/19.
//  Copyright © 2019 Qast. All rights reserved.
//

import UIKit

class SoundZoneDetailViewController: UIViewController {

    let soundZone: SoundZone?
    let soundZoneTitle = UILabel()
    let dismissIcon = UIImageView(image: UIImage(named: "x-button"))
    
    init(_ soundZone: SoundZone) {
        self.soundZone = soundZone
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupText()
        setupDismissIcon()
    }

}

// MARK: UI Setup

extension SoundZoneDetailViewController {
    func setupDismissIcon() {
        view.addSubview(dismissIcon)
        dismissIcon.snp.makeConstraints { (make) in
            make.width.equalTo(40)
            make.height.equalTo(40)
            make.left.equalToSuperview().offset(30)
            make.top.equalToSuperview().offset(30)
        }
        let dismissIconTapped = UITapGestureRecognizer(target: self, action: #selector(self.dismiss(_:)))
        dismissIcon.addGestureRecognizer(dismissIconTapped)
        dismissIcon.isUserInteractionEnabled = true
    }
    
    func setupText() {
        view.addSubview(soundZoneTitle)
        soundZoneTitle.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalTo(150)
            make.height.equalTo(60)
        }
        soundZoneTitle.textColor = .black
        soundZoneTitle.text =  soundZone?.id
        soundZoneTitle.textAlignment = .center
    }
}

// MARK: Gesture Recognizer Actions
extension SoundZoneDetailViewController {
    @objc func dismiss(_ sender: UIImageView) {
        self.dismiss(animated: true, completion: nil)
    }
}

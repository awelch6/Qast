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
import Lottie

class TutorialCardOneViewController: UIViewController {
    
    let mainLabel = UILabel()
    let soundZoneTutorialAnimationView = AnimationView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playSoundZoneTutorialAnimation()
        view.backgroundColor = .clear
        navigationController?.navigationBar.isHidden = true
    }
}

// MARK: UI Setup

extension TutorialCardOneViewController {
    func setupText() {
        view.addSubview(mainLabel)
        mainLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalTo(150)
            make.height.equalTo(60)
        }
        mainLabel.text =  "Card One"
        mainLabel.textColor = .white
        mainLabel.textAlignment = .center
    }
    
    func playSoundZoneTutorialAnimation() {
        soundZoneTutorialAnimationView.animation = Animation.named("soundZoneTutorial")
        
        view.addSubview(soundZoneTutorialAnimationView)
        soundZoneTutorialAnimationView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview()
        }
        soundZoneTutorialAnimationView.contentMode = .scaleAspectFit
        soundZoneTutorialAnimationView.play { (finished) in
            if (finished) {
                print("Animation finished!")
            }
        }
    }
}

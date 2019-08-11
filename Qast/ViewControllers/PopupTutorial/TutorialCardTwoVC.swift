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

class TutorialCardTwo: UIViewController {
    
    let mainLabel = UILabel()
    let qastLogo = UIImageView(image: UIImage(named: "qast"))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupText()
        setupQastLogo()
        view.backgroundColor = .clear
        navigationController?.navigationBar.isHidden = true
    }
}

// MARK: UI Setup

extension TutorialCardTwo {
    func setupQastLogo() {
        qastLogo.contentMode = .scaleAspectFit
        qastLogo.layer.cornerRadius = 9
        qastLogo.layer.borderWidth = 1
        qastLogo.layer.borderColor = UIColor.init(hexString: "FFFFFF", alpha: 0.5).cgColor
        qastLogo.backgroundColor = UIColor.init(hexString: "FFFFFF", alpha: 0.25)
        
        view.addSubview(qastLogo)
        qastLogo.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(90)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().inset(20)
        }
    }
    
    func setupText() {
        mainLabel.text =  "Tap SoundZone for Info"
        mainLabel.textColor = .white
        mainLabel.textAlignment = .center
        mainLabel.font = UIFont(name: "AvenirNext-Bold", size: 23.0)!
        
        view.addSubview(mainLabel)
        mainLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalToSuperview().inset(15)
            make.height.equalTo(60)
        }
    }
}

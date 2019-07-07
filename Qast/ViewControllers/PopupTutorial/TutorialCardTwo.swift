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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupText()
        view.backgroundColor = .clear
    }
}

// MARK: UI Setup

extension TutorialCardTwo {
    func setupText() {
        view.addSubview(mainLabel)
        mainLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalTo(150)
            make.height.equalTo(60)
        }
        mainLabel.text =  "Card Two"
        mainLabel.textColor = .white
        mainLabel.textAlignment = .center
    }
}

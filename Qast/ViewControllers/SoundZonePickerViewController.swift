//
//  SoundZonePickerViewController.swift
//  Qast
//
//  Created by Andrew O'Brien on 8/11/19.
//  Copyright © 2019 Qast. All rights reserved.
//

import UIKit
import SnapKit

protocol SoundZonePickerDelegate {
    func didSelect(soundZone: SoundZone) -> Void
}

class SoundZonePickerViewController: UIViewController {

    let mainText: UILabel = UILabel()
    let stackView: UIStackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.init(hexString: "F96170", alpha: 0.5)
        
        self.view.frame = CGRect(x: 0, y: (UIScreen.main.bounds.height - 115), width: UIScreen.main.bounds.width, height: 115)
        
        setupUI()
    }

}

extension SoundZonePickerViewController {
    func setupUI() {
        setupStackView()
    }
    
    func setupStackView() {
        stackView.axis = .horizontal
        stackView.alignment = .fill // .leading .firstBaseline .center .trailing .lastBaseline
        stackView.distribution = .fill // .fillEqually .fillProportionally .equalSpacing .equalCentering
        
        let label = UILabel()
        label.text = "Text"
        stackView.addArrangedSubview(label)
        
        view.addSubview(stackView)
        
        stackView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.right.equalToSuperview()
        }
        
    }
}

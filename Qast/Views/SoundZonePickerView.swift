//
//  SoundZonePickerView.swift
//  Qast
//
//  Created by Andrew O'Brien on 8/11/19.
//  Copyright © 2019 Qast. All rights reserved.
//

import Foundation
import UIKit

class SoundZonePickerView: UIView {
    
    var id: String = "00000"
    var imageName: String = "placeholder"
    var title: String = "titleHere"
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 2000))
        setupUI()
    }
    
    convenience init(_ soundZone: SoundZone) {
        self.init()
        self.id = soundZone.id
        self.title = soundZone.name
        self.imageName = "initializedImageView"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: Setup UI
extension SoundZonePickerView {
    func setupUI() {
        setupImage()
        setupTitle()
    }
    
    func setupImage() {
        
    }
    
    func setupTitle() {
        
    }
}

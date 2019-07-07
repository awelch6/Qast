//
//  UINavigationBarExtension.swift
//  Qast
//
//  Created by Andrew O'Brien on 7/6/19.
//  Copyright © 2019 Qast. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationBar {
    func clear() {
        setBackgroundImage(UIImage(), for: .default)
        shadowImage = UIImage()
        isTranslucent = true
    }
}

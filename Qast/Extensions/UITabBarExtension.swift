//
//  UItabBarExtension.swift
//  Qast
//
//  Created by Andrew O'Brien on 7/6/19.
//  Copyright © 2019 Qast. All rights reserved.
//

import Foundation
import UIKit

extension UITabBar {
    func clear() {
        barTintColor = UIColor.clear
        backgroundImage = UIImage()
        shadowImage = UIImage()
    }
}

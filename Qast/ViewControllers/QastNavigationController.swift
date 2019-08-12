//
//  QastNavigationController.swift
//  Qast
//
//  Created by Andrew O'Brien on 8/12/19.
//  Copyright © 2019 Qast. All rights reserved.
//

import Foundation
import UIKit

class QastNavigationViewController: NiblessNavigationController {
    
    init(rootViewController: UIViewController) {
        super.init()
        setViewControllers([rootViewController], animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.clear()
    }
    
}

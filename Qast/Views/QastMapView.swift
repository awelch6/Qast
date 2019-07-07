//
//  QastMapView.swift
//  Qast
//
//  Created by Austin Welch on 7/6/19.
//  Copyright © 2019 Qast. All rights reserved.
//

import Mapbox

class QastMapView: MGLMapView {
        
    init() {
        super.init(frame: UIScreen.main.bounds, styleURL: URL(string: "mapbox://styles/mapbox/streets-v11"))
        showsUserLocation = true
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        zoomLevel = 20
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

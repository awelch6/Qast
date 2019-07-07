//
//  SoundZoneAnnotationView.swift
//  Qast
//
//  Created by Austin Welch on 7/6/19.
//  Copyright © 2019 Qast. All rights reserved.
//

import Mapbox

class SoundZoneAnnotationView: MGLAnnotationView {
    
    override init(annotation: MGLAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        backgroundColor = .red
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

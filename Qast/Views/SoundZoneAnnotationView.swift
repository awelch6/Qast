//
//  SoundZoneAnnotationView.swift
//  Qast
//
//  Created by Austin Welch on 7/6/19.
//  Copyright © 2019 Qast. All rights reserved.
//

import Mapbox

class SoundZoneAnnotationView: MGLAnnotationView {
    
    var soundZone: SoundZone? {
        guard let soundZoneAnnotation = annotation as? SoundZoneAnnotation else { return nil }
        return soundZoneAnnotation.soundZone
    }
    
    override init(annotation: MGLAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        guard let soundZone = self.soundZone else { return }
        
        // after the non-overridable zoom-scaling effecting MGLAnnotation, this statically defined radius is no longer valid...
        frame = CGRect(x: 0, y: 0, width: soundZone.radius.toPoints(), height: soundZone.radius.toPoints())
        backgroundColor = .red
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.width / 2
    }
}

//
//  MapViewController.swift
//  Qast
//
//  Created by Austin Welch on 7/2/19.
//  Copyright © 2019 Qast. All rights reserved.
//

import UIKit
import Mapbox

class MapViewController: UIViewController {
    
    let mapView = MGLMapView(frame: UIScreen.main.bounds, styleURL: URL(string: "mapbox://styles/mapbox/streets-v11"))
    
    lazy var vision = VisionManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMapView()
    }
}

// MARK: UI Setup

extension MapViewController {
    
    private func setupMapView() {
        view.addSubview(mapView)
        mapView.showsUserLocation = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.zoomLevel = 20
        mapView.delegate = self
    }
}

// MARK: MGLMapView Delegate

extension MapViewController: MGLMapViewDelegate {
    func mapView(_ mapView: MGLMapView, didUpdate userLocation: MGLUserLocation?) {
        guard let location = userLocation else {
            return
        }
        visionPolygon(for: location.coordinate)
        mapView.setCenter(location.coordinate, animated: true)
    }
    
    func visionPolygon(for coordinate: CLLocationCoordinate2D) {
        vision.updateVisionPolygon(center: coordinate, orientation: 200)
        
        self.mapView.addAnnotation(vision.visionPolygon!)
    }
    
    func mapView(_ mapView: MGLMapView, alphaForShapeAnnotation annotation: MGLShape) -> CGFloat {
        // Set the alpha for all shape annotations to 1 (full opacity)
        return 0.5
    }
    
    func mapView(_ mapView: MGLMapView, lineWidthForPolylineAnnotation annotation: MGLPolyline) -> CGFloat {
        // Set the line width for polyline annotations
        return 5
    }
    
    func mapView(_ mapView: MGLMapView, fillColorForPolygonAnnotation annotation: MGLPolygon) -> UIColor {
        return Int.random(in: 0...2) == 1 ? UIColor.red : UIColor.blue
    }
}

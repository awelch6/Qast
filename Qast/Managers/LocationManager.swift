//
//  QastMapViewDelegate.swift
//  Qast
//
//  Created by Andrew O'Brien on 7/18/19.
//  Copyright © 2019 Qast. All rights reserved.
//

import Foundation
import CoreLocation
import Mapbox
import SDWebImage

protocol LocationManagerDelegate: class {
    var mapView: MGLMapView { get }
    
    func qastMap(didReceive nearbySoundZones: [SoundZone])
    func qastMap(didUpdate currentSoundZone: SoundZone?)
    func qastMap(didUpdate userLocation: CLLocation)
}

class LocationManager: NSObject, MGLMapViewDelegate {
    
    weak var delegate: LocationManagerDelegate?
    var networker: SoundZoneAPI = FirebaseManager()
    var streamManager = StreamManager()
    
    var nearbySoundZones: [SoundZone]?
    var currentSoundZone: SoundZone? {
        didSet {
            delegate?.qastMap(didUpdate: currentSoundZone)
        }
    }
    
    func getNearbySoundZones() {
        networker.soundZones(nearby: CLLocationCoordinate2D(latitude: 42.334811, longitude: -83.052395), distance: 10000) { (soundZones, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                self.nearbySoundZones = soundZones
                self.delegate?.qastMap(didReceive: self.nearbySoundZones!)
            }
        }
    }
    
    func mapView(_ mapView: MGLMapView, didUpdate userLocation: MGLUserLocation?) {
        guard let location = userLocation?.location, location.horizontalAccuracy > 0 else {
            return
        }
        let soundZoneContainingUser = determineWhichSoundZoneContainsUser(for: location.coordinate)
        updateCurrentSoundZone(currentSoundZone: self.currentSoundZone, soundZoneContainingUser: soundZoneContainingUser)
        delegate?.qastMap(didUpdate: location)
    }
    
    func determineWhichSoundZoneContainsUser(for coordinate: CLLocationCoordinate2D) -> SoundZone? {
        guard let nearbySoundZones = nearbySoundZones else { return nil }
        
        let cgLocationPoint = delegate?.mapView.convert(coordinate, toPointTo: nil)
        
        // OPTION 1: CoreGraphics using CGRect.contains. Most accurate, particularly excelled in smaller SoundZones
        return nearbySoundZones.filter({ soundZoneRect(soundZonePolygon: $0.renderableGeofence).contains(cgLocationPoint!) }).first
        
        //        // OPTION 2: Mapbox using MGLCoordinateInCoordinateBounds. Fairly accurate in open spaces, excelled in Medium SoundZones
        //        return nearbySoundZones.filter({ MGLCoordinateInCoordinateBounds(coordinate, $0.renderableGeofence.overlayBounds) }).first
        
        //        // OPTION 3: CoreLocation using CLCircularRegion.contains. This was least accurate. Only worked in large SoundZones
        //        return nearbySoundZones.filter({ $0.queryableGeofence.contains(coordinate) }).first
    }
    
    func soundZoneRect(soundZonePolygon: MGLPolygon) -> CGRect {
        return (delegate?.mapView.convert(soundZonePolygon.overlayBounds, toRectTo: nil))!
    }
    
    func determineSoundZoneTransitionType(currentSoundZone: SoundZone?, soundZoneContainingUser: SoundZone?) -> SoundZoneTransitionType {
        if currentSoundZone == nil && soundZoneContainingUser == nil { return .NIL_TO_NIL }
        if currentSoundZone == nil && soundZoneContainingUser != nil { return .NIL_TO_SOME }
        if currentSoundZone != nil && soundZoneContainingUser == nil { return .SOME_TO_NIL }
        if currentSoundZone != nil && soundZoneContainingUser != nil { return .SOME_TO_SOME }
        fatalError()
    }
    
    func updateCurrentSoundZone(currentSoundZone: SoundZone?, soundZoneContainingUser: SoundZone?) {
        let transitionType = determineSoundZoneTransitionType(currentSoundZone: currentSoundZone, soundZoneContainingUser: soundZoneContainingUser)
        
        switch transitionType {
        case .NIL_TO_NIL:
            self.currentSoundZone = soundZoneContainingUser
        case .NIL_TO_SOME:
            self.currentSoundZone = soundZoneContainingUser
        case .SOME_TO_NIL:
            self.currentSoundZone = soundZoneContainingUser
        case .SOME_TO_SOME:
            if currentSoundZone!.id == soundZoneContainingUser!.id {
                return
            } else {
                self.currentSoundZone = soundZoneContainingUser
            }
        }
    }
    
}

// MARK: VisionCone rendering

extension LocationManager {
    func visionPolygon(for coordinate: CLLocationCoordinate2D, orientation: Double) {
        //        if let annotation = mapView.annotations?.first(where: { $0 is MGLPolygon }) {
        //            mapView.removeAnnotation(annotation)
        //        }
        //        self.mapView.addAnnotation(vision.updateVisionPolygon(center: coordinate, orientation: orientation))
    }
}

// MARK: MapView UI Delegate Methods

extension LocationManager {
    func mapView(_ mapView: MGLMapView, alphaForShapeAnnotation annotation: MGLShape) -> CGFloat {
        return 0.5
    }
    
    func mapView(_ mapView: MGLMapView, lineWidthForPolylineAnnotation annotation: MGLPolyline) -> CGFloat {
        return 5
    }
    
    func mapView(_ mapView: MGLMapView, fillColorForPolygonAnnotation annotation: MGLPolygon) -> UIColor {
        return UIColor.blue
    }
    
    // this is NOT called for MGLPolygon annotations
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    func mapView(_ mapView: MGLMapView, rightCalloutAccessoryViewFor annotation: MGLAnnotation) -> UIView? {
        
        let rightCalloutAccessoryView = UIImageView(image: UIImage(named: "cover_art_placeholder"))
        rightCalloutAccessoryView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        
        streamManager.fetchCoverArtUrl(for: "USKRS0326911") { (result) in
            switch result {
            case .value(let coverUrl):
                print(coverUrl)
                rightCalloutAccessoryView.sd_setImage(with: coverUrl, completed: nil)
            case .error(let error):
                print(error)
            }
        }
        
        return rightCalloutAccessoryView
        
    }
    
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        
        if let polygonFeatureAnnotation = annotation as? MGLPolygonFeature {
            guard let polygonFeatureIdentifier = polygonFeatureAnnotation.identifier as? String else { return }
            guard let annotations = mapView.annotations else { return }
            guard let correspondingPointAnnotation = annotations.filter({ ($0 as? SoundZoneAnnotation)?.soundZone.id == polygonFeatureIdentifier }).first else { return }
            
            if correspondingPointAnnotation.title != mapView.selectedAnnotations[0].title {
                mapView.selectAnnotation(correspondingPointAnnotation, animated: true)
            }
            
        } else {
            return
        }
        
    }

}

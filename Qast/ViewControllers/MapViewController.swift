import UIKit
import Mapbox

class MapViewController: UIViewController {
    
    let soundZoneRepository = FirebaseSoundZoneRepository()
    
    let mapView = MGLMapView(frame: UIScreen.main.bounds, styleURL: URL(string: "mapbox://styles/mapbox/streets-v11"))
    
    var circleSource: MGLShapeSource?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMapView()
        
        let newSoundZone = SoundZone(soundUrl: "www.soundUrl.com", center: CLLocationCoordinate2D(latitude: 42.345, longitude: -83.432), radius: 3000, identifier: "identifier")
        
        soundZoneRepository.createSoundZone(newSoundZone) { (result) in
            switch result {
            case .value(let result):
                print(result)
            case .error(let error):
                print(error)
            }
        }
    }

}

// MARK: UI Setup

extension MapViewController {
    
    private func setupMapView() {
        view.addSubview(mapView)
        mapView.showsUserLocation = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.zoomLevel = 18
        mapView.delegate = self
    }
}

// MARK: MGLMapView Delegate

extension MapViewController: MGLMapViewDelegate {
    func mapView(_ mapView: MGLMapView, didUpdate userLocation: MGLUserLocation?) {
        guard let location = userLocation else {
            return
        }
        polygonCircle(for: location.coordinate, withMeterRadius: 10)
        visionPolygon(for: location.coordinate)
        mapView.setCenter(location.coordinate, animated: true)
    }
    
    func polygonCircle(for coordinate: CLLocationCoordinate2D, withMeterRadius: Double) {
        let degreesBetweenPoints = 8.0
        //45 sides
        let numberOfPoints = floor(360.0 / degreesBetweenPoints)
        let distRadians = withMeterRadius / 6371000.0
        
        // earth radius in meters
        let centerLatRadians = coordinate.latitude * Double.pi / 180
        let centerLonRadians = coordinate.longitude * Double.pi / 180
        
        var coordinates = [CLLocationCoordinate2D]()
        
        //array to hold all the points
        for index in 0..<Int(numberOfPoints) {
            let degrees = Double(index) * Double(degreesBetweenPoints)
            let degreeRadians = degrees * Double.pi / 180
            let pointLatRadians = asin(sin(centerLatRadians) * cos(distRadians) + cos(centerLatRadians) * sin(distRadians) * cos(degreeRadians))
            let pointLonRadians = centerLonRadians + atan2(sin(degreeRadians) * sin(distRadians) * cos(centerLatRadians), cos(distRadians) - sin(centerLatRadians) * sin(pointLatRadians))
            let pointLat = pointLatRadians * 180 / Double.pi
            let pointLon = pointLonRadians * 180 / Double.pi
            let point = CLLocationCoordinate2D(latitude: pointLat, longitude: pointLon)
            
            coordinates.append(point)
        }
       
        let polygon = MGLPolygon(coordinates: &coordinates, count: UInt(coordinates.count))
        
        self.mapView.addAnnotation(polygon)
    }
    
    func visionPolygon(for coordinate: CLLocationCoordinate2D) {
        let radius = 10 / 6371000.0
        
        let centerLatRadians = coordinate.latitude * Double.pi / 180
        let centerLonRadians = coordinate.longitude * Double.pi / 180
        
        let theta: Double = 0
        let degToRad: Double
        let viewingAngle: Double = 60
        
        let aTheta = theta - (viewingAngle / 2)
        
        let pointLatRadians = asin(sin(centerLatRadians) * cos(radius) + cos(centerLatRadians) * sin(radius) * cos(radius))
        let pointLonRadians = centerLonRadians + atan2(sin(radius) * sin(radius) * cos(centerLatRadians), cos(radius) - sin(centerLatRadians) * sin(pointLatRadians))
        
        print(aTheta * pointLatRadians)
        
        let pointLat = pointLatRadians * 180 / Double.pi
        let pointLon = pointLonRadians * 180 / Double.pi
        
        let point = CLLocationCoordinate2D(latitude: pointLat, longitude: pointLon)
       
        let line1 = MGLPolyline(coordinates: [coordinate, CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude)], count: 2)
        
        self.mapView.addAnnotation(line1)

//        let radius: CGFloat = 10 / 6371000.0
//        let theta: CGFloat = 45
//
//        let aTheta = theta - (viewingAngle / 2)
//
//        let ax = CGFloat(coordinate.latitude) + cos(aTheta * degToRad) * radius
//        let ay = CGFloat(coordinate.longitude) + sin(aTheta * degToRad) * radius
//
//        let bTheta = theta + (viewingAngle / 2)
//
//        let bx = CGFloat(coordinate.latitude) + cos(bTheta * degToRad) * radius
//        let by = CGFloat(coordinate.longitude) + sin(bTheta * degToRad) * radius
//
//
//        let line2 = MGLPolyline(coordinates: [coordinate, CLLocationCoordinate2D(latitude: CLLocationDegrees(bx), longitude: CLLocationDegrees(by))], count: 2)
    }
    
    func mapView(_ mapView: MGLMapView, alphaForShapeAnnotation annotation: MGLShape) -> CGFloat {
        // Set the alpha for all shape annotations to 1 (full opacity)
        return 0.5
    }
    
    func mapView(_ mapView: MGLMapView, lineWidthForPolylineAnnotation annotation: MGLPolyline) -> CGFloat {
        // Set the line width for polyline annotations
        return 2
    }
    
    func mapView(_ mapView: MGLMapView, fillColorForPolygonAnnotation annotation: MGLPolygon) -> UIColor {
        return Int.random(in: 0...2) == 1 ? UIColor.red : UIColor.blue
    }
}

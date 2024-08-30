//
//  ViewController.swift
//  MapKitRotation
//
//  Created by Frank Guchelaar on 30/08/2024.
//

import MapKit
import UIKit

class CustomAnnotation: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    var title: String?
     
    init(coordinate: CLLocationCoordinate2D, title: String? = nil) {
        self.coordinate = coordinate
        self.title = title
    }
}

class ViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet var mapView: MKMapView!
    var polyline: MKPolyline!
    var carAnnotation: CustomAnnotation!

    override func viewDidLoad() {
        super.viewDidLoad()
        centerOnCoordinate(calculateCenterCoordinate(coordinates: Coordinates.indianapolisSpeedway) ?? Coordinates.indianapolisSpeedway.first!)
        
        polyline = MKPolyline(coordinates: Coordinates.indianapolisSpeedway, count: Coordinates.indianapolisSpeedway.count)
        mapView.addOverlay(polyline)
        
        carAnnotation = CustomAnnotation(coordinate: Coordinates.indianapolisSpeedway.first!, title: "Car")
        mapView.addAnnotation(carAnnotation)
        
        animateCar()
        
        for entry in Coordinates.indianapolisSpeedway.enumerated() {
            if entry.offset.isMultiple(of: 2) {
                let coordinate = entry.element
                print("CLLocationCoordinate2D(latitude: \(coordinate.latitude), longitude: \(coordinate.longitude)),")
            }
        }
    }
    
    func calculateCenterCoordinate(coordinates: [CLLocationCoordinate2D]) -> CLLocationCoordinate2D? {
        guard !coordinates.isEmpty else {
            return nil // Return nil if the array is empty
        }

        var latitudeSum: CLLocationDegrees = 0.0
        var longitudeSum: CLLocationDegrees = 0.0

        for coordinate in coordinates {
            latitudeSum += coordinate.latitude
            longitudeSum += coordinate.longitude
        }

        let centerLatitude = latitudeSum / Double(coordinates.count)
        let centerLongitude = longitudeSum / Double(coordinates.count)

        return CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude)
    }

    
    @IBAction func animateBtnTouched(_ sender: Any) {
        animateCar()
    }
    
    func centerOnCoordinate(_ coordinate: CLLocationCoordinate2D) {
        mapView.setRegion(MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000), animated: true)
    }
    
    func animateCar() {
        let duration: TimeInterval = 10.0 // Total duration of the animation
        let stepDuration = duration / Double(Coordinates.indianapolisSpeedway.count - 1)

        for i in 0 ..< Coordinates.indianapolisSpeedway.count - 1 {
            let startPoint = Coordinates.indianapolisSpeedway[i]
            let endPoint = Coordinates.indianapolisSpeedway[i + 1]

            DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(i)) {
                let startMapPoint = MKMapPoint(startPoint)
                let endMapPoint = MKMapPoint(endPoint)

                let xOffset = endMapPoint.x - startMapPoint.x
                let yOffset = endMapPoint.y - startMapPoint.y

                let angle = atan2(yOffset, xOffset) + (.pi / 2)

                UIView.animate(withDuration: stepDuration, delay: 0, options: .curveLinear, animations: {
                    self.carAnnotation.coordinate = endPoint
                        
                }, completion: nil)
            }
        }
    }
    
    // Delegate functions
    func mapView(_ mapView: MKMapView, rendererFor overlay: any MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .red
            renderer.lineWidth = 5
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("Region changed")
    }
}

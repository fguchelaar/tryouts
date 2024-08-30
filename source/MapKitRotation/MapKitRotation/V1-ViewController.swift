//
//  ViewController.swift
//  MapKitRotation
//
//  Created by Frank Guchelaar on 24/08/2024.
//

import MapKit
import UIKit

class V1ViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet var mapView: MKMapView!
    var polyline: MKPolyline!
    let carImageView = UIImageView(image: UIImage(named: "car"))

    override func viewDidLoad() {
        super.viewDidLoad()
        centerOnCoordinate(Coordinates.indianapolisSpeedway.first!)

        polyline = MKPolyline(coordinates: Coordinates.indianapolisSpeedway, count: Coordinates.indianapolisSpeedway.count)
        mapView.addOverlay(polyline)

        mapView.addSubview(carImageView)

        animateCar()
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
                    self.carImageView.center = self.mapView.convert(endPoint, toPointTo: self.mapView)
                    self.carImageView.transform = CGAffineTransform(rotationAngle: CGFloat(angle))
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

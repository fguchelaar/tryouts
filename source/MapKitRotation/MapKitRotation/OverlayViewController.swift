//
//  ViewController.swift
//  MapKitRotation
//
//  Created by Frank Guchelaar on 30/08/2024.
//

import MapKit
import UIKit

class ImageOverlay: NSObject, MKOverlay {
    dynamic var coordinate: CLLocationCoordinate2D
    var boundingMapRect: MKMapRect

    init(coordinate: CLLocationCoordinate2D, boundingMapRect: MKMapRect) {
        self.coordinate = coordinate
        self.boundingMapRect = boundingMapRect
    }
}

class ImageOverlayRenderer: MKOverlayRenderer {
    var image: UIImage

    init(overlay: MKOverlay, image: UIImage) {
        self.image = image
        super.init(overlay: overlay)
    }

    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
            guard let imageReference = image.cgImage else { return }
            
            // Convert the overlay's bounding map rect to a rect in the view's coordinate system
            var rect = self.rect(for: overlay.boundingMapRect)
            
            // Adjust the size of the rect based on the zoomScale
            let scaleFactor = 1.0 / zoomScale
            rect.size.width *= scaleFactor
            rect.size.height *= scaleFactor
            
            // Center the image
            rect.origin.x -= (rect.size.width - rect.width) / 2
            rect.origin.y -= (rect.size.height - rect.height) / 2
            
            // Draw the image
            context.draw(imageReference, in: rect)
        }
}

class OverlayViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet var mapView: MKMapView!
    var polyline: MKPolyline!
    var carOverlay: ImageOverlay!
    var animationTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        centerOnCoordinate(calculateCenterCoordinate(coordinates: Coordinates.indianapolisSpeedway) ?? Coordinates.indianapolisSpeedway.first!)

        polyline = MKPolyline(coordinates: Coordinates.indianapolisSpeedway, count: Coordinates.indianapolisSpeedway.count)
        mapView.addOverlay(polyline)

        let overlayCoordinate = Coordinates.indianapolisSpeedway.first!
        let overlayRect = MKMapRect(origin: MKMapPoint(overlayCoordinate), size: MKMapSize(width: 2000, height: 1000))
        carOverlay = ImageOverlay(coordinate: overlayCoordinate, boundingMapRect: overlayRect)
        mapView.addOverlay(carOverlay)

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
        startAnimation()
        return;
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
                    self.mapView.removeOverlay(self.carOverlay)
                    self.carOverlay.coordinate = endPoint
                    self.mapView.addOverlay(self.carOverlay)

                }, completion: nil)
            }
        }
    }

    func startAnimation() {
        animationTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateOverlayPosition), userInfo: nil, repeats: true)
    }

    
    
    @objc func updateOverlayPosition() {
        guard let overlay = carOverlay else { return }

        overlay.coordinate = Coordinates.indianapolisSpeedway.randomElement()!

        // Force the map view to redraw the overlay
        mapView.removeOverlay(overlay)
        mapView.addOverlay(overlay)

//        // Stop the timer if we've reached the end of the path
//        if overlay.currentStep >= overlay.path.count {
//            animationTimer?.invalidate()
//            animationTimer = nil
//        }
    }


    // Delegate functions
    func mapView(_ mapView: MKMapView, rendererFor overlay: any MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .red
            renderer.lineWidth = 5
            return renderer
        }
        if let imageOverlay = overlay as? ImageOverlay {
            let image = UIImage(named: "car")! // Load your custom image
            return ImageOverlayRenderer(overlay: imageOverlay, image: image)
        }
        return MKOverlayRenderer(overlay: overlay)
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "CustomAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            annotationView?.image = UIImage(named: "car")
        } else {
            annotationView?.annotation = annotation
        }
        return annotationView
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("Region changed")
    }
}

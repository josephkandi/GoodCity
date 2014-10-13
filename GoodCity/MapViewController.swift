//
//  MapViewController.swift
//  GoodCity
//
//  Created by Nick Aiwazian on 10/5/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

//let kCLLocationAccuracyKilometer = 0.5

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager: CLLocationManager?
    var showUserLocation = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        startStandardUpdates()
        
        // Adding a pin to the map
        let pin = DropoffAnnotation(markerText: "1", title: "Hello", coordinate: CLLocationCoordinate2D(latitude: 37.7730939, longitude: -122.3960759))
        mapView.addAnnotation(pin)
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if (annotation.isKindOfClass(DropoffAnnotation)) {
            let marker = annotation as DropoffAnnotation
            var markerView = mapView.dequeueReusableAnnotationViewWithIdentifier("dropoffAnnotation")
            
            if markerView == nil {
                markerView = marker.annotationView
            }
            else {
                markerView.annotation = annotation
            }
            return markerView
        }
        return nil
    }
    
    // MARK: Location Manager related methods
    func startStandardUpdates() {
        // Create the location manager if this object doesn't already exist
        
        if (locationManager == nil) {
            locationManager = CLLocationManager()
        }
        
        locationManager!.delegate = self
        locationManager!.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager!.distanceFilter = 500 // meters
        
        // Request location permission
        locationManager!.requestWhenInUseAuthorization()
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if (authorizationStatus == CLAuthorizationStatus.Authorized || authorizationStatus == CLAuthorizationStatus.AuthorizedWhenInUse) {
            locationManager!.startUpdatingLocation()
            mapView.showsUserLocation = true
        }
    }
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let location = locations.last as CLLocation
        let eventDate = location.timestamp
        let howRecent = eventDate.timeIntervalSinceNow
        
        if (abs(howRecent) < 15.0) {
            NSLog("latitude \(location.coordinate.latitude), longitude \(location.coordinate.longitude)\n")
        }
        
        if (showUserLocation == false) {
            let center = location.coordinate
            let span = MKCoordinateSpanMake(0.05, 0.05)
            mapView.setRegion(MKCoordinateRegion(center: center, span: span), animated: false)
            showUserLocation = true
        }
        
    }
 
   /* func centerMap() {
        let span = MKCoordinateSpan(latitudeDelta: upper!.latitude-lower!.latitude+0.05, longitudeDelta: upper!.longitude-lower!.longitude+0.05)
        let center = CLLocationCoordinate2D(latitude: (upper!.latitude+lower!.latitude)/2, longitude: (upper!.longitude+lower!.longitude)/2)
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.region = mapView.regionThatFits(region)

    }
*/
    
    @IBAction func onDismiss(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            println("dismissing the mapview")
        })
    }
}

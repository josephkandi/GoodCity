import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager: CLLocationManager?
    var lastUserLocation: CLLocation?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.styleNavBar(navigationBar)
        
        mapView.delegate = self
        startStandardUpdates()
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

        // 15 minutes
        if (abs(howRecent) < 15.0 * 60) {
            self.lastUserLocation = location
            let pfLocation = PFGeoPoint(location: location)
            self.getNearbyDropOffLocationsFromParse(pfLocation)
        }
    }

    func getNearbyDropOffLocationsFromParse(userCurrentLocation: PFGeoPoint, radiusInMiles: Int = 25) {
        var query = DropoffLocation.query()
        query.whereKey("location", nearGeoPoint: userCurrentLocation, withinMiles: Double(radiusInMiles))
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                NSLog("Successfully retrieved \(objects.count) dropoff locations.")
                self.addDropoffLocationsToMap(objects as [DropoffLocation])
            } else {
                NSLog("Error trying to get dropoff locations: %@ %@", error, error.userInfo!)
            }
        }
    }

    func zoomMap() {
        let userAnnotationPoint = MKMapPointForCoordinate(self.lastUserLocation!.coordinate)
        var zoomRect = MKMapRectMake(userAnnotationPoint.x, userAnnotationPoint.y, 0.1, 0.1)

        for annotation in mapView.annotations {
            let annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
            let pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1)
            zoomRect = MKMapRectUnion(zoomRect, pointRect)
        }
        let inset = -zoomRect.size.width * 0.15
        mapView.setVisibleMapRect(MKMapRectInset(zoomRect, inset, inset), animated:true)
    }

    func addDropoffLocationsToMap(locations: [DropoffLocation]) {
        var annotations = [DropoffAnnotation]()
        var index = 0
        for location in locations {
            let coordinate = CLLocationCoordinate2DMake(location.location.latitude, location.location.longitude)
            let dropoffAnnotation = DropoffAnnotation(markerText: String(index), title: location.name, coordinate: coordinate)
            annotations.append(dropoffAnnotation)
            index++
        }
        mapView.addAnnotations(annotations)
        self.zoomMap()
    }

    // Dismiss
    @IBAction func onDismiss(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion:nil)
    }
}

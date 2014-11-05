import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager: CLLocationManager?
    var lastUserLocation: CLLocation?
    var dropoffLocationsHaveBeenRequested = false

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        // NSNotificationCenter.defaultCenter().addObserver(self, selector: "userLocationUpdated:", name: UserLocationDidUpdateNotificiation, object: nil)

        LocationManager.sharedInstance.startStandardUpdates()
        if let loc = LocationManager.sharedInstance.coreLocationManager?.location {
            self.lastUserLocation = loc
            self.getNearbyDropOffLocationsFromParse(PFGeoPoint(location: loc), radiusInMiles: 15)
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.styleNavBar(navigationBar)
    }

    func userLocationUpdated(notification: NSNotification) {
        if let loc = notification.userInfo!["loc"] as? CLLocation {
            let pfLocation = PFGeoPoint(location: loc)
            if !dropoffLocationsHaveBeenRequested {
                println("Sending request to get nearby dropoff locations")

                self.getNearbyDropOffLocationsFromParse(pfLocation)
                dropoffLocationsHaveBeenRequested = true
            }
        }
    }

    override func viewWillDisappear(animated: Bool) {
        LocationManager.sharedInstance.stopStandardUpdates()
        // NSNotificationCenter.defaultCenter().removeObserver(self, name: UserLocationDidUpdateNotificiation, object: nil)
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
    /*
    // MARK: Location Manager related methods
    func startStandardUpdates() {
        // Create the location manager if this object doesn't already exist
        
        if (locationManager == nil) {
            locationManager = CLLocationManager()
        }
        
        locationManager!.delegate = self
        locationManager!.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager!.distanceFilter = 1000 // meters
        
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
    */
    func getNearbyDropOffLocationsFromParse(userCurrentLocation: PFGeoPoint, radiusInMiles: Int = 15) {
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
        var index = 1
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

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
}

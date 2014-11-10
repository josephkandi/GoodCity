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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userLocationUpdated:", name: UserLocationDidUpdateNotificiation, object: nil)

        LocationManager.sharedInstance.startStandardUpdates(accurary: kCLLocationAccuracyHundredMeters)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.styleNavBar(navigationBar)
        if let loc = LocationManager.sharedInstance.coreLocationManager?.location {
            self.lastUserLocation = loc
            dropoffLocationsHaveBeenRequested = true
            self.getNearbyDropOffLocationsFromParse(PFGeoPoint(location: loc), radiusInMiles: 10)
        } else {
            println("Location was not already available when dropoff location viewController started")
        }
    }

    func userLocationUpdated(notification: NSNotification) {
        if let loc = notification.userInfo!["loc"] as? CLLocation {

            let pfLocation = PFGeoPoint(location: loc)
            if !dropoffLocationsHaveBeenRequested {
                self.lastUserLocation = loc
                println("Sending request to get nearby dropoff locations")
                dropoffLocationsHaveBeenRequested = true
                self.getNearbyDropOffLocationsFromParse(pfLocation, radiusInMiles: 10)
            }
        }
    }

    override func viewWillDisappear(animated: Bool) {
        LocationManager.sharedInstance.stopStandardUpdates()
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UserLocationDidUpdateNotificiation, object: nil)
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

    func getNearbyDropOffLocationsFromParse(userCurrentLocation: PFGeoPoint, radiusInMiles: Int) {
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
            let dropoffAnnotation = DropoffAnnotation(
                markerText: String(index),
                title: location.name,
                coordinate: coordinate,
                icon: location.icon
            )
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

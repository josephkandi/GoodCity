import UIKit
import MapKit
import CoreLocation

class UberMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var driverView: UIView!
    
    @IBOutlet weak var timeRemainingLabel: UILabel!
    var lastUserLocation: CLLocation?
    var driverAnnotation: MKAnnotation?

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateMapAnnotation:", name: LocationDidChangeNotification, object: nil)

        self.setupPubnub()

        LocationManager.sharedInstance.startStandardUpdates()
        if let loc = LocationManager.sharedInstance.coreLocationManager?.location {
            self.lastUserLocation = loc
            println("user location is: \(loc)")
        }

        self.timeRemainingLabel.text = "Update pending..."
    }

    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: LocationDidChangeNotification, object: nil)
        LocationManager.sharedInstance.stopStandardUpdates()
    }

    func updateMapAnnotation(notification: NSNotification) {
        println("Received observer event to update map heading: \(notification.userInfo)")
        if let message = notification.userInfo!["message"] as? NSDictionary {
            updateUberAnnotation(message)
        }
    }

    func setupPubnub() {
        PubNubClient.sharedInstance.subscribeToChannel(HEADING_CHANNEL)
    }

    func updateUberAnnotation(dictionary: NSDictionary) {
        var newCoordinate: CLLocationCoordinate2D?
        var newHeading: Double?

        if let loc = dictionary["loc"] as? NSDictionary {
            let lat = loc["lat"] as? Double
            let lng = loc["lng"] as? Double
            if lat != nil && lng != nil {
                // We have a location update
                println("Received a new location broadcast: lat:\(lat), lng:\(lng)")
                newCoordinate = CLLocationCoordinate2DMake(lat!, lng!)
                if self.driverAnnotation == nil {
                    self.addDriverLocationToMap(newCoordinate!)
                }
            }
        }

        if let heading = dictionary["heading"] as? Double {
            // We have a heading
            println("Received a new heading broadcast: \(heading)")
            newHeading = heading
        }

        if let annotationView = mapView.viewForAnnotation(self.driverAnnotation) as? UberAnnotationView {
            UIView.animateWithDuration(1, animations: { () -> Void in
                if newCoordinate != nil {
                    println("Setting new location")
                    self.driverAnnotation!.setCoordinate!(newCoordinate!)
                    // self.getPathEstimatedTime(newCoordinate!, destination: self.lastUserLocation!.coordinate)
                }
                if newHeading != nil {
                    println("Setting new angle")
                    annotationView.rotationAngle = newHeading!
                }
            })
        }
    }

    func getPathEstimatedTime(source: CLLocationCoordinate2D, destination: CLLocationCoordinate2D) {
        let sourcePlacemark = MKPlacemark(coordinate: source, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destination, addressDictionary: nil)
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)

        let request = MKDirectionsRequest()
        request.setSource(sourceMapItem)
        request.setDestination(destinationMapItem)
        request.transportType = MKDirectionsTransportType.Automobile
        request.requestsAlternateRoutes = false

        let directions = MKDirections(request: request)
        if !directions.calculating {
            directions.calculateETAWithCompletionHandler { (response, error) -> Void in
                println("Got directions, expected time in seconds is: \(response.expectedTravelTime)")
                self.timeRemainingLabel.text = "\(response.expectedTravelTime) seconds"
            }
        } else {
            println("Request already in progress for ETA")
        }
    }

    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if annotation.isKindOfClass(MKUserLocation) {
            println("User location annotation")
            return nil;
        } else {
            // TODO: reuse
            var annotationView = UberAnnotationView(annotation: annotation, reuseIdentifier: "MyCustom")
            return annotationView
        }
    }

    func zoomMap() {
        let userAnnotationPoint = MKMapPointForCoordinate(self.lastUserLocation!.coordinate)
        var zoomRect = MKMapRectMake(userAnnotationPoint.x, userAnnotationPoint.y, 0.1, 0.1)

        let annotationPoint = MKMapPointForCoordinate(self.driverAnnotation!.coordinate);
        let pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1)
        zoomRect = MKMapRectUnion(zoomRect, pointRect)

        let inset = -zoomRect.size.width * 0.15
        mapView.setVisibleMapRect(MKMapRectInset(zoomRect, inset, inset), animated:true)
    }

    func addDriverLocationToMap(loc: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.setCoordinate(CLLocationCoordinate2DMake(loc.latitude, loc.longitude))
        self.driverAnnotation = annotation
        mapView.addAnnotation(self.driverAnnotation)
        //self.zoomMap()
    }
}

import UIKit
import MapKit
import CoreLocation

class UberMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var driverView: UIView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var driverNameLabel: UILabel!
    @IBOutlet weak var callImageView: UIImageView!
    @IBOutlet weak var pickupAddressContainer: UIView!
    @IBOutlet weak var pickupAddressLabel: UILabel!
    
    var YAHOO_COORDINATE = CLLocationCoordinate2DMake(37.419029, -122.025733)
    var lastUserLocation: CLLocation?
    var driverAnnotation: MKAnnotation?
    var pickupAnnotation: PickupAnnotation?

    var channelSubscriptionName: String?
    var destinationCoordinate: CLLocationCoordinate2D?
    var destinationAddress: Address?

    var driverUser: GoodCityUser?
    var driverArrivedPromptShown: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.styleNavBar(navigationBar)
    
        mapView.delegate = self

        setupDriverInfo()
        setupPickupAddress()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "driverLocationUpdateHandler:", name: DriverLocationDidChangeNotification, object: nil)
        /*
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userLocationUpdateHandler:", name: UserLocationDidUpdateNotificiation, object: nil)
        */
        self.subscribeForDriverUpdates()

        /*
        LocationManager.sharedInstance.startStandardUpdates()
        if let loc = LocationManager.sharedInstance.coreLocationManager?.location {
            self.lastUserLocation = loc
            self.hasUserLocation = true
            self.zoomMap()
        }
        */

        if let coordinate = self.destinationCoordinate {
            self.zoomMap(20, center: coordinate, animated: false)
            addDropoffLocationsToMap(coordinate)
        }
    }

    func callDriver() {
        println("Calling driver")
        if let phoneNumber = driverUser?.phoneNumber {
            UIApplication.sharedApplication().openURL(NSURL(string: "telprompt://\(phoneNumber)")!)
        }
    }
    func setupDriverInfo() {
        profileImage.layer.cornerRadius = 4
        profileImage.layer.masksToBounds = true
        
        if driverUser != nil {
            profileImage.fadeInImageFromURL(NSURL(string: driverUser!.profilePhotoUrlString)!, border: true)
            driverNameLabel.text = driverUser!.firstName
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: "callDriver")
        callImageView.userInteractionEnabled = true
        callImageView.addGestureRecognizer(tapGesture)
    }
    
    func setupPickupAddress() {
        
        if destinationAddress != nil {
            let line2 = destinationAddress!.line2 == "" ? "" : ", \(destinationAddress!.line2)"
            let city = destinationAddress!.city == "" ? "" : ", \(destinationAddress!.city)"

            pickupAddressLabel.text = destinationAddress!.line1 + line2 + city
        }

        pickupAddressContainer.backgroundColor = UIColor(white: 1, alpha: 0.9)
        pickupAddressContainer.layer.cornerRadius = 4
        pickupAddressContainer.layer.masksToBounds = true
        pickupAddressContainer.layer.borderWidth = 1
        pickupAddressContainer.layer.borderColor = UIColorFromRGB(0xdddddd).CGColor
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: DriverLocationDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UserLocationDidUpdateNotificiation, object: nil)
        LocationManager.sharedInstance.stopStandardUpdates()
    }

    func subscribeForDriverUpdates() {
        if let channelName = self.channelSubscriptionName {
            PubNubClient.sharedInstance.subscribeToChannel(channelName)
        }
    }
    /*
    func userLocationUpdateHandler(notification: NSNotification) {
        // User the first update to zoom map (if it hasn't happened already)
        if !hasUserLocation {
            if let loc = LocationManager.sharedInstance.coreLocationManager?.location {
                self.lastUserLocation = loc
                self.zoomMap()
                self.hasUserLocation = true
            } else {
                println("Error: Could not get user location even after location notification")
            }
            return
        }
    }
    */
    func driverLocationUpdateHandler(notification: NSNotification) {
        if let message = notification.userInfo!["message"] as? NSDictionary {
            updateUberAnnotation(message)
        }
    }

    func updateUberAnnotation(dictionary: NSDictionary) {
        var newCoordinate: CLLocationCoordinate2D?
        var newHeading: Double?

        if let loc = dictionary["loc"] as? NSDictionary {
            let lat = loc["lat"] as? Double
            let lng = loc["lng"] as? Double
            if lat != nil && lng != nil {
                // We have a location update
                newCoordinate = CLLocationCoordinate2DMake(lat!, lng!)
                if self.driverAnnotation == nil {
                    self.addDriverLocationToMap(newCoordinate!)
                    if self.destinationCoordinate != nil && newCoordinate != nil {
                        self.zoomMap(self.destinationCoordinate!, newCoordinate!)
                    }
                }
            }
        }

        if let heading = dictionary["heading"] as? Double {
            // We have a heading
            newHeading = heading
        }
        // We have both user and driver location, so compute ETA
        if (self.driverAnnotation != nil && newCoordinate != nil && self.destinationCoordinate != nil) {
            self.getPathEstimatedTime(newCoordinate!, destination: self.destinationCoordinate!)
        }

        if let annotationView = mapView.viewForAnnotation(self.driverAnnotation) as? UberAnnotationView {
            UIView.animateWithDuration(1, animations: { () -> Void in
                if newCoordinate != nil {
                    self.driverAnnotation!.setCoordinate!(newCoordinate!)
                }
                if newHeading != nil {
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
                let timeRemainingInMinutes = String(format: "%.0f", response.expectedTravelTime / 60)
                self.pickupAnnotation?.markerText = "\(timeRemainingInMinutes)"
                if (response.expectedTravelTime < 60 && !self.driverArrivedPromptShown) {
                    self.promptDriverArrived()
                }
            }
        } else {
            println("Request already in progress for ETA")
        }
    }

    func promptDriverArrived() {
        var title = driverUser != nil ? driverUser!.firstName : "Your volunteer"
        title = title + " is here!"
        
        let alertView = SIAlertView(title: title, andMessage: "Your GoodCity volunteer is here to pick up your items.")
        alertView.titleFont = FONT_MEDIUM_20
        alertView.messageFont = FONT_16
        alertView.buttonFont = FONT_MEDIUM_16
        
        alertView.addButtonWithTitle("OK", type: SIAlertViewButtonType.Default) { (originatingView) -> Void in
            println("ok")
        }
        
        alertView.transitionStyle = SIAlertViewTransitionStyle.DropDown
        alertView.show()
        driverArrivedPromptShown = true
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if annotation.isKindOfClass(MKUserLocation) {
            println("User location annotation")
            return nil;
        }
        else if annotation.isKindOfClass(PickupAnnotation) {
            let dropoffAnnotation = annotation as PickupAnnotation
            return dropoffAnnotation.annotationView
        }
        else {
            // TODO: reuse
            var annotationView = UberAnnotationView(annotation: annotation, reuseIdentifier: "MyCustom")
            return annotationView
        }
    }

    func center(coord1: CLLocationCoordinate2D, _ coord2: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(
            (coord1.latitude + coord2.latitude) / 2,
            (coord1.longitude + coord2.longitude) / 2
        )
    }

    func distanceInMiles(coord1: CLLocationCoordinate2D, _ coord2: CLLocationCoordinate2D) -> Double {
        let loc1 = CLLocation(latitude: coord1.latitude, longitude: coord1.longitude)
        let loc2 = CLLocation(latitude: coord2.latitude, longitude: coord2.longitude)
        let distanceInMeters = loc1.distanceFromLocation(loc2)

        return distanceInMeters * 0.000621371
    }

    func zoomMap(destinationCoordinate: CLLocationCoordinate2D, _ driverCoordinate: CLLocationCoordinate2D) {
        let centerCoordinate = center(destinationCoordinate, driverCoordinate)
        let radiusInMiles = distanceInMiles(destinationCoordinate, driverCoordinate) + 2
        self.zoomMap(radiusInMiles, center: centerCoordinate, animated: true)
    }

    func zoomMap(radiusInMiles: Double, center: CLLocationCoordinate2D, animated: Bool) {
        let scalingFactor = abs(cos(2 * M_PI * center.latitude / 360.0))
        let span = MKCoordinateSpanMake(radiusInMiles / 69.0, radiusInMiles / (scalingFactor * 69.0))
        let region = MKCoordinateRegionMake(center, span)
        mapView.setRegion(region, animated: animated)
    }

    func addDriverLocationToMap(loc: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.setCoordinate(CLLocationCoordinate2DMake(loc.latitude, loc.longitude))
        self.driverAnnotation = annotation
        mapView.addAnnotation(self.driverAnnotation)
    }
    
    func addDropoffLocationsToMap(location: CLLocationCoordinate2D) {
        pickupAnnotation = PickupAnnotation(markerText: "--", title: "Address goes here", coordinate: location)
        mapView.addAnnotation(pickupAnnotation)
    }

    
    @IBAction func onTapDismiss(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion:nil)
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
}

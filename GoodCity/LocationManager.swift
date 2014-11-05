//
//  LocationManager.swift
//  GoodCity
//
//  Created by Nick Aiwazian on 11/2/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import Foundation

let UserLocationDidUpdateNotificiation = "user_location_did_change"

private let sharedLocationManager = LocationManager()

class LocationManager: NSObject, CLLocationManagerDelegate {

    class var sharedInstance : LocationManager {
        struct Static {
            static let instance = LocationManager()
        }
        return Static.instance
    }

    var coreLocationManager: CLLocationManager?
    var lastSentHeading: CLHeading?
    var lastSentLocation: CLLocation?

    func startStandardUpdates() {
        if (coreLocationManager != nil) {
            coreLocationManager!.startUpdatingLocation()
            return
        }
        coreLocationManager = CLLocationManager()

        if CLLocationManager.headingAvailable() {
            println("Heading IS available on this device")
            coreLocationManager?.startUpdatingHeading()
        }

        coreLocationManager!.delegate = self
        coreLocationManager!.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        coreLocationManager!.distanceFilter = 10 // meters

        // Request location permission
        coreLocationManager!.requestWhenInUseAuthorization()
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if (authorizationStatus == CLAuthorizationStatus.Authorized || authorizationStatus == CLAuthorizationStatus.AuthorizedWhenInUse) {
            coreLocationManager!.startUpdatingLocation()
        }
    }

    func stopStandardUpdates() {
        coreLocationManager?.stopUpdatingLocation()
    }

    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let location = locations.last as CLLocation
        let eventDate = location.timestamp
        let howRecent = eventDate.timeIntervalSinceNow
        println("--------------------------Positing notification for user location")
        NSNotificationCenter.defaultCenter().postNotificationName(UserLocationDidUpdateNotificiation, object: nil, userInfo: ["loc": location])

        println("Got a location update...lat: \(location.coordinate.latitude), lng: \(location.coordinate.longitude)")
        if let loc = self.lastSentLocation {
            let locationDistanceInMeters = location.distanceFromLocation(loc)
            if abs(locationDistanceInMeters) > 10 {
                // broadcast location change
                println("Time to broadcast location change")

                PubNubClient.sharedInstance.publishToLocationChannel(location.coordinate.latitude, location.coordinate.longitude)
                self.lastSentLocation = location
            }
        } else {
            // First time
            PubNubClient.sharedInstance.publishToLocationChannel(location.coordinate.latitude, location.coordinate.longitude)
            self.lastSentLocation = location
        }
    }

    func locationManager(manager: CLLocationManager!, didUpdateHeading newHeading: CLHeading!) {
        //        println("Got a heading update \(newHeading.trueHeading)")
        if let heading = self.lastSentHeading {
            let headingDeltaInDegrees = Double.angleDiff(newHeading.trueHeading, heading.trueHeading)
            if abs(headingDeltaInDegrees) > 20 {
                println("Time to broadcast heading change. Old heading: \(heading.trueHeading), New heading: \(newHeading.trueHeading)")
                PubNubClient.sharedInstance.publishToHeadingChannel(newHeading)
                self.lastSentHeading = newHeading
            }
        } else {
            // send first heading
            PubNubClient.sharedInstance.publishToHeadingChannel(newHeading)
            self.lastSentHeading = newHeading
        }
    }
}
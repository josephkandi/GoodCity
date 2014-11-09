//
//  DriverOnTheWay.swift
//  GoodCity
//
//  Created by Nick Aiwazian on 11/9/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import Foundation

class DriverOnTheWay : PFObject, PFSubclassing {
    @NSManaged var drivers: Int

    // Must be called before Parse is initialized
    override class func load() {
        registerSubclass()
    }

    class func parseClassName() -> String! {
        return "DriverOnTheWay"
    }

    func description() -> String {
        return self.drivers
    }

    class func sendOnTheWayPushNotifs() {
        var query = DriverOnTheWay.query()
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error != nil {
                println("Error trying to get driverOnTheWay object: \(error)")
            } else {
                if objects.count > 0 {
                    if let row = objects[0] as? DriverOnTheWay {
                        row.incrementKey("drivers", byAmount: 1)
                        println("Triggering push notifs")
                    }
                }
            }
        }

    }
}
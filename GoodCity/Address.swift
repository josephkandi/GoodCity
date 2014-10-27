//
//  Address.swift
//  GoodCity
//
//  Created by Nick Aiwazian on 10/26/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import Foundation

@objc class Address : PFObject, PFSubclassing {
    @NSManaged var line1: String
    @NSManaged var line2: String
    @NSManaged var city: String
    @NSManaged var state: String
    @NSManaged var zip: String

    // Must be called before Parse is initialized
    override class func load() {
        registerSubclass()
    }

    class func parseClassName() -> String! {
        return "Address"
    }

    func description() -> String {
        return self.line1
    }
    
    /*
    class func getAddressForCurrentUser() {
        var query = GoodCityUser.query()
        //query.includeKey("address")
        //query.whereKey("user", equalTo: GoodCityUser.currentUser)
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            println(objects)
            println(error)
            if objects.count > 0 {
                println("User has address")
            } else {
                println("User DOES NOT HAVE ADDRESS")
            }
        }
    }
    */
}

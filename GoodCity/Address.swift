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
    @NSManaged var user: GoodCityUser
    @NSManaged var coordinate: PFGeoPoint

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

    class func getAddressForCurrentUserWithBlock(completion: (address: Address?, error: NSError?) -> ()) {
        var query = Address.query()
        query.whereKey("user", equalTo: GoodCityUser.currentUser)
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                println("Got addresses back: \(objects)")
                if objects != nil && objects.count == 1 {
                    if let address = objects[0] as? Address {
                        completion(address: address, error: nil)
                        println("Sending completion for address")
                        return
                    }
                }
            }
            println("Sending error for address")
            completion(address: nil, error: error)
        }
    }
}

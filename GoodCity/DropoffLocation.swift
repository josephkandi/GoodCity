//
//  DropoffLocation.swift
//  GoodCity
//
//  Created by Nick Aiwazian on 10/11/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import Foundation

class DropoffLocation : PFObject, PFSubclassing {
    @NSManaged var name: String
    @NSManaged var address: String
    @NSManaged var location: PFGeoPoint
    
    // Must be called before Parse is initialized
    override class func load() {
        registerSubclass()
    }
    
    class func parseClassName() -> String! {
        return "DropoffLocation"
    }
    
    func description() -> String {
        return self.name
    }
}
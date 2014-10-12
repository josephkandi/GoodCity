//
//  PickupScheduleSlot.swift
//  GoodCity
//
//  Created by Nick Aiwazian on 10/11/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import Foundation

class PickupScheduleSlot : PFObject, PFSubclassing {
    @NSManaged var startDateTime: NSDate
    @NSManaged var durationInMinutes: Int
    @NSManaged var taken: Bool
    @NSManaged var takenByUser: GoodCityUser
    @NSManaged var items: [DonationItem]

    // Must be called before Parse is initialized
    override class func load() {
        registerSubclass()
    }

    class func parseClassName() -> String! {
        return "PickupScheduleSlot"
    }

    func description() -> String {
        return self.startDateTime.description
    }

    func grabTimeSlot(user: GoodCityUser, items: [DonationItem]) -> Bool {
        if self.taken {
            println("Trying to schedule a slot that is already taken")
            return false
        }
        self.taken = true
        self.takenByUser = user
        self.items = items
        self.save()
        return true
    }
}
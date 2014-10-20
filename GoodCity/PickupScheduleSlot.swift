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
    @NSManaged var claimedCount: Int
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

    func grabSlot(items: [DonationItem]? = nil) {
        PFCloud.callFunctionInBackground("grabPickupScheduleSlot", withParameters: ["objectId": self.objectId]) {
            (result, error) -> Void in
            if error == nil {
                println("Result from Parse Cloud Code: \(result)")
            } else {
                println("Error from Parse Cloud Code: \(error)")
            }
        }
    }

    class func getAllAvailableSlots(completion: ParseResponse) {
        var query = PickupScheduleSlot.query()
        query.whereKey("claimedCount", lessThan: 1)
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            completion(objects: objects, error: error)
        }
    }

    // Return sorted list of available days given list of pickup schedule slots
    class func getDaysWithAtLeastOneAvailableSlot(slots: [PickupScheduleSlot]) -> [NSDate] {
        // Build set of available days
        let days = NSSet(array: slots.map { $0.startDateTime.dateWithTimeTruncated() })
        let daysList = days.allObjects as [NSDate]
        return sorted(daysList, { $0.compare($1) == NSComparisonResult.OrderedAscending })
    }

    // Return sorted available slots for a particular date
    class func getAvailableSlotsForDay(day: NSDate, slots: [PickupScheduleSlot]) -> [Int] {
        let desiredDate = day.dateWithTimeTruncated()
        let resultSlots = slots.filter { $0.startDateTime.dateWithTimeTruncated() == desiredDate }
        var result = resultSlots.map({ $0.startDateTime.hour() })
        result.sort { $0 < $1 }

        return result
    }
}
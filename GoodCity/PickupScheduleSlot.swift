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

    func grabSlot(items: [DonationItem]) {
        PFCloud.callFunctionInBackground("grabPickupScheduleSlot",
            withParameters: ["objectId": self.objectId,
                "donationItemIds": items.map { $0.objectId }]) {
            (result, error) -> Void in
            if error == nil {
                println("Result from Parse Cloud Code: \(result)")
                let countOfItems = result["countOfItems"] as Int
                self.persistSlotToUserDefaults(countOfItems, dateTime: self.startDateTime)
            } else {
                println("Error from Parse Cloud Code: \(error)")
            }
        }
    }

    func persistSlotToUserDefaults(count: Int, dateTime: NSDate) {
        println("Persisting next schedule slot to user defaults...")
        if let userDefaults = NSUserDefaults(suiteName: "group.com.codepath.goodcity") {

            println("Setting next pickup count to: \(count)")
            userDefaults.setInteger(count, forKey: NUMBER_ITEMS_NEXT_PICKUP_KEY)

            let dateString = getFriendlyDateFormatterWithTime().stringFromDate(dateTime)
            userDefaults.setObject(dateString, forKey: NEXT_SCHEDULE_PICKUP_KEY)
            println("Setting next pickup slot to: \(dateString)")

            userDefaults.synchronize()
        } else {
            println("Error retrieving user defaults")
        }
    }

    class func getAllAvailableSlots(completion: ParseResponse, minDelayFromNowInHours: Int = 1) {
        let secondsFromNow = NSTimeInterval(minDelayFromNowInHours * 3600)
        var startDate = NSDate(timeIntervalSinceNow: secondsFromNow)
        var query = PickupScheduleSlot.query()
        query.whereKey("claimedCount", lessThan: 1)
        query.whereKey("startDateTime", greaterThan: startDate)
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            completion(objects: objects, error: error)
        }
    }

    class func getDaysWithAtLeastOneAvailableSlot(slots: [PickupScheduleSlot]) -> NSSet {
        // Build set of available days
        return NSSet(array: slots.map { $0.startDateTime.dateWithTimeTruncated() })
    }

    // Return sorted available slots for a particular date
    class func getAvailableSlotsForDay(day: NSDate, slots: [PickupScheduleSlot]) -> [Int: PickupScheduleSlot] {
        let desiredDate = day.dateWithTimeTruncated()
        let resultSlots = slots.filter { $0.startDateTime.dateWithTimeTruncated() == desiredDate }
        var result = [Int: PickupScheduleSlot]()
        for slot in resultSlots {
            result[slot.startDateTime.hour()] = slot
        }
        return result
    }
}
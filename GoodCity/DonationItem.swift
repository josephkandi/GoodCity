//
//  DonationItem.swift
//  GoodCity
//
//  Created by Nick Aiwazian on 10/11/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import Foundation

@objc class DonationItem : PFObject, PFSubclassing {
    // TODO: See if there is a way to use an enum with NSManaged since its not visible
    // to Objective C
    @NSManaged var user: GoodCityUser
    @NSManaged var state: String
    @NSManaged var condition: String
    @NSManaged var itemDescription: String
    @NSManaged var photo: PFFile
    @NSManaged var reviewedBy: GoodCityUser
    @NSManaged var pickedUpBy: GoodCityUser

    // Must be called before Parse is initialized
    override class func load() {
        registerSubclass()
    }

    class func parseClassName() -> String! {
        return "DonationItem"
    }

    func description() -> String {
        return itemDescription
    }

    class func newItem(description: NSString, photo: UIImage, condition: NSString) -> DonationItem {
        var donationItem = DonationItem.object()
        donationItem.state = ItemState.Pending.toRaw()
        donationItem.condition = condition
        donationItem.itemDescription = description
        donationItem.user = GoodCityUser.currentUser()

        let data = UIImageJPEGRepresentation(photo, CGFloat(0.05));
        let imageFile = PFFile(data: data)
        donationItem.photo = imageFile

        return donationItem
    }

    func submitToParse() {
        self.saveInBackgroundWithBlock { (Bool succeeded, error: NSError!) -> Void in
            if succeeded {
                NSLog("Successfully saved a new donation item to Parse")
            } else {
                NSLog("Failed trying to save a new donation item to Parse: ")
                NSLog(error.description)
            }
        }
    }

    func updateState(newState: ItemState) {
        self.state = newState.toRaw()
        // Might want to add a completion handler here
        self.saveInBackground()
    }

    // Deletion can happen with deleteInBackground()

    // States is optional
    class func getAllItemsWithStates(completion: ParseResponse, states: [ItemState]? = nil) {
        var query = DonationItem.query()

        if states != nil {
            let stateStrings = states?.map { $0.toRaw() }
            println("stateStrings: \(stateStrings)")
            query.whereKey("state", containedIn: stateStrings)
        }
        query.whereKey("user", equalTo: GoodCityUser.currentUser)
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            completion(objects: objects, error: error)
        }
    }
}
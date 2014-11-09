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
    @NSManaged var pickupScheduledAt: NSDate
    
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
        var donationItem = DonationItem()
        donationItem.state = ItemState.Draft.rawValue
        donationItem.condition = condition
        donationItem.itemDescription = description
        donationItem.user = GoodCityUser.currentUser()

        let w = CGFloat(320)
        let h = CGFloat(480)

        UIGraphicsBeginImageContext(CGSizeMake(w, h));
        photo.drawInRect(CGRectMake(0, 0, w, h))
        let smallImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        let data = UIImageJPEGRepresentation(smallImage, CGFloat(0.05));

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

    // States is optional
    class func getAllItemsWithStates(completion: ParseResponse, states: [ItemState]? = nil, user: GoodCityUser? = GoodCityUser.currentUser()) {
        var query = DonationItem.query()

        if states != nil {
            let stateStrings = states?.map { $0.rawValue }
            query.whereKey("state", containedIn: stateStrings)
        }
        if user != nil {
            query.whereKey("user", equalTo: user)
        }
        query.includeKey("user")
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            completion(objects: objects, error: error)
        }
    }
}
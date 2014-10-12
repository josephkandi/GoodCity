//
//  DonationItem.swift
//  GoodCity
//
//  Created by Nick Aiwazian on 10/11/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import Foundation

class DonationItem : PFObject, PFSubclassing {
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
        return ""
    }

    class func createItem(state: ItemState, condition: ItemCondition, itemDescription: String, user: GoodCityUser = GoodCityUser.currentUser!) {
        var donationItem = DonationItem.object()
        donationItem.state = state.toRaw()
        donationItem.condition = condition.toRaw()
        donationItem.itemDescription = itemDescription
        donationItem.user = user
        donationItem.save()
    }

    class func submitItems(items: [DonationItem]) {

    }
}
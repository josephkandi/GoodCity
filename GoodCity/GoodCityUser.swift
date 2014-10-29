//
//  User.swift
//  GoodCity
//
//  Created by Nick Aiwazian on 10/11/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import Foundation

var _currentUser: GoodCityUser?
let userDidLogoutNotification = "userDidLogoutNotification"

class GoodCityUser: PFUser, PFSubclassing {
    @NSManaged var firstName: String
    @NSManaged var lastName: String
    @NSManaged var facebookId: String
    @NSManaged var isVolunteer: Bool
    @NSManaged var phoneNumber: String
    @NSManaged var address: Address
    @NSManaged var coverPhotoUrl: String

    var profilePhotoUrlString: String {
        get {
            return "https://graph.facebook.com/\(self.facebookId)/picture?type=large&return_ssl_resources=1"
        }
    }

    // Must be called before Parse is initialized
    override class func load() {
        registerSubclass()
    }
    
    class var currentUser: GoodCityUser? {
        get {
        if _currentUser == nil {
            // Is user cached and linked to Facebook
            if PFUser.currentUser() != nil && PFFacebookUtils.isLinkedWithUser(PFUser.currentUser()) {
                _currentUser = PFUser.currentUser() as? GoodCityUser
            }
        }
        return _currentUser
        }
    }

    func promoteToVolunteer() {
        self.isVolunteer = true
        self.save()
    }

    func updatePhoneNumber(phoneNumber: String) {
        self.phoneNumber = phoneNumber
        self.save()
    }

    func updateFacebookInfo(dictionary: NSDictionary) {
        self.firstName = dictionary["first_name"] as String
        self.lastName = dictionary["last_name"] as String
        //self.email = dictionary["email"] as String
        self.facebookId = dictionary["id"] as String

        if let coverDictionary = dictionary["cover"] as? NSDictionary {
            if let url = coverDictionary["source"] as? NSString {
                self.coverPhotoUrl = url
            }
        }
        self.saveInBackgroundWithTarget(nil, selector: nil)
    }
    /*
    func updateAddress(line1: String, line2: String, city: String, zip: String, state: String = "CA") {
        let newAddress = Address()
        newAddress.line1 = line1
        newAddress.line2 = line2
        newAddress.city = city
        newAddress.zip = zip
        newAddress.state = state
        newAddress.saveEventually()
        self.address = newAddress
        self.saveEventually()
    }
    */
    /*
    func updateAddress(newAddress: Address) {
        newAddress.saveEventually()
    }
    */
    func logout() {
        PFUser.logOut()
        _currentUser = nil
        NSNotificationCenter.defaultCenter().postNotificationName(userDidLogoutNotification, object: nil)
    }

    func clearUser() {
        PFFacebookUtils.unlinkUser(GoodCityUser.currentUser)
        self.logout()
    }
}
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
    
    func updateUserFacebookInfo(dictionary: NSDictionary) {
        self.firstName = dictionary["first_name"] as String
        self.lastName = dictionary["last_name"] as String
        self.email = dictionary["email"] as String
        self.facebookId = dictionary["id"] as String
        self.save()
    }
    
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
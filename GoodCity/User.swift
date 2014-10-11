//
//  User.swift
//  GoodCity
//
//  Created by Nick Aiwazian on 10/11/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import Foundation

var _currentUser: User?
let currentUserKey = "kCurrentUserKey"
let userDidLoginNotification = "userDidLoginNotification"
let userDidLogoutNotification = "userDidLogoutNotification"

class User: NSObject {
    var email: String
    var firstName: String
    var lastName: String
    var facebookId: String
    var pictureUrl: String
    
    init(dictionary: NSDictionary) {
        self.email = dictionary["email"] as String
        self.firstName = dictionary["first_name"] as String
        self.lastName = dictionary["last_name"] as String
        self.facebookId = dictionary["id"] as String
        self.pictureUrl = "https://graph.facebook.com/\(self.facebookId)/picture?type=large&return_ssl_resources=1"
    }
    
    class func refreshUserData() {
        let facebookRequest = FBRequest.requestForMe()
        facebookRequest.startWithCompletionHandler { (connection, result, error) -> Void in
            if error == nil {
                let userData = result as NSDictionary
                let currentUser = User(dictionary: userData)
                println(userData)
            } else {
                println(error)
            }
        }
    }
    
    func logout() {
        //      User.currentUser = nil
        //TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
        PFUser.logOut()
        NSNotificationCenter.defaultCenter().postNotificationName(userDidLogoutNotification, object: nil)
    }
}
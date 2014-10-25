//
//  ParseClient.swift
//  GoodCity
//
//  Created by Nick Aiwazian on 10/5/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import Foundation

let PARSE_APPLICATION_ID = "I3aRv2pcl7byfah51bfTSupsZtjQ81F8Jp2jmEyE"
let PARSE_CLIENT_KEY = "mza3JWqSDyWpDZyNeTdGzEYw0A0W8jlZMuvvTM2w"

let TOTAL_DONATION_VALUE_KEY = "total_donation_value"
let TOTAL_DONATION_COUNT_KEY = "total_donation_count"
let MEMBER_SINCE_KEY = "member_since"

private let parseClientSharedInstance = ParseClient()

typealias ParseResponse = (objects: [AnyObject], error: NSError?) -> ()

class ParseClient: NSObject {
    typealias loginResponse = ((user: GoodCityUser?, error: NSError?) -> ())

    // Shared Parse Client instance
    class var sharedInstance : ParseClient {
    struct Static {
        static let instance = ParseClient()
        }
        return Static.instance
    }
    
    func loginOrSignupWithCompletion(completion: loginResponse) {
        let permissionsArray = [] // Can request "user_location"

        PFFacebookUtils.logInWithPermissions(permissionsArray, block:
            { (user, error) -> Void in
                // TODO: activityIndicator.stopAnimating() - Hide loading indicator
                if user == nil { // No user returned
                    var errorMessage = ""
                    if error == nil {
                        println("User cancelled FB login")
                        errorMessage = "Facebook login canceled"
                    } else {
                        // Handle invalidated session
                        //error.userInfo.objectForKey("error").objectForKey("type").isEqualToString("OAuthException") {

                        println("FB login error: \(error)")
                        errorMessage = "An error occurred: \(error.localizedDescription)"
                    }
                    let alertView = UIAlertView(title: "Log in error", message: errorMessage, delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "Dismiss")
                    alertView.show()
                    completion(user: nil, error: error)
                } else {
                    println("Parse response successful...calling completion handler")
                    completion(user: user as? GoodCityUser, error: error)
                }
        })
    }
    
    func refreshUserInfoFromFacebookWithCompletion(completion: (dictionary:NSDictionary?, error: NSError?) -> ()) {

        let facebookRequest = FBRequest.requestForMe()
        facebookRequest.graphPath = "me?fields=email,cover,first_name,last_name"
        facebookRequest.startWithCompletionHandler { (connection, result, error) -> Void in
            completion(dictionary: result as? NSDictionary, error: error)
        }
    }

    func getUserItemHistory(user: GoodCityUser) {

    }

    func updateTotalDonationsValueInUserDefaults() {
        PFCloud.callFunctionInBackground("getDonationStats",
            withParameters: ["userId": GoodCityUser.currentUser().objectId]) { (result, error) -> Void in
                if error == nil {
                    let userDefaults = NSUserDefaults(suiteName: "group.com.codepath.goodcity")

                    let totalDonationsValue = result["totalDonationsValue"] as? Double ?? 0
                    userDefaults?.setDouble(totalDonationsValue, forKey: TOTAL_DONATION_VALUE_KEY)

                    let totalDonationsCount = result["totalDonationsCount"] as? Int ?? 0
                    userDefaults?.setInteger(totalDonationsCount, forKey: TOTAL_DONATION_COUNT_KEY)
                    if let member = result["user"] as? PFUser {
                        let dateString = getFriendlyDateFormatter().stringFromDate(member.createdAt)
                        userDefaults?.setObject(dateString, forKey: MEMBER_SINCE_KEY)
                    }
                    userDefaults?.synchronize()
                } else {
                    println("Error from Parse Cloud Code: \(error)")
                }
        }
    }

}
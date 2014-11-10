//
//  AppDelegate.swift
//  GoodCity
//
//  Created by Nick Aiwazian on 10/5/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, PNDelegate {

    private let PICKUP_ACTION_IDENTIFIER = "PICKUP_IDENTIFIER"
    private let DROPOFF_ACTION_IDENTIFIER = "DROPOFF_IDENTIFIER"

    var window: UIWindow?
    var containerViewController: ContainerViewController?

    func displayLoginScreen() {
        println("Displaying login screen from AppDelegate")
        let loginViewController = LoginViewController(nibName: "LoginViewController", bundle: nil)
        self.window?.rootViewController = loginViewController
    }

    private func displayHomeScreen() {
        println("Displaying home screen from AppDelegate")
        
        let userDefaults = NSUserDefaults(suiteName: "group.com.codepath.goodcity")
        if let volunteer = userDefaults?.valueForKey(LOGGED_IN_AS_VOLUNTEER_KEY) as? Bool {
            if volunteer {
                println("launched reviewer app")
                let reviewItemsViewController = ReviewItemsViewController(nibName: "ReviewItemsViewController", bundle: nil)
                self.window?.rootViewController = reviewItemsViewController
            }
            else {
                self.containerViewController = ContainerViewController(nibName: "ContainerViewController", bundle: nil)
                self.window?.rootViewController = containerViewController
            }
        }
        else {
            println("User Logged In as State key missing")
            GoodCityUser.currentUser().logout()
            displayLoginScreen()
        }
    }

    
    func setupParse() {
        Parse.setApplicationId(PARSE_APPLICATION_ID, clientKey: PARSE_CLIENT_KEY)
        PFFacebookUtils.initializeFacebook()
    }

    func setupPubNub() {
        PubNub.setDelegate(self)
        let configuration = PNConfiguration(publishKey: PUB_NUB_PUBLISH_KEY, subscribeKey: PUB_NUB_SUBSCRIBE_KEY, secretKey: PUB_NUB_SECRET_KEY)
        PubNub.setConfiguration(configuration)
        PubNub.connect()
    }

    func setupGlobalNavBarAttributes() {
        UIBarButtonItem.appearance().tintColor = UIColor.whiteColor()
    }
    func registerForPushNotifications(application: UIApplication) {

        let dropoffAction = UIMutableUserNotificationAction()
        dropoffAction.identifier = DROPOFF_ACTION_IDENTIFIER
        dropoffAction.title = "Find nearest dropoff"
        dropoffAction.activationMode = UIUserNotificationActivationMode.Foreground
        dropoffAction.destructive = false

        let pickupAction = UIMutableUserNotificationAction()
        pickupAction.identifier = PICKUP_ACTION_IDENTIFIER
        pickupAction.title = "Schedule pickup"
        pickupAction.activationMode = UIUserNotificationActivationMode.Foreground
        pickupAction.destructive = false

        let notificationCategory = UIMutableUserNotificationCategory()
        notificationCategory.identifier = "DONATION_APPROVED_CATEGORY"
        notificationCategory.setActions([dropoffAction, pickupAction], forContext: .Default)

        let categories = NSSet(object: notificationCategory)

        if application.respondsToSelector("registerUserNotificationSettings:") {
            println("Registering for push notifications the iOS8 way")
            let userNotificationTypes = UIUserNotificationType.Alert | UIUserNotificationType.Badge | UIUserNotificationType.Sound
            let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: categories)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        } else { // Before iOS 8
            println("Registering for push notifications the pre-iOS8 way")
            application.registerForRemoteNotificationTypes(UIRemoteNotificationType.Badge | UIRemoteNotificationType.Alert | UIRemoteNotificationType.Sound)
        }
    }

    // Notification action handler
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        println("Notification action received.")
        if identifier == PICKUP_ACTION_IDENTIFIER {
            println("Pick up action recognized.")
            self.containerViewController?.launchScheduleView()
        } else if identifier == DROPOFF_ACTION_IDENTIFIER {
            println("Drop off action recognized.")
            self.containerViewController?.launchMapView()
        } else {
            println("Error: Unrecognized identifier sent to handleActionWithIdentifier")
        }
        completionHandler()
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // UI setup
        //application.setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Fade)
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.tintColor = blueHighlight
        //self.window?.tintColor = UIColor.orangeColor()

        // TODO: Move this to ONLY reviewer when reviewer goes into "Pick up" mode
        //LocationManager.sharedInstance.startStandardUpdates()

        self.setupParse()
        self.registerForPushNotifications(application)

        // Listen for log out notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userDidLogout", name: userDidLogoutNotification, object: nil)
        self.setupGlobalNavBarAttributes()
        if GoodCityUser.currentUser != nil {
            println("User is already logged in.  Going straight to home screen")
            self.displayHomeScreen()
        } else {
            println("No user found.  Going to login screen")
            self.displayLoginScreen()
        }

        self.window?.makeKeyAndVisible()
        setupPubNub()
        return true
    }

    // Handles logout notifications
    func userDidLogout() {
        self.displayLoginScreen()
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        if let scheme = url.scheme {
            if (scheme == "fb373287049514452") {
                println("Got a facebook url openUrl request")
                // SSO authorization flow.  Attempt to extract a token from the url
                return FBAppCall.handleOpenURL(url, sourceApplication: sourceApplication, withSession: PFFacebookUtils.session())
            } else if (scheme == "goodcity") {
                println("Got a goodcity url openUrl request")
                return true
            }
        }
        println("Unrecognized url sent to openUrl")
        return false
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Clear badge on launch
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0

        FBAppCall.handleDidBecomeActiveWithSession(PFFacebookUtils.session())
    }
    
    func applicationWillTerminate(application: UIApplication) {
        PFFacebookUtils.session().close()
    }

    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        if let desiredViewController = userInfo["vc"] as? NSString {
            if desiredViewController == "historyView" {
                println("got a driver notification...going to history view")
                }
        } else {
            // Default parse handling of push notif. Will pop alertview is app is in foreground
            PFPush.handlePush(userInfo)
        }
    }

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        println("APNs registration successful")
        let currentIntallation = PFInstallation.currentInstallation()
        currentIntallation.setDeviceTokenFromData(deviceToken)
        currentIntallation.saveEventually()
    }

    func pubnubClient(client: PubNub!, didReceiveMessage message: PNMessage!) {
        println("PubNub client received message: \(message)")
        NSNotificationCenter.defaultCenter().postNotificationName(DriverLocationDidChangeNotification, object: nil, userInfo: ["message": message.message])
    }

    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        println("Error registering for push notifications: \(error)")
    }

    func applicationDidEnterBackground(application: UIApplication) {
        LocationManager.sharedInstance.stopStandardUpdates()
    }
}


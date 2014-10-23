//
//  AppDelegate.swift
//  GoodCity
//
//  Created by Nick Aiwazian on 10/5/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let PICKUP_ACTION_IDENTIFIER = "PICKUP_IDENTIFIER"
    let DROPOFF_ACTION_IDENTIFIER = "DROPOFF_IDENTIFIER"

    var window: UIWindow?
    var containerViewController: ContainerViewController?

    func displayLoginScreen() {
        let loginViewController = LoginViewController(nibName: "LoginViewController", bundle: nil)
        self.window?.rootViewController = loginViewController
    }

    private func displayHomeScreen() {
        self.containerViewController = ContainerViewController(nibName: "ContainerViewController", bundle: nil)
        self.window?.rootViewController = containerViewController
    }

    // Handles logout notifications
    func userDidLogout() {
        self.displayLoginScreen()
    }
    
    func setupParse() {
        Parse.setApplicationId(PARSE_APPLICATION_ID, clientKey: PARSE_CLIENT_KEY)
        PFFacebookUtils.initializeFacebook()
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

    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        println("Got a notification action!!!")
        if identifier == PICKUP_ACTION_IDENTIFIER {
            println("Pick up action recognized")
            // Time to take user to hisory view
            self.containerViewController?.launchScheduleView()
        } else if identifier == DROPOFF_ACTION_IDENTIFIER {
            println("Drop off action recognized")
            // Time to take user to map view
            self.containerViewController?.launchMapView()
        } else {
            println("ERROR: Unrecognized identifier sent to handleActionWithIdentifier")
        }

        completionHandler()
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent

        // Clear badge on launch
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        //application.setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Fade)
        
        self.setupParse()
        self.registerForPushNotifications(application)
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.tintColor = tintColor

        // Listen for log out notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userDidLogout", name: userDidLogoutNotification, object: nil)
        if GoodCityUser.currentUser != nil {
            // User is already logged in
            println("User is already logged in.  Going straight to home screen")
            self.displayHomeScreen()
        } else {
            println("No user found.  Going to login screen")
            self.displayLoginScreen()
        }

        self.window?.makeKeyAndVisible()
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String, annotation: AnyObject?) -> Bool {
        // Attempt to extract a token from the url
        return FBAppCall.handleOpenURL(url, sourceApplication: sourceApplication, withSession: PFFacebookUtils.session())
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        FBAppCall.handleDidBecomeActiveWithSession(PFFacebookUtils.session())
    }
    
    func applicationWillTerminate(application: UIApplication) {
        PFFacebookUtils.session().close()
    }

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        println("APNs registration successful")
        let currentIntallation = PFInstallation.currentInstallation()
        currentIntallation.setDeviceTokenFromData(deviceToken)
        currentIntallation.saveInBackgroundWithTarget(nil, selector: nil)
    }

    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        PFPush.handlePush(userInfo)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
}


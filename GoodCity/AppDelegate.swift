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
    
    var window: UIWindow?
    
    func displayLoginScreen() {
        let loginViewController = LoginViewController(nibName: "LoginViewController", bundle: nil)
        self.window?.rootViewController = loginViewController
    }

    private func displayHomeScreen() {
        let containerViewController = ContainerViewController(nibName: "ContainerViewController", bundle: nil)
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
        if application.respondsToSelector("registerUserNotificationSettings:") {
            println("Registering for push notifications the iOS8 way")
            let userNotificationTypes = UIUserNotificationType.Alert | UIUserNotificationType.Badge | UIUserNotificationType.Sound
            let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        } else { // Before iOS 8
            println("Registering for push notifications the pre-iOS8 way")
            application.registerForRemoteNotificationTypes(UIRemoteNotificationType.Badge | UIRemoteNotificationType.Alert | UIRemoteNotificationType.Sound)
        }
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
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


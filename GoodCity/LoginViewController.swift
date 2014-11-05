//
//  LoginViewController.swift
//  GoodCity
//
//  Created by Nick Aiwazian on 10/5/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var FBLoginButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Old code if we want to use Facebook graphic
        // let loginView = FBLoginView()
        // loginView.center = self.view.center
        // self.view.addSubview(loginView)

        //self.view.backgroundColor = tintColor
        
        FBLoginButton.backgroundColor = blueHighlight
        FBLoginButton.layer.cornerRadius = 20
        FBLoginButton.layer.masksToBounds = true
        let attributedTitle = NSMutableAttributedString(string: "Connect with Facebook")
        let range = NSMakeRange(0, attributedTitle.length)
        attributedTitle.addAttribute(NSFontAttributeName, value: FONT_MEDIUM_14!, range: range)
        attributedTitle.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: range)
        FBLoginButton.setAttributedTitle(attributedTitle, forState: .Normal)
    }

    private func updateCurrentInstallationUserInfo() {
        let currentIntallation = PFInstallation.currentInstallation()
        if GoodCityUser.currentUser() != nil {
            println("User is not null...updating installation")
            currentIntallation["owner"] = GoodCityUser.currentUser()
            currentIntallation.saveInBackgroundWithTarget(nil, selector: nil)
      }
    }

    private func loginWithParse(volunteer: Bool = false) {
        ParseClient.sharedInstance.loginOrSignupWithCompletion { (user, error) -> () in
            if error == nil {
                ParseClient.sharedInstance.refreshUserInfoFromFacebookWithCompletion({ (dictionary, error) -> () in
                    if let dict = dictionary {
                        println("Got a successful response from Facebook...going to home screen")
                        GoodCityUser.currentUser?.updateFacebookInfo(dict)
                        self.updateCurrentInstallationUserInfo()
                        self.goToHomeScreen(volunteer)
                    } else {
                        println("Facebook user info dict is nil")
                    }
                })
            } else {
                println("Failed getting info from facebook with error: \(error)")
            }
        }
    }
    
    // Login button tapped
    @IBAction func loginButtonTapped(sender: UIButton) {
        self.loginWithParse()
    }
    
    @IBAction func loginAsVolunteer(sender: AnyObject) {
        self.loginWithParse(volunteer: true)
    }
    
    private func goToHomeScreen(volunteer: Bool) {
        if volunteer {
            println("launched reviewer app")
            let reviewItemsViewController = ReviewItemsViewController(nibName: "ReviewItemsViewController", bundle: nil)
            self.presentViewController(reviewItemsViewController, animated: true, completion: { () -> Void in
                println("launched the profile view controller")
                self.saveLogInAsState(volunteer)
            })
        }
        else {
            let containerViewController = ContainerViewController(nibName: "ContainerViewController", bundle: nil)
            self.presentViewController(containerViewController, animated: true, completion: { () -> Void in
                NSLog("Successfully pushed the container view")
                self.saveLogInAsState(volunteer)
            })
        }
    }
    
    private func saveLogInAsState(volunteer: Bool) {
        let userDefaults = NSUserDefaults(suiteName: "group.com.codepath.goodcity")
        userDefaults?.setBool(volunteer, forKey: LOGGED_IN_AS_VOLUNTEER_KEY)
        userDefaults?.synchronize()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}

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
        
        FBLoginButton.backgroundColor = tintColor
        FBLoginButton.layer.cornerRadius = 25
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

    private func loginWithParse() {
        ParseClient.sharedInstance.loginOrSignupWithCompletion { (user, error) -> () in
            if error == nil {
                ParseClient.sharedInstance.refreshUserInfoFromFacebookWithCompletion({ (dictionary, error) -> () in
                    if let dict = dictionary {
                        println("Got a successful response from Facebook...going to home screen")
                        GoodCityUser.currentUser?.updateFacebookInfo(dict)
                        self.updateCurrentInstallationUserInfo()
                        self.goToHomeScreen()
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
    
    private func goToHomeScreen() {
        let containerViewController = ContainerViewController(nibName: "ContainerViewController", bundle: nil)
        self.presentViewController(containerViewController, animated: true, completion: { () -> Void in
            NSLog("Successfully pushed the container view")
        })
    }
    
    @IBAction func onTapSkip(sender: AnyObject) {
        goToHomeScreen()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}

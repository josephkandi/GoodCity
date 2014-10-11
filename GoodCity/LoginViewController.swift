//
//  LoginViewController.swift
//  GoodCity
//
//  Created by Nick Aiwazian on 10/5/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //let testObject = PFObject(className: "TestObject")
        //testObject["foo"] = "bar"
        //testObject.saveInBackground()

        // Old code if we want to use Facebook graphic
        // let loginView = FBLoginView()
        // loginView.center = self.view.center
        // self.view.addSubview(loginView)
    }
    
    override func viewDidAppear(animated: Bool) {
        // Is user cached and linked to Facebook
        if PFUser.currentUser() != nil && PFFacebookUtils.isLinkedWithUser(PFUser.currentUser()) {
            self.goToHomeView()
        }
    }
    
    // Login button tapped
    @IBAction func loginButtonTapped(sender: UIButton) {
        self.loginOrSignUpUser()
    }
    
    // New user...might want to show first use screen?
    private func handleSignupSuccess() {
        // Just follow same path as existing user for now
        self.handleLoginSuccess()
    }
    
    // Existing user
    private func handleLoginSuccess() {
        User.refreshUserData()
        self.goToHomeView()
    }
    
    private func goToHomeView() {
        let containerViewController = ContainerViewController(nibName: "ContainerViewController", bundle: nil)
        self.presentViewController(containerViewController, animated: true, completion: { () -> Void in
            NSLog("Successfully pushed the container view")
        })
    }
    
    private func loginOrSignUpUser() {
        let permissionsArray = [] // Can also request "user_location"
        
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
                } else if user.isNew { // New user
                    println("User signed up and logged in with Facebook")
                    self.handleSignupSuccess()
                } else { // Existing user
                    println("User logged in via Facebook")
                    self.handleLoginSuccess()
                }
        })
        // TODO: Show activityIndicator.startAnimating() - Show loading indicator until login is finished
    }
    
    
    @IBAction func onTapSkip(sender: AnyObject) {
        goToHomeView()
    }
    
}

//
//  ProfileViewController.swift
//  GoodCity
//
//  Created by Yili Aiwazian on 10/24/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

private let marginTopBottom: CGFloat = 22
private let marginLeftRight: CGFloat = 22
private let gapMargin: CGFloat = 10
private let iconWidth: CGFloat = 40
private let profileImageSize: CGFloat = 60

class ProfileViewController: UIViewController {

    var bgImage: UIImage!
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var blurView: UIVisualEffectView!
   
    @IBOutlet weak var contentContainerView: UIView!

    @IBOutlet weak var profileInfoContainerView: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!

    @IBOutlet weak var progressRing: M13ProgressViewRing!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var logoutButton: RoundedButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bgImageView.image = bgImage
        contentContainerView.alpha = 0
        profileImage.layer.cornerRadius = 30
        profileImage.layer.masksToBounds = true
        
        addressLabel.sizeToFit()
                
        if let currentUser = GoodCityUser.currentUser {
            profileImage.fadeInImageFromURL(NSURL(string: currentUser.profilePhotoUrlString)!, border: true)
            usernameLabel.text = currentUser.firstName + " " + currentUser.lastName
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.contentContainerView.transform = CGAffineTransformMakeScale(1.2, 1.2)
        UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            self.contentContainerView.transform = CGAffineTransformMakeScale(1.0, 1.0)
            self.contentContainerView.alpha = 1
        }) { (finished) -> Void in
            println("animated in")
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        progressRing.setProgress(0.56, animated: true)
    }
    
    override func viewWillLayoutSubviews() {
        let bounds = self.view.bounds
        
        contentContainerView.frame = bounds
        closeButton.frame = CGRectMake(bounds.width-marginLeftRight-iconWidth, marginTopBottom, iconWidth, iconWidth)
        
        // Set the starting point frame for the profile info container view
        profileInfoContainerView.frame = CGRectMake(marginLeftRight*1.5, marginTopBottom*4, bounds.width-marginLeftRight*3, 200)
        profileImage.frame = CGRectMake(0, 0, profileImageSize, profileImageSize)
        usernameLabel.frame = CGRectMake(profileImage.frame.width + gapMargin, 4, profileInfoContainerView.frame.width - profileImage.frame.width - gapMargin, 20)
        usernameLabel.sizeToFit()
        addressLabel.frame = CGRectMake(usernameLabel.frame.origin.x, usernameLabel.frame.height + 4, profileInfoContainerView.frame.width - profileImage.frame.width - gapMargin, 40)
        addressLabel.sizeToFit()
        // Resize and recenter the profile info container in view
        let width = max(usernameLabel.frame.width, addressLabel.frame.width) + usernameLabel.frame.origin.x
        let height = addressLabel.frame.height+addressLabel.frame.origin.y
        profileInfoContainerView.frame = CGRectMake((bounds.width-width)/2, profileInfoContainerView.frame.origin.y, width, height)
        
        // setup the log out button
        logoutButton.frame = CGRectMake((bounds.width-150)/2, bounds.height-marginTopBottom*2-40, 150, 40)
        
        let progressRingSize: CGFloat = 220
        let yOffset = (bounds.height - profileInfoContainerView.frame.height - profileInfoContainerView.frame.origin.y - progressRingSize) / 2 + profileInfoContainerView.frame.height + profileInfoContainerView.frame.origin.y - 50
        
        progressRing.frame = CGRectMake((bounds.width - progressRingSize) / 2, yOffset, progressRingSize, progressRingSize)
    }
    
    @IBAction func onTapClose(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            println("dismissed profile view")
        })
    }

    @IBAction func onTapLogOut(sender: AnyObject) {
        GoodCityUser.currentUser().logout()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}

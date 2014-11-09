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

class ProfileViewController: UIViewController, EditAddressViewDelegate {

    var bgImage: UIImage!
    @IBOutlet weak var blurView: UIVisualEffectView!
   
    @IBOutlet weak var contentContainerView: UIView!
    @IBOutlet weak var profileMainView: UIView!
    @IBOutlet weak var profileInfoContainerView: UIView!
    var tapGesture: UIGestureRecognizer!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!

    @IBOutlet weak var progressRing: M13ProgressViewRing!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var logoutButton: RoundedButton!
    @IBOutlet weak var shareTwitter: UIButton!
    @IBOutlet weak var shareFB: UIButton!
    
    @IBOutlet weak var editAddressview: EditAddressView!
    var userAddress: Address?
    var donationCount: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentContainerView.alpha = 0
        editAddressview.alpha = 0
        editAddressview.delegate = self
        editAddressview.layer.cornerRadius = 4
        editAddressview.layer.masksToBounds = true
        editAddressview.setTitleText("Edit Address")
        editAddressview.setExplanationText("")
        editAddressview.setDoneButtonText("Done")
        
        profileImage.layer.cornerRadius = 30
        profileImage.layer.masksToBounds = true
        tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: "launchEditAddressView")
        profileInfoContainerView.addGestureRecognizer(tapGesture)
        
        logoutButton.setButtonColor(UIColor.lightGrayColor())
        logoutButton.setButtonSytle(1)
        logoutButton.setButtonTitle("Log Out")
        progressRing.donationLevelCount = DONATION_LEVEL_COUNT
        

        shareFB.setImage(UIImage(named: "profile_fb")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: .Normal)
        shareTwitter.setImage(UIImage(named: "profile_twitter")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: .Normal)
        shareFB.tintColor = UIColor.whiteColor()
        shareTwitter.tintColor = UIColor.whiteColor()
        
        
        if let currentUser = GoodCityUser.currentUser {
            profileImage.fadeInImageFromURL(NSURL(string: currentUser.profilePhotoUrlString)!, border: true)
            usernameLabel.text = currentUser.firstName + " " + currentUser.lastName

            Address.getAddressForCurrentUserWithBlock({ (address, error) -> () in
                if address != nil {
                    self.userAddress = address
                    self.setAddressLabelText(self.userAddress!)
                    self.editAddressview.setAddress(self.userAddress!)
                }
            });
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

    private func updateProgressRingValue() {
        var count = CGFloat(0)
        println("Initializing progress ring count to zero")
        if let userDefaults = NSUserDefaults(suiteName: "group.com.codepath.goodcity") {
            if let donationCount = userDefaults.valueForKey(TOTAL_DONATION_COUNT_KEY) as? Int {
                count = CGFloat(donationCount)
                println("Updating progress ring count to: \(count)")
            }
        }
        progressRing.setProgress(count/CGFloat(DONATION_LEVEL_COUNT), animated: true)
        donationCount = Int(count)
    }

    override func viewDidAppear(animated: Bool) {
        self.updateProgressRingValue()
    }
    
    override func viewWillLayoutSubviews() {
        let bounds = self.view.bounds
        
        contentContainerView.frame = bounds
        profileMainView.frame = contentContainerView.bounds
        editAddressview.frame = CGRectMake(20, 50, bounds.width-40, bounds.height-120)
        closeButton.frame = CGRectMake(bounds.width-marginLeftRight-iconWidth, marginTopBottom, iconWidth, iconWidth)
        
        // Set the starting point frame for the profile info container view
        profileInfoContainerView.frame = CGRectMake(marginLeftRight*1.5, marginTopBottom*4, bounds.width-marginLeftRight*3, 200)
        profileImage.frame = CGRectMake(0, 0, profileImageSize, profileImageSize)
        usernameLabel.frame = CGRectMake(profileImage.frame.width + gapMargin, 4, profileInfoContainerView.frame.width - profileImage.frame.width - gapMargin, 20)
        usernameLabel.sizeToFit()
        addressLabel.frame = CGRectMake(usernameLabel.frame.origin.x, usernameLabel.frame.height + 4, profileInfoContainerView.frame.width - profileImage.frame.width - gapMargin, 40)
       
        if (self.userAddress != nil) {
            addressLabel.sizeToFit()
        }
        // Resize and recenter the profile info container in view
        let width = max(usernameLabel.frame.width, addressLabel.frame.width) + usernameLabel.frame.origin.x
        let height = addressLabel.frame.height+addressLabel.frame.origin.y
        profileInfoContainerView.frame = CGRectMake((bounds.width-width)/2, profileInfoContainerView.frame.origin.y, width, height)
        
        // setup the log out button
        logoutButton.frame = CGRectMake((bounds.width-150)/2, bounds.height-marginTopBottom*2-40, 150, 40)
    
        let progressRingSize: CGFloat = 220
        let yOffset = (bounds.height - profileInfoContainerView.frame.height - profileInfoContainerView.frame.origin.y - progressRingSize) / 2 + profileInfoContainerView.frame.height + profileInfoContainerView.frame.origin.y - 50
        
        progressRing.frame = CGRectMake((bounds.width - progressRingSize) / 2, yOffset, progressRingSize, progressRingSize)
        
        let iconSize: CGFloat = 30
        let iconGap: CGFloat = 15
        shareFB.frame = CGRectMake(progressRing.frame.origin.x+(progressRingSize-iconSize*2-iconGap)/2, progressRing.frame.origin.y+progressRingSize-85, iconSize, iconSize)
        shareTwitter.frame = CGRectMake(shareFB.frame.origin.x+iconSize+iconGap, progressRing.frame.origin.y+progressRingSize-85, iconSize, iconSize)

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
    
    func launchEditAddressView() {
        UIView.animateWithDuration(0.4, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            self.editAddressview.alpha = 1
            self.profileMainView.alpha = 0
            
            }) { (finished) -> Void in
                println("animation completed")
        }
    }
    
    func onTapDone(address: Address) {
        UIView.animateWithDuration(0.4, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            self.editAddressview.alpha = 0
            self.profileMainView.alpha = 1
            
            }) { (finished) -> Void in
                println("animation completed")
        }
        if let currentUser = GoodCityUser.currentUser {
            address.saveEventually()
            userAddress = address
            setAddressLabelText(address)
        }
    }
    func setAddressLabelText(address: Address) {
        let line2 = address.line2 == "" ? "" : ", \(address.line2)"
        let city = address.city == "" ? "" : ", \(address.city)"
        let state = address.state == "" ? "" : ", \(address.state)"
        let zip = address.zip == "" ? "" : " \(address.zip)"
        
        UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            self.addressLabel.text = address.line1 + line2 + city + state + zip
            self.addressLabel.sizeToFit()
            }) { (finished) -> Void in
                println("set address")
        }

    }
    @IBAction func onTapFBShare(sender: AnyObject) {
        SocialSharing.postToSocialNetwork(.Facebook, message: "I donated \(donationCount) items to GoodCity. You can do it too!", presentingViewController: self, image: UIImage(named: "profile_share_image"))
    }
    
    @IBAction func onTapTwitterShare(sender: AnyObject) {
        SocialSharing.postToSocialNetwork(.Twitter, message: "I donated \(donationCount) items to GoodCity. You can do it too!", presentingViewController: self, image: UIImage(named: "profile_share_image"))
    }
    
}

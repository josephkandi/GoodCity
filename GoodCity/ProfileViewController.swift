//
//  ProfileViewController.swift
//  GoodCity
//
//  Created by Yili Aiwazian on 10/24/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    var bgImage: UIImage!
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var blurView: UIVisualEffectView!
   
    @IBOutlet weak var contentContainerView: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var itemsLabel: UILabel!

    @IBOutlet weak var closeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bgImageView.image = bgImage
        contentContainerView.alpha = 0
        profileImage.layer.cornerRadius = 30
        profileImage.layer.masksToBounds = true
                
        if let currentUser = GoodCityUser.currentUser {
            //profileImage.fadeInImageFromURL(NSURL(string: currentUser.profilePhotoUrlString)!)
            //usernameLabel.text = currentUser.firstName + " " + currentUser.lastName
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
    
    @IBAction func onTapClose(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            println("dismissed profile view")
        })
    }

    @IBAction func onTapLogOut(sender: AnyObject) {
        println("TODO: Implement log out")
    }
}

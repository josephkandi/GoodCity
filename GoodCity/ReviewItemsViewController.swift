//
//  ReviewItemsViewController.swift
//  GoodCity
//
//  Created by Yili Aiwazian on 11/1/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

private let marginLeftRight: CGFloat = 16
private let marginTop: CGFloat = 16

class ReviewItemsViewController: UIViewController, DraggableItemImageViewDelegate {

    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var currentItemView: DraggableItemImageView!

    var itemsToReview = NSMutableArray()
    var approvedItems = NSMutableArray()
    var rejectedItems = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.styleNavBar(navBar)
        
        currentItemView.frame = CGRectMake(marginLeftRight, marginTop+64, self.view.frame.width-marginLeftRight*2, self.view.frame.width-marginLeftRight*2 + 70)
        currentItemView.delegate = self

        self.currentItemView.alpha = 0
        self.view.backgroundColor = LIGHT_GRAY_BG
        getPendingItemsFromServer()
    }
    
    override func viewWillLayoutSubviews() {
        navBar.frame = CGRectMake(0, 0, self.view.frame.width, 64)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onTapDismiss(sender: AnyObject) {
        GoodCityUser.currentUser().logout()
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func updateView() {
        if itemsToReview.count == 0 {
            return
        }
        self.currentItemView.alpha = 0
        let item = itemsToReview.firstObject! as DonationItem
        currentItemView.setItemDetails(item)
        item.photo.getDataInBackgroundWithBlock({ (photoData, error) -> Void in
            if error == nil {
                let image = UIImage(data: photoData)
                self.currentItemView.image = image
                UIView.animateWithDuration(0.4, animations: { () -> Void in
                    self.currentItemView.alpha = 1
                })
            }
            else {
                println("error fetching the photo")
            }
        })
    }
    
    private func getPendingItemsFromServer() {
        DonationItem.getAllItemsWithStates({
            (objects, error) -> () in
            if let donationItems = objects as? [DonationItem] {
                self.itemsToReview.addObjectsFromArray(donationItems)
                self.updateView()
            }
            else {
                println("Error trying to get pending items from server: \(error)")
            }
            }, states: [ItemState.Pending], user: nil)
    }
    
    // DraggableItemImageView delegate methods
    func onApprove() {
        let item = itemsToReview.firstObject as DonationItem
        item.state = ItemState.Approved.rawValue
        item.driverUser = GoodCityUser.currentUser()
        item.saveEventually()
    
        approvedItems.addObject(item)
        itemsToReview.removeObjectAtIndex(0)
        currentItemView.restoreImage()
        updateView()
    }
    
    func onReject() {
        let item = itemsToReview.firstObject as DonationItem
        item.state = ItemState.NotNeeded.rawValue
        item.saveEventually()
        
        rejectedItems.addObject(item)
        itemsToReview.removeObjectAtIndex(0)
        currentItemView.restoreImage()
        updateView()
    }
    
    @IBAction func onTapDoneReviewing(sender: AnyObject) {
        println("Tapped on Done Reviewing Button")
    }
    
    @IBAction func onTapDrive(sender: AnyObject) {
        println("Tapped the drive button")
        goOnlineAsDriver()
    }
    
    // All items that are "SCHEDULED" that have "me" as driver are set to "ONTHEWAY"
    // Then push notifications are triggered
    func goOnlineAsDriver() {
        DonationItem.getAllItemsWithStates({
            (objects, error) -> () in
            if let donationItems = objects as? [DonationItem] {
                donationItems.map { $0.state = ItemState.OnTheWay.rawValue }
                PFObject.saveAllInBackground(donationItems, block: { (success, error) -> Void in
                    if success {
                        DriverOnTheWay.sendOnTheWayPushNotifs()
                    } else {
                        println("Error: Failed trying to save donationItems when going online: \(error)")
                    }
                })
            }
            else {
                println("Error trying to get scheduled items from server: \(error)")
            }
            }, states: [ItemState.Scheduled], user: nil, driverUser: GoodCityUser.currentUser())
    }
}

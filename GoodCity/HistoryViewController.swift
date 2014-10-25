//
//  HistoryViewController.swift
//  GoodCity
//
//  Created by Yili Aiwazian on 10/10/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

protocol ItemsActionDelegate {
    func viewDropoffLocations()
    func schedulePickup(donationGroup: DonationItemsAggregator.DonationGroup)
}

class HistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ItemsActionDelegate, UIViewControllerTransitioningDelegate {
    
    @IBOutlet weak var historyTableView: UITableView!

    var itemGroups: DonationItemsAggregator?
    var profileButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.styleNavBar()
 
        // Add the profile icon to the right nav bar
        let profileIcon = UIImage(named: "profile")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        
        profileButton = UIBarButtonItem(image: profileIcon, style: UIBarButtonItemStyle.Plain, target: self, action: "launchProfile")
        profileButton.tintColor = UIColor.whiteColor()
        self.navigationItem.setRightBarButtonItem(profileButton, animated: true)
        
        setupTableView()
        getItemGroups()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if (itemGroups != nil) {
            println("number of sections: \(itemGroups!.sortedSections.count) ")
            return itemGroups!.sortedSections.count
        }
        else {
            return 0
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (itemGroups != nil) {
            println("number of items in section\(section): \(itemGroups!.sortedSections[section].numberOfItems())")
            return itemGroups!.sortedSections[section].numberOfItems()
        }
        else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        if (itemGroups == nil) {
            return UITableViewCell()
        }
        
        let sortedSection = itemGroups!.sortedSections[indexPath.section]
        let item  = sortedSection.sortedDonationGroups[indexPath.row]
        let cell = historyTableView.dequeueReusableCellWithIdentifier("itemsGroupCell") as ItemsGroupCell
        cell.setDelegate(self)
        cell.setItemsGroup(item)
        cell.setItemsState(ItemState(rawValue: sortedSection.name)!)
        return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if (itemGroups == nil) {
            return nil
        }
        
        let sortedSection = itemGroups!.sortedSections[section]
        let header = historyTableView.dequeueReusableHeaderFooterViewWithIdentifier("sectionHeader") as SectionHeaderView
        header.setSectionTitle(sortedSection.name)
        return header

    }

    // HACK: Hardcoding the row height based on the different sections right now. Need to update with real model
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if (itemGroups == nil) {
            return 0
        }
        
        let sortedSection = itemGroups!.sortedSections[indexPath.section]
        let state = ItemState(rawValue: sortedSection.name)!
        let numberOfItems = sortedSection.sortedDonationGroups[indexPath.row].sortedDonationItems.count
    
        var height: CGFloat = 78
        if (state == ItemState.Approved || state == ItemState.Scheduled) {
            height += 41
        }
        height += ItemsGroupCell.getThumbnailsHeight(tableView.frame.width, count: numberOfItems)
        
        return height
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return SECTION_HEADER_HEIGHT
    }
    
    // Custom protocol methods
    func viewDropoffLocations() {
        let dropoffViewController = MapViewController(nibName: "MapViewController", bundle: nil)
        dropoffViewController.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
        
        self.navigationController?.presentViewController(dropoffViewController, animated: true, completion: { () -> Void in
            println("launched the dropoff view controller")
        })
    }
    
    func schedulePickup(donationGroup: DonationItemsAggregator.DonationGroup) {
        let scheduleViewController = SchedulePickupViewController(nibName: "SchedulePickupViewController", bundle: nil)
        scheduleViewController.itemsGroup = donationGroup
        scheduleViewController.bgImage = takeSnapshot()
        self.navigationController?.presentViewController(scheduleViewController, animated: false, completion: { () -> Void in
            println("launched the schedule view controller")
        })
    }
    
    func launchProfile() {
        println("launched profile view")
        let profileViewController = ProfileViewController(nibName: "ProfileViewController", bundle: nil)
        profileViewController.bgImage = takeSnapshot()
        
        // Custom view controller animation
        //profileViewController.transitioningDelegate = self;
        //profileViewController.modalPresentationStyle = UIModalPresentationStyle.Custom
        
        self.navigationController?.presentViewController(profileViewController, animated: false, completion: { () -> Void in
            println("launched the profile view controller")
        })
    }
    
    // Helper functions
    func takeSnapshot() -> UIImage{
        NSLog("begin snapshot")
        let layer = UIApplication.sharedApplication().keyWindow?.layer
        UIGraphicsBeginImageContextWithOptions(layer!.frame.size, true, 0)
        let context = UIGraphicsGetCurrentContext()
        layer!.renderInContext(context)
        let snapShotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        NSLog("end snapshot")
        return snapShotImage
    }
    
    func registerTableViewCellNib(nibName: String, reuseIdentifier: String) {
        let nib = UINib(nibName: nibName, bundle: nil)
        self.historyTableView.registerNib(nib, forCellReuseIdentifier: reuseIdentifier)
    }
    
    private func setupTableView() {
        historyTableView.dataSource = self
        historyTableView.delegate = self
        historyTableView.rowHeight = UITableViewAutomaticDimension
        historyTableView.estimatedRowHeight = 200
        registerTableViewCellNib("ItemsGroupCell", reuseIdentifier: "itemsGroupCell")
        historyTableView.registerClass(SectionHeaderView.self, forHeaderFooterViewReuseIdentifier: "sectionHeader")
    }
    
    private func getItemGroups() {
        DonationItem.getAllItemsWithStates({
            (objects, error) -> () in
            println("Completed")
            if error == nil {
                if (objects.count == 0 ) {
                    println("There are no results")
                    return
                }
                println(objects)
                let result = DonationItemsAggregator(donationItems: objects as [DonationItem])
                self.itemGroups = result
                self.historyTableView.reloadData()
                
                for section in self.itemGroups!.sortedSections {
                    println(section.name)
                    for donationGroup in section.sortedDonationGroups {
                        println("  " + donationGroup.name)
                        for donationItem in donationGroup.sortedDonationItems {
                            println("    " + donationItem.itemDescription)
                        }
                    }
                }
            } else {
                println(error)
            }
            }
        )
    }
    
    // View Controller animation delegate methods
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let scaleModalAnimator = ScaleModalAnimator()
        return scaleModalAnimator
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let scaleModalAnimator = ScaleModalAnimator()
        scaleModalAnimator.presenting = true
        return scaleModalAnimator
    }
}

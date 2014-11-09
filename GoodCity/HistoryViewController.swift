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

let HistoryItemsDidChangeNotifications = "historyItemsDidChangeNotification"

class HistoryViewController: UIViewController, ItemsActionDelegate, UIViewControllerTransitioningDelegate {
    
    @IBOutlet weak var historyTableView: UITableView!

    // DonationsItemsAggregator array that maps to segmented control index
    var itemGroupsArray: [DonationItemsAggregator?]!
    var activitiesChooser: UISegmentedControl!

    var profileButton: UIBarButtonItem!
    var mapButton: UIBarButtonItem!
    var refreshControl: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        println("View will appear")
        // Style the nav bar
        self.styleNavBar(self.navigationController!.navigationBar)

        // Set up segmented control for switching between active and completed items
        activitiesChooser = UISegmentedControl(items: ["ACTIVE", "HISTORY"])
        let titleSytle = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: FONT_BOLD_14!]
        activitiesChooser.setTitleTextAttributes(titleSytle, forState: .Normal)
        activitiesChooser.selectedSegmentIndex = 0
        activitiesChooser.sizeToFit()
        activitiesChooser.addTarget(self, action: "switchTabs", forControlEvents: UIControlEvents.ValueChanged)
        self.navigationItem.titleView = activitiesChooser

        // Add the map icon to the left nav bar
        let mapIcon = UIImage(named: "map")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        mapButton = UIBarButtonItem(image: mapIcon, style: UIBarButtonItemStyle.Plain, target: self, action: "viewDropoffLocations")
        mapButton.tintColor = UIColor.whiteColor()
        var negativeSpacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
        negativeSpacer.width = -8;
        self.navigationItem.setLeftBarButtonItems([negativeSpacer, mapButton], animated: true)

        // Add the profile icon to the right nav bar
        let profileIcon = UIImage(named: "profile")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        profileButton = UIBarButtonItem(image: profileIcon, style: UIBarButtonItemStyle.Plain, target: self, action: "launchProfile")
        profileButton.tintColor = UIColor.whiteColor()
        self.navigationItem.setRightBarButtonItems([negativeSpacer, profileButton], animated: true)
        
        refreshDataFromServerForAllSegments()
        println("-----> add notification")
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshDataFromServerForCurrentlySelectedSegment", name: HistoryItemsDidChangeNotifications, object: nil)
    }

    override func viewWillDisappear(animated: Bool) {
        println("-----> remove notification")
        NSNotificationCenter.defaultCenter().removeObserver(self, name: HistoryItemsDidChangeNotifications, object: nil)
    }

    // Custom protocol methods
    func viewDropoffLocations() {
        let dropoffViewController = MapViewController(nibName: "MapViewController", bundle: nil)
        // Uncomment for testing Uber
        //let dropoffViewController = UberMapViewController(nibName: "UberMapViewController", bundle: nil)
        dropoffViewController.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
        
        self.navigationController?.presentViewController(dropoffViewController, animated: true, completion: { () -> Void in
            println("launched the dropoff view controller")
        })
    }
    
    func schedulePickup(donationGroup: DonationItemsAggregator.DonationGroup) {
        let scheduleViewController = SchedulePickupViewController(nibName: "SchedulePickupViewController", bundle: nil)
        scheduleViewController.itemsGroup = donationGroup
        scheduleViewController.modalPresentationStyle = .Custom
        self.navigationController?.presentViewController(scheduleViewController, animated: false,
            completion: { () -> Void in
            println("launched the schedule view controller")
        })
    }
    
    func launchProfile() {
        println("launched profile view")
        let profileViewController = ProfileViewController(nibName: "ProfileViewController", bundle: nil)
        
        // Custom view controller animation
        //profileViewController.transitioningDelegate = self;
        //profileViewController.modalPresentationStyle = UIModalPresentationStyle.Custom
        
        profileViewController.modalPresentationStyle = .Custom
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
        
        itemGroupsArray = [DonationItemsAggregator?]()
        itemGroupsArray.append(nil)
        itemGroupsArray.append(nil)
                
        historyTableView.dataSource = self
        historyTableView.delegate = self
        historyTableView.backgroundColor = LIGHT_GRAY_BG
        historyTableView.contentInset = UIEdgeInsetsMake(0, 0, 20, 0)
        //historyTableView.rowHeight = UITableViewAutomaticDimension
        //historyTableView.estimatedRowHeight = 200
        registerTableViewCellNib("ItemsGroupCell", reuseIdentifier: "itemsGroupCell")
        historyTableView.registerClass(SectionHeaderView.self, forHeaderFooterViewReuseIdentifier: "sectionHeader")

        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: "refreshDataFromServerForCurrentlySelectedSegment", forControlEvents: UIControlEvents.ValueChanged)
        self.historyTableView.addSubview(self.refreshControl)
    }

    func refreshDataFromServerForCurrentlySelectedSegment() {
        println("refreshing for current index")
        let index = activitiesChooser.selectedSegmentIndex
        if (index == 0) {
            getItemGroups(states: [ItemState.Scheduled, ItemState.Approved, ItemState.Pending], index: index)
        } else {
            getItemGroups(states: [ItemState.NotNeeded, ItemState.PickedUp], index: index)
        }
    }

    func refreshDataFromServerForAllSegments() {
        getItemGroups(states: [ItemState.Scheduled, ItemState.Approved, ItemState.Pending], index: 0)
        getItemGroups(states: [ItemState.NotNeeded, ItemState.PickedUp], index: 1)
    }

    func switchTabs() {
        // Reload data for the new tab index since the tableView is shared
        self.refreshDataFromServerForCurrentlySelectedSegment()
        self.historyTableView.reloadData()
    }

    private func getItemGroups(states: [ItemState]? = nil, index: Int) {
        DonationItem.getAllItemsWithStates({
            (objects, error) -> () in
            println("Completed")
            if error == nil {
                self.refreshControl.endRefreshing()
                if (objects.count == 0 ) {
                    println("There are no results")
                    self.itemGroupsArray[index] = nil
                    self.historyTableView.reloadData()
                    return
                }
                let result = DonationItemsAggregator(donationItems: objects as [DonationItem])
                self.itemGroupsArray[index] = result
                self.historyTableView.reloadData()
                
                for section in result.sortedSections {
                    println(section.name)
                    for donationGroup in section.sortedDonationGroups {
                        println("  " + donationGroup.name)
                        for donationItem in donationGroup.sortedDonationItems {
                            println("    " + donationItem.itemDescription)
                        }
                    }
                }
            } else {
                self.refreshControl.endRefreshing()
                println(error)
            }
            }, states: states
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

// TableView DataSource
extension HistoryViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if (itemGroupsArray[activitiesChooser.selectedSegmentIndex] != nil &&
            itemGroupsArray[activitiesChooser.selectedSegmentIndex]?.sortedSections.count > 0) {

                println("number of sections: \(itemGroupsArray[activitiesChooser.selectedSegmentIndex]!.sortedSections.count) ")
                self.historyTableView.backgroundView = nil
                return itemGroupsArray[activitiesChooser.selectedSegmentIndex]!.sortedSections.count
        } else {
            // Empty view
            let messageLabel = UILabel(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
            messageLabel.text = activitiesChooser.selectedSegmentIndex == 0 ? "There are no active items." : "There are no items in history."
            messageLabel.textColor = UIColor.lightGrayColor()
            messageLabel.numberOfLines = 0;
            messageLabel.textAlignment = NSTextAlignment.Center
            messageLabel.font = FONT_18
            messageLabel.sizeToFit()

            self.historyTableView.backgroundView = messageLabel;
        }

        return 0;
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (itemGroupsArray[activitiesChooser.selectedSegmentIndex] != nil) {
            println("number of items in section\(section): \(itemGroupsArray[activitiesChooser.selectedSegmentIndex]!.sortedSections[section].numberOfItems())")
            return itemGroupsArray[activitiesChooser.selectedSegmentIndex]!.sortedSections[section].numberOfItems()
        }
        else {
            return 0
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        if (itemGroupsArray[activitiesChooser.selectedSegmentIndex] == nil) {
            return UITableViewCell()
        }

        let sortedSection = itemGroupsArray[activitiesChooser.selectedSegmentIndex]!.sortedSections[indexPath.section]
        let item  = sortedSection.sortedDonationGroups[indexPath.row]
        let cell = historyTableView.dequeueReusableCellWithIdentifier("itemsGroupCell") as ItemsGroupCell
        cell.setDelegate(self)
        cell.setItemsGroup(item)
        cell.setItemsState(ItemState(rawValue: sortedSection.name)!)
        return cell
    }

}

// TableView Delegate
extension HistoryViewController: UITableViewDelegate {
    /*func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        if (itemGroupsArray[activitiesChooser.selectedSegmentIndex] == nil) {
            return nil
        }

        let sortedSection = itemGroupsArray[activitiesChooser.selectedSegmentIndex]!.sortedSections[section]
        let header = historyTableView.dequeueReusableHeaderFooterViewWithIdentifier("sectionHeader") as SectionHeaderView
        header.setSectionTitle(sortedSection.name)
        
        return header
    }*/

    // HACK: Hardcoding the row height based on the different sections right now. Need to update with real model
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {

        if (itemGroupsArray[activitiesChooser.selectedSegmentIndex] == nil) {
            return 0
        }

        let sortedSection = itemGroupsArray[activitiesChooser.selectedSegmentIndex]!.sortedSections[indexPath.section]
        let state = ItemState(rawValue: sortedSection.name)!
        let numberOfItems = sortedSection.sortedDonationGroups[indexPath.row].sortedDonationItems.count

        var height: CGFloat = 70
        if (state == ItemState.Approved || state == ItemState.Scheduled) {
            height += 55
        }
        height += ItemsGroupCell.getThumbnailsHeight(tableView.frame.width, count: numberOfItems)
        return height
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
}

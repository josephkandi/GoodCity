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

class HistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ItemsActionDelegate {
    
    @IBOutlet weak var historyTableView: UITableView!

    var itemGroups: DonationItemsAggregator?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.styleNavBar()
 
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
        cell.setItemsState(ItemState.fromRaw(sortedSection.name)!)
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
        let state = ItemState.fromRaw(sortedSection.name)!
        let numberOfItems = sortedSection.sortedDonationGroups[indexPath.row].sortedDonationItems.count
        let additionalRows = Int(CGFloat(numberOfItems) / ITEMS_PER_ROW)
    
        var height = 145
        
        if (state == ItemState.Approved || state == ItemState.Scheduled) {
            height += 41
        }
        if additionalRows != 0 {
            height += additionalRows * 66 + (additionalRows - 1)*5
        }
        
        return CGFloat(height)
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
        self.navigationController?.presentViewController(scheduleViewController, animated: true, completion: { () -> Void in
            println("launched the schedule view controller")
        })
    }
    
    // Helper functions
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
    
}

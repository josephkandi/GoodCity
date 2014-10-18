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
}

class HistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ItemsActionDelegate {
    
    @IBOutlet weak var historyTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.styleNavBar()
        
        historyTableView.dataSource = self
        historyTableView.delegate = self
        historyTableView.rowHeight = UITableViewAutomaticDimension
        historyTableView.estimatedRowHeight = 200
        
        registerTableViewCellNib("ItemsGroupCell", reuseIdentifier: "itemsGroupCell")
        historyTableView.registerClass(SectionHeaderView.self, forHeaderFooterViewReuseIdentifier: "sectionHeader")
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 1
        }
        else if (section == 1) {
            return 1
        }
        else if (section == 2) {
            return 3
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = historyTableView.dequeueReusableCellWithIdentifier("itemsGroupCell") as ItemsGroupCell
        cell.setDelegate(self)

        if indexPath.section == 0 {
            cell.setItemsState(ItemState.Scheduled)
        }
        else if indexPath.section == 1 {
            cell.setItemsState(ItemState.Approved)
        }
        else if (indexPath.section == 2) {
            cell.setItemsState(ItemState.PickedUp)
        }
        return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let header = historyTableView.dequeueReusableHeaderFooterViewWithIdentifier("sectionHeader") as SectionHeaderView
            header.setSectionTitle("Scheduled")
            return header
        }
        else if section == 1 {
            let header = historyTableView.dequeueReusableHeaderFooterViewWithIdentifier("sectionHeader") as SectionHeaderView
            header.setSectionTitle("Approved")
            return header
        }
        else if section == 2 {
            let header = historyTableView.dequeueReusableHeaderFooterViewWithIdentifier("sectionHeader") as SectionHeaderView
            header.setSectionTitle("History")
            return header
        }
        
        return nil
    }
    
    // HACK: Hardcoding the row height based on the different sections right now. Need to update with real model
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.section == 0 || indexPath.section == 1) {
            return 186
        }
        else {
            return 145
        }
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
    
    // Helper functions
    func registerTableViewCellNib(nibName: String, reuseIdentifier: String) {
        let nib = UINib(nibName: nibName, bundle: nil)
        self.historyTableView.registerNib(nib, forCellReuseIdentifier: reuseIdentifier)
    }
}

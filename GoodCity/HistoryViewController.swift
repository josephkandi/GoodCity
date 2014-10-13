//
//  HistoryViewController.swift
//  GoodCity
//
//  Created by Yili Aiwazian on 10/10/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var historyTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        historyTableView.dataSource = self
        historyTableView.delegate = self
        historyTableView.rowHeight = UITableViewAutomaticDimension
        historyTableView.estimatedRowHeight = 200
        
        registerTableViewCellNib("ItemsGroupCell", reuseIdentifier: "itemsGroupCell")
        historyTableView.registerClass(SectionHeaderView.self, forHeaderFooterViewReuseIdentifier: "sectionHeader")
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = historyTableView.dequeueReusableCellWithIdentifier("itemsGroupCell") as ItemsGroupCell
        
        return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let header = historyTableView.dequeueReusableHeaderFooterViewWithIdentifier("sectionHeader") as SectionHeaderView
            header.setSectionTitle("Approved")
            return header
        }
        return nil
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }
    
    // Helper functions
    func registerTableViewCellNib(nibName: String, reuseIdentifier: String) {
        let nib = UINib(nibName: nibName, bundle: nil)
        self.historyTableView.registerNib(nib, forCellReuseIdentifier: reuseIdentifier)
    }
}

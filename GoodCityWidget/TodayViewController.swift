//
//  TodayViewController.swift
//  GoodCityWidget
//
//  Created by Nick Aiwazian on 10/23/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    @IBOutlet weak var donationsValueLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        println("In viewDidLoad...")
        // Fetch network info
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "launchApp")
        self.view.addGestureRecognizer(tapGestureRecognizer)
        let userDefaults = NSUserDefaults(suiteName: "group.com.codepath.goodcity")
        if let value = userDefaults?.valueForKey("total_donation_value") as? Double {
            println("Value: \(value)")
            self.donationsValueLabel.text = NSString(format: "$%.2f", value)
        }         //self.donationsValueLabel.text = NSString(format: "$%.2f", 300)
        //        userDefaults?.setDouble(result as Double, forKey: "total_donation_value")

    }

    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        println("In widgetPerformUpdateWithCompletionHandler...")

        let userDefaults = NSUserDefaults(suiteName: "group.com.codepath.goodcity")
        if let value = userDefaults?.valueForKey("total_donation_value") as? Double {
            println("Value: \(value)")
            self.donationsValueLabel.text = NSString(format: "$%.2f", value)
        }         //self.donationsValueLabel.text = NSString(format: "$%.2f", 300)

        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        completionHandler(NCUpdateResult.NewData)
    }

    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsetsZero
    }

    func launchApp() {
        println("Registered tap...launching app")
        let url = NSURL(string: "goodcity://widget")
        self.extensionContext?.openURL(url!, completionHandler: nil)
    }
    
}

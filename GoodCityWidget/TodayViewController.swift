//
//  TodayViewController.swift
//  GoodCityWidget
//
//  Created by Nick Aiwazian on 10/23/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit
import NotificationCenter

let TOTAL_DONATION_VALUE_KEY = "total_donation_value"
let TOTAL_DONATION_COUNT_KEY = "total_donation_count"
let MEMBER_SINCE_KEY = "member_since"

class TodayViewController: UIViewController, NCWidgetProviding {

    @IBOutlet weak var donationCountLabel: UILabel!
    @IBOutlet weak var donationValueLabel: UILabel!
    @IBOutlet weak var memberSinceLabel: UILabel!
    @IBOutlet weak var badgeImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        println("In viewDidLoad...")

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "launchContainingApp")
        self.view.addGestureRecognizer(tapGestureRecognizer)

        self.updateFromUserDefaults()
    }

    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        println("In widgetPerformUpdateWithCompletionHandler...")

        self.updateFromUserDefaults()

        // TODO: Also fetch results from network in case items were approved since app was last opened
        completionHandler(NCUpdateResult.NoData)
    }

    func updateFromUserDefaults() {
        if let userDefaults = NSUserDefaults(suiteName: "group.com.codepath.goodcity") {
            if let donationValue = userDefaults.valueForKey(TOTAL_DONATION_VALUE_KEY) as? Double {
                self.donationValueLabel.text = NSString(format: "$%.2f", donationValue)
            }
            if let donationCount = userDefaults.valueForKey(TOTAL_DONATION_COUNT_KEY) as? Int {
                self.donationCountLabel.text = "\(donationCount)"
            }
            if let memberSince = userDefaults.objectForKey(MEMBER_SINCE_KEY) as? String {
                self.memberSinceLabel.text = memberSince
            }
        }
    }

    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsetsZero
    }

    func launchContainingApp() {
        println("Registered tap...launching app")
        let url = NSURL(string: "goodcity://widget")
        self.extensionContext?.openURL(url!, completionHandler: nil)
    }
}

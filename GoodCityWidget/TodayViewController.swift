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

    @IBOutlet weak var totalCountView: UIView!
    @IBOutlet weak var scheduleView: UIView!
    @IBOutlet weak var addItemView: UIView!

    var donationCount = 0
    var nextScheduledPickup = ""
    var numberOfItemsInNextPickup = 0
    var memberSince = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        println("In viewDidLoad...")

        self.updateFromUserDefaults()
        setup()

        //let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "launchContainingApp")
        //self.view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func setup() {
        let scheduleGroupView = UIView()
        scheduleGroupView.frame = CGRectMake(14, 12, self.view.bounds.width-28, 20)
        self.view.addSubview(scheduleGroupView)
        
        var bounds = scheduleGroupView.bounds
        let scheduleIcon = UIImageView(image: UIImage(named: "history_scheduled")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate))
        scheduleIcon.tintColor = blueHighlight
        scheduleIcon.frame = CGRectMake(0, 0, 24, 24)
        
        var xOffset: CGFloat = scheduleIcon.frame.origin.x + 10 + scheduleIcon.frame.width
        var yOffset: CGFloat = 0
        let scheduleLabel = UILabel(frame: CGRectMake(xOffset, 0, bounds.width - scheduleIcon.frame.width - 10, 10))
        scheduleLabel.text = "Next Scheduled Pickup:"
        scheduleLabel.font = FONT_12
        scheduleLabel.textColor = UIColor.whiteColor()
        scheduleLabel.sizeToFit()

        yOffset += scheduleLabel.frame.height
        let scheduleTime = UILabel(frame: CGRectMake(xOffset, yOffset, bounds.width - scheduleIcon.frame.width - 10, 10))
        scheduleTime.text = "\(self.nextScheduledPickup)"
        scheduleTime.font = FONT_MEDIUM_16
        scheduleTime.textColor = UIColor.whiteColor()
        scheduleTime.sizeToFit()
        
        yOffset += scheduleTime.frame.height
        let scheduleItems = UILabel(frame: CGRectMake(xOffset, yOffset, bounds.width - scheduleIcon.frame.width - 10, 10))
        scheduleItems.text = "\(self.numberOfItemsInNextPickup) items"
        scheduleItems.font = FONT_12
        scheduleItems.textColor = UIColor.whiteColor()
        scheduleItems.sizeToFit()
        
        yOffset += scheduleItems.frame.height
        scheduleGroupView.addSubview(scheduleIcon)
        scheduleGroupView.addSubview(scheduleLabel)
        scheduleGroupView.addSubview(scheduleTime)
        scheduleGroupView.addSubview(scheduleItems)
        scheduleGroupView.frame = CGRectMake(scheduleGroupView.frame.origin.x, scheduleGroupView.frame.origin.y, scheduleGroupView.frame.width, yOffset)
        
        yOffset += 20
        let totalDonationView = UIView()
        totalDonationView.frame = CGRectMake(scheduleGroupView.frame.origin.x, yOffset, scheduleGroupView.frame.width, 20)
        self.view.addSubview(totalDonationView)

        bounds = totalDonationView.bounds
        let donatedIcon = UIImageView(image: UIImage(named: "history_pickedup")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate))
        donatedIcon.tintColor = pinkHighlight
        donatedIcon.frame = CGRectMake(0, 4, 24, 24)
        
        yOffset = 0
        let totalLabel = UILabel(frame: CGRectMake(xOffset, yOffset, bounds.width - donatedIcon.frame.width - 10, 10))
        totalLabel.text = "\(self.donationCount) items donated"
        totalLabel.font = FONT_MEDIUM_16
        totalLabel.textColor = UIColor.whiteColor()
        totalLabel.sizeToFit()
        
        yOffset += totalLabel.frame.height
        let memberSince = UILabel(frame: CGRectMake(xOffset, yOffset, bounds.width - scheduleIcon.frame.width - 10, 10))
        memberSince.text = "Member since \(self.memberSince)"
        memberSince.font = FONT_12
        memberSince.textColor = UIColor.whiteColor()
        memberSince.sizeToFit()
        
        yOffset += memberSince.frame.height
        totalDonationView.addSubview(donatedIcon)
        totalDonationView.addSubview(totalLabel)
        totalDonationView.addSubview(memberSince)
        totalDonationView.frame = CGRectMake(totalDonationView.frame.origin.x, totalDonationView.frame.origin.y, totalDonationView.frame.width, yOffset)
        
        // Get Started button
        yOffset = totalDonationView.frame.origin.y + totalDonationView.frame.height + 20
        let startButton = RoundedButton()
        xOffset += totalDonationView.frame.origin.x
        startButton.frame = CGRectMake(xOffset, yOffset, self.view.bounds.width-2*xOffset, 30)
        self.view.addSubview(startButton)
        startButton.layer.cornerRadius = 4
        startButton.layer.masksToBounds = true
        startButton.setButtonColor(UIColor(white: 0.4, alpha: 0.5))
        startButton.setButtonTitle("Donate New Item")
        startButton.addTarget(self, action: "onTapNew", forControlEvents: UIControlEvents.TouchUpInside)
        
        yOffset += startButton.frame.height + 30
        self.preferredContentSize = CGSizeMake(0, yOffset);
    }
    
    func onTapNew() {
        launchContainingApp()
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        println("In widgetPerformUpdateWithCompletionHandler...")

        self.updateFromUserDefaults()

        // TODO: Also fetch results from network in case items were approved since app was last opened
        completionHandler(NCUpdateResult.NoData)
    }

    func updateFromUserDefaults() {
        if let userDefaults = NSUserDefaults(suiteName: "group.com.codepath.goodcity") {
            if let dc = userDefaults.valueForKey(TOTAL_DONATION_COUNT_KEY) as? Int {
                self.donationCount = dc
            }
            if let ms = userDefaults.objectForKey(MEMBER_SINCE_KEY) as? String {
                self.memberSince = ms
            }
            if let np = userDefaults.objectForKey(NEXT_SCHEDULE_PICKUP_KEY) as? String {
                self.nextScheduledPickup = np
            }
            if let npc = userDefaults.objectForKey(NUMBER_ITEMS_NEXT_PICKUP_KEY) as? Int {
                self.numberOfItemsInNextPickup = npc
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

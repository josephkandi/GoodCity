//
//  ActionButtonsView.swift
//  GoodCity
//
//  Created by Yili Aiwazian on 10/13/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

class ActionButtonsView: UIView {

    private var itemsState = ItemState.Pending
    private var delegate: ItemsActionDelegate?
    private var button1: RoundedButton!
    private var button2: RoundedButton!
    private var itemsGroup: DonationItemsAggregator.DonationGroup?
    private var line: UIView!
    
    convenience init(frame: CGRect, itemsState: ItemState, delegate: ItemsActionDelegate) {
        self.init(frame: frame)
        self.itemsState = itemsState
        self.delegate = delegate
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        button1 = RoundedButton()
        button2 = RoundedButton()
        button1.layer.cornerRadius = self.frame.height / 2
        button2.layer.cornerRadius = self.frame.height / 2
        button1.layer.masksToBounds = true
        button2.layer.masksToBounds = true
        
        line = UIView()
        line.backgroundColor = UIColor(white: 0.7, alpha: 1)
        line.frame = CGRectZero
        
        self.addSubview(line)
        self.addSubview(button1)
        self.addSubview(button2)
    }

    override func layoutSubviews() {
        let width = self.frame.width
        
        // Approved => lay out 2 buttons
        if itemsState == ItemState.Approved {
            
            button2.hidden = false
            button2.setButtonTitle("Schedule Pickup")
            button2.setButtonColor(tintColor)
            button2.setButtonSytle(1)
            button2.frame = CGRectMake((width-BUTTON_SPACING)/2+BUTTON_SPACING, 0, (width-BUTTON_SPACING)/2, self.frame.height)
            button2.addTarget(self, action: "onTapSchedulePickup", forControlEvents: UIControlEvents.TouchUpInside)
            
            line.frame = CGRectMake(0, self.frame.height / 2, width - button2.frame.width - SPACING, 0.5)

        }
        // Scheduled => lay out 1 button
        else if itemsState == ItemState.Scheduled {
            button1.hidden = false
            button2.hidden = true
            button1.setButtonTitle("Edit Pickup Schedule")
            button1.frame = CGRectMake(0, 0, width, self.frame.height)
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.x, self.frame.width, self.frame.height)
        }
        // All other states => no buttons
        else {
            button1.hidden = true
            button2.hidden = true
            self.frame = CGRectZero
        }
    }
    
    func setItemsState(state: ItemState) {
        self.itemsState = state
    }
    func setDelegate(delegate: ItemsActionDelegate) {
        self.delegate = delegate
    }
    func setItemsGroup(itemsGroup: DonationItemsAggregator.DonationGroup) {
        self.itemsGroup = itemsGroup
    }
    func onTapSchedulePickup() {
        self.delegate?.schedulePickup(itemsGroup!)
    }
    func onTapScheduleEdit() {
        
    }
    func onTapDropoff() {
        self.delegate?.viewDropoffLocations()
    }
}

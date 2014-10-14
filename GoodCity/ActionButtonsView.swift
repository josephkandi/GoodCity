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
        button1.layer.cornerRadius = BUTTON_HEIGHT / 2
        button2.layer.cornerRadius = BUTTON_HEIGHT / 2
        button1.layer.masksToBounds = true
        button2.layer.masksToBounds = true
        self.addSubview(button1)
        self.addSubview(button2)
    }

    override func layoutSubviews() {
        let width = self.frame.width
        
        // Approved => lay out 2 buttons
        if itemsState == ItemState.Approved {
            button1.hidden = false
            button2.hidden = false
            button1.setButtonTitle("Schedule Pickup")
            button2.setButtonTitle("Dropoff Locations")
            button1.frame = CGRectMake(0, 0, (width-BUTTON_SPACING)/2, BUTTON_HEIGHT)
            button2.frame = CGRectMake(button1.frame.width+BUTTON_SPACING, 0, (width-BUTTON_SPACING)/2, BUTTON_HEIGHT)
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.x, width, BUTTON_HEIGHT)

            button1.addTarget(self, action: "onTapSchedulePickup", forControlEvents: UIControlEvents.TouchUpInside)
            button2.addTarget(self, action: "onTapDropoff", forControlEvents: UIControlEvents.TouchUpInside)
        }
        // Scheduled => lay out 1 button
        else if itemsState == ItemState.Scheduled {
            button1.hidden = false
            button2.hidden = true
            button1.setButtonTitle("Edit Pickup Schedule")
            button1.frame = CGRectMake(0, 0, width, BUTTON_HEIGHT)
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.x, self.frame.width, BUTTON_HEIGHT)
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
    
    func onTapSchedulePickup() {
        
    }
    func onTapScheduleEdit() {
        
    }
    func onTapDropoff() {
        self.delegate?.viewDropoffLocations()
    }
}

//
//  SchedulePickupViewController.swift
//  GoodCity
//
//  Created by Nick Aiwazian on 10/5/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

class SchedulePickupViewController: UIViewController, MDCalendarDelegate {

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var datePickerButton: RoundedButton!
    @IBOutlet weak var datePickerView: UIView!
    @IBOutlet weak var datePickerHeightConstraint: NSLayoutConstraint!
    
    var pickerOpen = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = LIGHT_GRAY_BG
        
        closeButton.setImage(UIImage(named: "edit_close").imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: .Normal)
        closeButton.tintColor = tintColor
        
        // start with the date picker view closed
        datePickerHeightConstraint.constant = 0
    }


    @IBAction func onTapClose(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            println("dismissed schedule view")
        })
    }


    @IBAction func onTapDatePicker(sender: AnyObject) {
        self.view.layoutIfNeeded()
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.datePickerHeightConstraint.constant = self.pickerOpen ? 0 : 300
            self.pickerOpen = !self.pickerOpen
            self.view.layoutIfNeeded()
        })
    }

}

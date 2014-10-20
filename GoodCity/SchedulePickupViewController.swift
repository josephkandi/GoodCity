//
//  SchedulePickupViewController.swift
//  GoodCity
//
//  Created by Nick Aiwazian on 10/5/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

let DATE_PICKER_HEIGHT = CGFloat(280)

class SchedulePickupViewController: UIViewController, MDCalendarDelegate {

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var datePickerButton: RoundedButton!
    @IBOutlet weak var datePickerView: UIView!
    @IBOutlet weak var datePickerHeightConstraint: NSLayoutConstraint!
    
    var pickerOpen = false
    var calendarView: MDCalendar?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = LIGHT_GRAY_BG
        
        closeButton.setImage(UIImage(named: "edit_close").imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: .Normal)
        closeButton.tintColor = tintColor
        
        // start with the date picker view closed
        datePickerHeightConstraint.constant = 0
        initDatePicker()
    }

    @IBAction func onTapClose(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            println("dismissed schedule view")
        })
    }
    @IBAction func onTapDatePicker(sender: AnyObject) {
        self.view.layoutIfNeeded()
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.datePickerHeightConstraint.constant = self.pickerOpen ? 0 : DATE_PICKER_HEIGHT
            self.pickerOpen = !self.pickerOpen
            self.view.layoutIfNeeded()
        })
    }
    
    func initDatePicker() {
        
        let calendarView = MDCalendar()
        
        calendarView.backgroundColor = UIColor.clearColor()
        
        calendarView.lineSpacing = 0
        calendarView.itemSpacing = 0
        calendarView.borderColor = UIColor.clearColor()
        calendarView.borderHeight = 0
        calendarView.showsBottomSectionBorder = true
        
        calendarView.textColor = UIColor.darkTextColor()
        calendarView.headerTextColor = UIColor.darkTextColor()
        calendarView.weekdayTextColor = UIColor.darkTextColor()
        calendarView.cellBackgroundColor = UIColor.whiteColor()
        
        calendarView.highlightColor = tintColor
        calendarView.indicatorColor = tintColor
        
        let startDate = NSDate.date()
        let endDate = startDate.dateByAddingMonths(12*25)
        
        calendarView.startDate = startDate
        calendarView.endDate = endDate
        calendarView.delegate = self
        calendarView.canSelectDaysBeforeStartDate = false
        
        calendarView.dayFont = FONT_14
        calendarView.weekdayFont = FONT_MEDIUM_12
        calendarView.headerFont = FONT_MEDIUM_14
        
        datePickerView.addSubview(calendarView)
        self.calendarView = calendarView
    }
    
    override func viewDidLayoutSubviews() {
        if pickerOpen {
            calendarView?.frame = CGRectMake(0, 15, datePickerView.bounds.width, datePickerView.bounds.height-15)
        }
        else {
            calendarView?.frame = CGRectMake(0, 0, datePickerView.bounds.width, 1)
        }
    }
    
    func calendarView(calendarView: MDCalendar!, didSelectDate date: NSDate!) {
        let friendlyDate = date.descriptionWithLocale(NSLocale.currentLocale())
        NSLog("Selected Date: \(friendlyDate)")
    }

    func calendarView(calendarView: MDCalendar!, shouldShowIndicatorForDate date: NSDate!) -> Bool {
        return date.day() % 4 == 1
    }
}

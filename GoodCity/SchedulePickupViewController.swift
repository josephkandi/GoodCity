//
//  SchedulePickupViewController.swift
//  GoodCity
//
//  Created by Nick Aiwazian on 10/5/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

let DATE_PICKER_HEIGHT = CGFloat(280)

protocol SlotPickerDelegate {
    func selectSlot(slot: PickupScheduleSlot)
}

class SchedulePickupViewController: UIViewController, MDCalendarDelegate, SlotPickerDelegate {

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var datePickerButton: DatePickerButton!
    @IBOutlet weak var datePickerView: UIView!
    @IBOutlet weak var datePickerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var slotPickerView: SlotPickerView!
    
    var pickerOpen = false
    var calendarView: MDCalendar?
    var days = NSSet()
    var slots: [PickupScheduleSlot]?
    var itemsGroup: DonationItemsAggregator.DonationGroup?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = LIGHT_GRAY_BG
        closeButton.setImage(UIImage(named: "edit_close")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: .Normal)
        closeButton.tintColor = tintColor
        
        slotPickerView.delegate = self
        slotPickerView.date = datePickerButton.datePicked
        
        // start with the date picker view closed
        datePickerHeightConstraint.constant = 0
        getScheduleSlots()
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
    func getScheduleSlots() {
        PickupScheduleSlot.getAllAvailableSlots { (objects, error) -> () in
            if (error != nil) {
                println("Error getting available slots from Parse")
            } else {
                println("All slots: \(objects)")
                if let slots = objects as? [PickupScheduleSlot] {
                    self.days = PickupScheduleSlot.getDaysWithAtLeastOneAvailableSlot(slots)
                    self.slots = slots
                    println("Days with available slots: \(self.days)")
                    if self.days.count > 0 {
                        var minDate = NSDate.distantFuture() as NSDate
                        for day in self.days {
                            if day.compare(minDate) == NSComparisonResult.OrderedAscending {
                                minDate = day as NSDate
                            }
                        }
                        self.datePickerButton.datePicked = minDate
                        self.updateSlots(minDate)
                    }
                }
            }
        }
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
        
        let startDate = NSDate()
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
        self.datePickerButton.datePicked = date
        onTapDatePicker(self)
        updateSlots(date)
    }

    func calendarView(calendarView: MDCalendar!, shouldShowIndicatorForDate date: NSDate!) -> Bool {
        return self.days.containsObject(date.dateWithTimeTruncated())
    }
    func updateSlots(date: NSDate) {
        if (slots != nil) {
            let slotsForDay = PickupScheduleSlot.getAvailableSlotsForDay(date, slots: slots!)
            println("Slots for day \(date): \(slotsForDay)")
            slotPickerView.date = date
            slotPickerView.resetSlots()
            slotPickerView.updateAvailableSlots(slotsForDay)
        }
    }

    // Pick Slot Delegate methods
    func selectSlot(slot: PickupScheduleSlot) {
        println("Selecting slot: \(slot.startDateTime)")
        if let donationItems = self.itemsGroup?.sortedDonationItems {
            slot.grabSlot(donationItems)
        }
    }
}

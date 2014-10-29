//
//  SchedulePickupViewController.swift
//  GoodCity
//
//  Created by Nick Aiwazian on 10/5/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

private let DATE_PICKER_HEIGHT = CGFloat(260)
private let marginTopBottom: CGFloat = 40
private let marginLeftRight: CGFloat = 15
private let gapMargin: CGFloat = 24

protocol SlotPickerDelegate {
    func selectSlot(slot: PickupScheduleSlot)
}

class SchedulePickupViewController: UIViewController, MDCalendarDelegate, SlotPickerDelegate, EditAddressViewDelegate {

    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var contentContainerView: UIView!
    @IBOutlet weak var schedulePickupView: UIView!
    @IBOutlet weak var editAddressView: EditAddressView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateFieldLabel: UILabel!
    @IBOutlet weak var slotPickerView: SlotPickerView!
    @IBOutlet weak var datePickerButton: DatePickerButton!
    @IBOutlet weak var datePickerView: UIView!
    @IBOutlet weak var scheduleButton: RoundedButton!
    
    var pickerOpen = false
    var calendarView: MDCalendar?
    var days = NSSet()
    var slots: [PickupScheduleSlot]?
    var itemsGroup: DonationItemsAggregator.DonationGroup?
    var bgImage: UIImage!
    var selectedSlot: PickupScheduleSlot?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentContainerView.alpha = 0
        contentContainerView.layer.cornerRadius = ROUNDED_CORNER
        contentContainerView.layer.masksToBounds = true
        titleLabel.textAlignment = .Center
        
        closeButton.setImage(UIImage(named: "modal_close")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: .Normal)
        closeButton.tintColor = offWhiteColor
        
        slotPickerView.delegate = self
        slotPickerView.date = datePickerButton.datePicked
        editAddressView.delegate = self
        
        getScheduleSlots()
        initDatePicker()
    }

    override func viewDidAppear(animated: Bool) {
        
        let frame = contentContainerView.frame
        
        contentContainerView.frame = CGRectMake(frame.origin.x, frame.origin.y+700, frame.width, frame.height)
        
        UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 4, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            self.contentContainerView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.width, frame.height)
            self.contentContainerView.alpha = 1
        }) { (finished) -> Void in
            println("launch modal animation cmopleted")
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        let frame = contentContainerView.frame
        UIView.animateWithDuration(0.4, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            self.contentContainerView.frame = CGRectMake(frame.origin.x, frame.origin.y+700, frame.width, frame.height)
            self.contentContainerView.alpha = 0
        }) { (finished) -> Void in
            println("dismiss modal animation cmopleted")
        }
    }
    
    @IBAction func onTapClose(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            println("dismissed schedule view")
            NSNotificationCenter.defaultCenter().postNotificationName(HistoryItemsDidChangeNotifications, object: self)
        })
    }
    @IBAction func onTapDatePicker(sender: AnyObject) {
        self.view.layoutIfNeeded()
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            //self.datePickerHeightConstraint.constant = self.pickerOpen ? 0 : DATE_PICKER_HEIGHT\
            self.pickerOpen = !self.pickerOpen
            let height = self.pickerOpen ? DATE_PICKER_HEIGHT : 0
            self.datePickerView.frame = CGRectMake(marginLeftRight, self.datePickerView.frame.origin.y, self.contentContainerView.bounds.width - marginLeftRight * 2, height)
        
            if self.pickerOpen {
                self.calendarView?.frame = CGRectMake(0, 15, self.datePickerView.bounds.width, self.datePickerView.bounds.height-15)
            }
            else {
                self.calendarView?.frame = CGRectMake(0, 0, self.datePickerView.bounds.width, 1)
            }
            
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
        
        calendarView.highlightColor = blueHighlight
        calendarView.indicatorColor = blueHighlight
        
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
    
    override func viewWillLayoutSubviews() {
        let bounds = self.view.bounds
        
        blurView.frame = bounds
        contentContainerView.frame = CGRectMake(marginLeftRight, marginTopBottom, bounds.width - marginLeftRight * 2, bounds.height - marginTopBottom * 3)
        schedulePickupView.frame = contentContainerView.bounds
        schedulePickupView.alpha = 0
        editAddressView.frame = contentContainerView.bounds

        // Layout elements within the content container view
        var yOffset: CGFloat = 20
        titleLabel.frame = CGRectMake(marginLeftRight, yOffset, schedulePickupView.bounds.width - marginLeftRight * 2, 40)
        yOffset += titleLabel.frame.height + TEXT_MARGIN
        dateFieldLabel.frame = CGRectMake(marginLeftRight, yOffset, schedulePickupView.bounds.width - marginLeftRight * 2, 20)
        yOffset += dateFieldLabel.frame.height
        datePickerButton.frame = CGRectMake(marginLeftRight, yOffset, schedulePickupView.bounds.width - marginLeftRight * 2, 40)
        yOffset += datePickerButton.frame.height
        let height = pickerOpen ? DATE_PICKER_HEIGHT : 0
        datePickerView.frame = CGRectMake(marginLeftRight, yOffset, schedulePickupView.bounds.width - marginLeftRight * 2, height)
        
        yOffset += 30
        slotPickerView.frame = CGRectMake(marginLeftRight, yOffset, schedulePickupView.bounds.width - marginLeftRight * 2, DATE_PICKER_HEIGHT)
        
        yOffset = schedulePickupView.bounds.height - 40 - 30
        scheduleButton.frame = CGRectMake((schedulePickupView.bounds.width-180)/2, yOffset, 180, 40)

        yOffset = self.view.bounds.height - 20 - 40
        closeButton.frame = CGRectMake((self.view.bounds.width-40)/2, yOffset, 40, 40)
        
        println("view will layout subviews slot picker view: \(self.slotPickerView.frame)")
    }
    
    override func viewDidLayoutSubviews() {
        println("view did layout subviews date picker bounds: \(datePickerView.bounds)")
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
        selectedSlot = slot
        scheduleButton.setButtonColor(blueHighlight)
    }
    @IBAction func confirmSchedule(sender: AnyObject) {
        if (selectedSlot != nil) {
            if let donationItems = self.itemsGroup?.sortedDonationItems {
                selectedSlot!.grabSlot(donationItems)
            }
            onTapClose(sender)
        }
        else {
            println("must first select a slot before confirming")
        }
    }
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // Edit Address View delegate
    func onTapDone(address: Address) {
        let frame = self.editAddressView.frame
        schedulePickupView.frame = CGRectMake(frame.origin.x + self.view.frame.width, frame.origin.y, frame.width, frame.height)
        UIView.animateWithDuration(0.4, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            self.schedulePickupView.frame = frame
            self.editAddressView.frame = CGRectMake(frame.origin.x - self.view.frame.width, frame.origin.y, frame.width, frame.height)
            
            self.editAddressView.alpha = 0
            self.schedulePickupView.alpha = 1

        }) { (finished) -> Void in
            println("animation completed")
        }
        address.saveEventually()
    }
}

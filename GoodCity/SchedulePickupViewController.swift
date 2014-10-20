//
//  SchedulePickupViewController.swift
//  GoodCity
//
//  Created by Nick Aiwazian on 10/5/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

let DATE_PICKER_HEIGHT = CGFloat(280)

enum Slots : Int {
    case Nine = 0, Ten, Eleven, Twelve, Thirteen, Forteen, Fifteen, Sixteen
    
    func getHour() -> Int {
        switch self {
        case .Nine:
            return 9
        case .Ten:
            return 10
        case .Eleven:
            return 11
        case .Twelve:
            return 12
        case .Thirteen:
            return 13
        case .Forteen:
            return 14
        case .Fifteen:
            return 15
        case .Sixteen:
            return 16
        }
    }
}

class SchedulePickupViewController: UIViewController, MDCalendarDelegate {

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var datePickerButton: DatePickerButton!
    @IBOutlet weak var datePickerView: UIView!
    @IBOutlet weak var datePickerHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var slotButton0: SelectableButton!
    @IBOutlet weak var slotButton1: SelectableButton!
    @IBOutlet weak var slotButton2: SelectableButton!
    @IBOutlet weak var slotButton3: SelectableButton!
    @IBOutlet weak var slotButton4: SelectableButton!
    @IBOutlet weak var slotButton5: SelectableButton!
    @IBOutlet weak var slotButton6: SelectableButton!
    @IBOutlet weak var slotButton7: SelectableButton!
    var slotButtons : [SelectableButton]!
    
    var pickerOpen = false
    var calendarView: MDCalendar?
    var days = NSSet()
    var slots: [PickupScheduleSlot]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = LIGHT_GRAY_BG
        
        closeButton.setImage(UIImage(named: "edit_close").imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: .Normal)
        closeButton.tintColor = tintColor
        
        // Add all the slot buttons to the array
        slotButtons = [slotButton0, slotButton1, slotButton2, slotButton3, slotButton4, slotButton5, slotButton6, slotButton7]
        slotButton0.slotHour = 9
        slotButton1.slotHour = 10
        slotButton2.slotHour = 11
        slotButton3.slotHour = 12
        slotButton4.slotHour = 13
        slotButton5.slotHour = 14
        slotButton6.slotHour = 15
        slotButton7.slotHour = 16
        
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
                        //let slotsForDay = PickupScheduleSlot.getAvailableSlotsForDay(days[2], slots: slots)
                        //println("Slots for day \(days[2].dateStringWithTimeTruncated()): \(slotsForDay)")
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
        self.datePickerButton.datePicked = date
        onTapDatePicker(self)
        
        // reset all the buttons to disabled
        for slotButton in slotButtons {
            slotButton.slotDisabled = true
        }
        
        if (slots != nil) {
            let slotsForDay = PickupScheduleSlot.getAvailableSlotsForDay(date, slots: slots!)
            for slot in slotsForDay {
                
                let index = slot - 9
                if (index >= 0 && index < 8) {
                    slotButtons[index].slotDisabled = false
                }
                //println(slot)
            }
            println("Slots for day \(date): \(slotsForDay)")
        }
    }

    func calendarView(calendarView: MDCalendar!, shouldShowIndicatorForDate date: NSDate!) -> Bool {
        return self.days.containsObject(date.dateWithTimeTruncated())
    }
}

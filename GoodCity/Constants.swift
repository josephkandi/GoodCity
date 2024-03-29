//
//  Constants.swift
//  GoodCity
//
//  Created by Yili Aiwazian on 10/12/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import Foundation

let TOTAL_DONATION_COUNT_KEY = "total_donation_count"
let MEMBER_SINCE_KEY = "member_since"
let NEXT_SCHEDULE_PICKUP_KEY = "next_schedule_pickup"
let NUMBER_ITEMS_NEXT_PICKUP_KEY = "number_items_next_pickup"
let LOGGED_IN_AS_VOLUNTEER_KEY = "logged_in_as_volunteer"


let ROUNDED_CORNER = CGFloat(4)
let SPACING = CGFloat(5)
let BUTTON_SPACING = CGFloat(8)
let BUTTON_HEIGHT = CGFloat(40)
let SECTION_HEADER_HEIGHT = CGFloat(36)

let DONATION_LEVEL_COUNT = 25

let FONT_8 = UIFont(name: "Avenir Next", size: 8.0)
let FONT_12 = UIFont(name: "Avenir Next", size: 12.0)
let FONT_14 = UIFont(name: "Avenir Next", size: 14.0)
let FONT_15 = UIFont(name: "Avenir Next", size: 15.0)
let FONT_16 = UIFont(name: "Avenir Next", size: 16.0)
let FONT_18 = UIFont(name: "Avenir Next", size: 18.0)
let FONT_MEDIUM_12 = UIFont(name: "AvenirNext-Medium", size: 12.0)
let FONT_MEDIUM_14 = UIFont(name: "AvenirNext-Medium", size: 14.0)
let FONT_MEDIUM_16 = UIFont(name: "AvenirNext-Medium", size: 16.0)
let FONT_MEDIUM_17 = UIFont(name: "AvenirNext-Medium", size: 17.0)
let FONT_MEDIUM_18 = UIFont(name: "AvenirNext-Medium", size: 18.0)
let FONT_MEDIUM_20 = UIFont(name: "AvenirNext-Medium", size: 20.0)
let FONT_BOLD_14 = UIFont(name: "AvenirNext-Bold", size: 14.0)
let FONT_BOLD_15 = UIFont(name: "AvenirNext-Bold", size: 15.0)
let FONT_BOLD_18 = UIFont(name: "AvenirNext-Bold", size: 18.0)

// Colors
let LIGHT_GRAY_BG = UIColorFromRGB(0xe7e7e7)
let GRAY_TEXT = UIColorFromRGB(0x9B9B9B)
//let FB_BLUE = UIColor(red: 0.278, green: 0.3843, blue: 0.6078, alpha: 1.0)
let FB_BLUE = UIColorFromRGB(0x153f77)
let DARK_GRAY = UIColor(white: 0.25, alpha: 1.0)
let HEADER_COLOR = UIColor(white: 0.25, alpha: 0.9)
let blueHighlight = UIColorFromRGB(0x03b7e7)
let offWhiteColor = UIColorFromRGB(0xf5f5f5)
let yellowHighlight = UIColorFromRGB(0xfcc82f)
let greenHighlight = UIColorFromRGB(0x67993c)
let pinkHighlight = UIColorFromRGB(0xcb398d)
let redHighlight = UIColorFromRGB(0xe24d52)
let orangeHighlight = UIColorFromRGB(0xfc6621)
let NAV_BAR_COLOR = blueHighlight


// Date Formatter
private var friendlyDateFormatter: NSDateFormatter?
private var friendlyDateFormatterWithTime: NSDateFormatter?
private var friendlyShortDateFormatter: NSDateFormatter?
private var friendlyShortDateFormatterWithTime: NSDateFormatter?
private var monthYearDateFormatter: NSDateFormatter?

func getMonthYearDateFormatter() -> NSDateFormatter {
    if monthYearDateFormatter == nil {
        monthYearDateFormatter = NSDateFormatter()
        monthYearDateFormatter!.dateFormat = "MMM YYYY"
    }
    return monthYearDateFormatter!
}

func getFriendlyDateFormatter() -> NSDateFormatter {
    if friendlyDateFormatter == nil {
        friendlyDateFormatter = NSDateFormatter()
        friendlyDateFormatter!.dateFormat = "EEE, MMMM dd, yyyy"
    }
    return friendlyDateFormatter!
}

func getFriendlyShortDateFormatter() -> NSDateFormatter {
    if friendlyShortDateFormatter == nil {
        friendlyShortDateFormatter = NSDateFormatter()
        friendlyShortDateFormatter!.dateFormat = "MMM dd"
    }
    return friendlyShortDateFormatter!
}

func getFriendlyShortDateFormatterWithTime() -> NSDateFormatter {
    if friendlyShortDateFormatterWithTime == nil {
        friendlyShortDateFormatterWithTime = NSDateFormatter()
        friendlyShortDateFormatterWithTime!.dateFormat = "MMM dd 'at' h a"
    }
    return friendlyShortDateFormatterWithTime!
}

func getFriendlyDateFormatterWithTime() -> NSDateFormatter {
    if friendlyDateFormatterWithTime == nil {
        friendlyDateFormatterWithTime = NSDateFormatter()
        friendlyDateFormatterWithTime!.dateFormat = "EEE, MMM dd 'at' h a"
    }
    return friendlyDateFormatterWithTime!
}

// Helper function
func UIColorFromRGB(rgbValue: UInt) -> UIColor {
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}
//
//  Constants.swift
//  GoodCity
//
//  Created by Yili Aiwazian on 10/12/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import Foundation

let ROUNDED_CORNER = CGFloat(4)
let SPACING = CGFloat(5)
let BUTTON_SPACING = CGFloat(8)
let BUTTON_HEIGHT = CGFloat(40)
let SECTION_HEADER_HEIGHT = CGFloat(36)

let FONT_14 = UIFont(name: "Avenir Next", size: 14.0)
let FONT_15 = UIFont(name: "Avenir Next", size: 15.0)
let FONT_18 = UIFont(name: "Avenir Next", size: 18.0)
let FONT_MEDIUM_12 = UIFont(name: "AvenirNext-Medium", size: 12.0)
let FONT_MEDIUM_14 = UIFont(name: "AvenirNext-Medium", size: 14.0)
let FONT_MEDIUM_20 = UIFont(name: "AvenirNext-Medium", size: 20.0)
let FONT_BOLD_14 = UIFont(name: "AvenirNext-Bold", size: 14.0)
let FONT_BOLD_18 = UIFont(name: "AvenirNext-Bold", size: 18.0)

// Colors
let LIGHT_GRAY_BG = UIColorFromRGB(0xe1e1e1)
let GRAY_TEXT = UIColorFromRGB(0x9B9B9B)
let FB_BLUE = UIColor(red: 0.278, green: 0.3843, blue: 0.6078, alpha: 1.0)
let DARK_GRAY = UIColor(white: 0.25, alpha: 1.0)
let BLUE_TEAL = UIColorFromRGB(0x03b7e7)
let NAV_BAR_COLOR = BLUE_TEAL
let HEADER_COLOR = UIColor(white: 0.25, alpha: 0.9)
let tintColor = BLUE_TEAL
let offWhiteColor = UIColorFromRGB(0xf5f5f5)
let yellowHighlight = UIColorFromRGB(0xfcc82f)
let greenHighlight = UIColorFromRGB(0x67993c)
let pinkHighlight = UIColorFromRGB(0xcb398d)


// Date Formatter
private var friendlyDateFormatter: NSDateFormatter?
private var friendlyShortDateFormatter: NSDateFormatter?

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

// Helper function
func UIColorFromRGB(rgbValue: UInt) -> UIColor {
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}
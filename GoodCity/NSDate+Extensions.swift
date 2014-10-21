//
//  NSDate+Extensions.swift
//  TweetiePie
//
//  Created by Nick Aiwazian on 9/27/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import Foundation

extension NSDate {
    
    // Returns a date formatted for display showing time elapsed since now
    func prettyTimestampSinceNow() -> String {
        
        let deltaSeconds = -self.timeIntervalSinceNow
        if deltaSeconds < 10 {
            return "Now"
        }
        if deltaSeconds < 60 {
            return "\(Int(deltaSeconds))s"
        }
        
        let deltaMins = deltaSeconds / 60
        if deltaMins < 60 {
            return "\(Int(deltaMins))m"
        }
        
        let deltaHours = deltaMins / 60
        if deltaHours < 24 {
            return "\(Int(deltaHours))h"
        }
        
        let deltaDays = deltaMins / 24
        if deltaDays < 7 {
            return "\(Int(deltaDays))d"
        }
        
        // More than 7 days ago
        let calendar = NSCalendar.currentCalendar()
        
        let now = NSDate()
        let componentFlags = NSCalendarUnit.YearCalendarUnit
        
        let nowComponents = calendar.components(componentFlags, fromDate: now)
        let selfComponents = calendar.components(componentFlags, fromDate: self)
        
        var formatter = NSDateFormatter()
        
        // If current year, return "7 Jun" format
        if (selfComponents.year == nowComponents.year) {
            formatter.dateFormat = "d MMM"
        } else { // Not the current year, return "7 Jun 2012" format
            formatter.dateFormat = "d MMM yyyy"
        }
        
        return formatter.stringFromDate(self)
    }

    func dateWithTimeTruncated() -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.YearCalendarUnit | .MonthCalendarUnit | .DayCalendarUnit, fromDate: self)
        components.timeZone = NSTimeZone(name: "PST")
        return calendar.dateFromComponents(components)!
    }

    func dateStringWithTimeTruncated() -> String {
        let format = NSDateFormatter()
        format.dateFormat = "MM-dd-YYYY"
        format.timeZone = NSTimeZone(name: "PST")
        return format.stringFromDate(self)
    }

    func hour() -> Int {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.HourCalendarUnit, fromDate: self)
        return components.hour
    }
}

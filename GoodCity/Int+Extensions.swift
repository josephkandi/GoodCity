//
//  Int+Extensions.swift
//  TweetiePie
//
//  Created by Nick Aiwazian on 9/27/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import Foundation

extension Int {
    
    // Returns an Int formatted for display that rolls up large numbers to the format "1.4k"
    func formattedForDisplay() -> String {
        var result = "0"
        
        if self <= 0 {
            return "0"
        } else if (self < 1000) {
            return String(self)
        } else if (self < 9500) {
            result = NSString(format:"%.1fk", Double(self) / 1000.0)
        } else { // Chop off decimal if display will be >= 10k
            result = NSString(format:"%.0fK", Double(self) / 1000.0)
        }
        return result
    }
    
}
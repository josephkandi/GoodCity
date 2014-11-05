//
//  Double+Extensions.swift
//  GoodCity
//
//  Created by Nick Aiwazian on 11/1/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import Foundation

extension Double {

    static func degreesToRadians (value:Double) -> Double {
        return value * M_PI / 180.0
    }

    static func radiansToDegrees (value:Double) -> Double {
        return value * 180.0 / M_PI
    }

    static func preserveSignMod(a: Double, _ b: Double) -> Double {
        return (a % b + b) % b
    }

    static func angleDiff(angle1: Double, _ angle2: Double) -> Double {
        var diff = angle1 - angle2
        diff = Double.preserveSignMod(diff + 180, 360) - 180

        return diff
    }
}
//
//  ItemState.swift
//  GoodCity
//
//  Created by Nick Aiwazian on 10/11/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import Foundation

enum ItemState: String {
    case
    Draft = "Draft",
    Pending = "Pending",
    Approved = "Approved",
    MoreInfoNeeded = "More information needed",
    NotNeeded = "Not needed",
    Scheduled = "Scheduled",
    PickedUp = "Picked up"

    func getSortValue() -> Int {
        switch self {
        case .Draft:
            return 0
        case .Pending:
            return 1
        case .PickedUp:
            return 2
        case .NotNeeded:
            return 3
        case .MoreInfoNeeded:
            return 4
        case .Approved:
            return 5
        case .Scheduled:
            return 6
        default:
            println("Uknown sort value in ItemState")
            return 7
        }
    }

    func getItemStateKey() -> String {
        if self == NotNeeded || self == PickedUp {
            return "Done"
        } else {
            return self.rawValue
        }
    }
}
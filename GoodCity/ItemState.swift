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
    Pending = "Pending",
    Approved = "Approved",
    MoreInfoNeeded = "More information needed",
    NotNeeded = "Not needed",
    Scheduled = "Scheduled",
    PickedUp = "Picked up"

    func getSortValue() -> Int {
        switch self {
        case .Pending:
            return 0
        case .PickedUp:
            return 1
        case .NotNeeded:
            return 2
        case .MoreInfoNeeded:
            return 3
        case .Approved:
            return 4
        case .Scheduled:
            return 5
        default:
            println("Uknown sort value in ItemState")
            return 7
        }
    }
}
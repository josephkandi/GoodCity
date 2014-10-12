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
}
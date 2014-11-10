//
//  DonationItemsAggregator.swift
//  GoodCity
//
//  Created by Nick Aiwazian on 10/18/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import Foundation


class DonationItemsAggregator {
    var sortedSections = [Section]() // Sorted by ItemState enum

    private var sectionsByState = [String: Section]()

    init(donationItems: [DonationItem]) {

        // Build up data structures
        for donationItem in donationItems {
            let key = ItemState(rawValue: donationItem.state)?.getItemStateKey()
            if let section = sectionsByState[key!] {
                section.addNewDonationItem(donationItem)
            } else {
                sectionsByState[key!] = Section(donationItem: donationItem)
            }
        }

        // Sort results
        sortedSections = sectionsByState.values.array
        sortedSections.sort { (item1, item2) -> Bool in
            let itemState1 = ItemState(rawValue: item1.name)
            let itemState2 = ItemState(rawValue: item2.name)

            return itemState1!.getSortValue() > itemState2!.getSortValue()
        }

        for section in sortedSections {
            section.sort()
        }
    }

    class Section {
        var name: String // i.e. Approved
        var sortedDonationGroups = [DonationGroup]() // Sorted by date

        private var donationGroupsByDate = [String: DonationGroup]()

        init(donationItem: DonationItem) {
            self.name = ItemState(rawValue: donationItem.state)?.getItemStateKey() ?? ""

            let donationGroup = DonationGroup(donationItem: donationItem)
            let key = donationItem.submittedAt.dateStringWithTimeTruncated()
            self.donationGroupsByDate[key] = donationGroup
        }

        func addNewDonationItem(donationItem: DonationItem) {
            let key = donationItem.submittedAt.dateStringWithTimeTruncated()

            if let donationGroup = donationGroupsByDate[key] {
                donationGroup.addNewDonationItem(donationItem)
            } else {
                donationGroupsByDate[key] = DonationGroup(donationItem: donationItem)
            }
        }

        func sort() {
            self.sortedDonationGroups = sorted(donationGroupsByDate.values.array) {
                $0.originalDate.compare($1.originalDate) == NSComparisonResult.OrderedDescending }
            for donationGroup in sortedDonationGroups {
                donationGroup.sort()
            }
        }
        
        func numberOfItems() -> Int {
            return sortedDonationGroups.count
        }
    }

     class DonationGroup {
        var name: String // i.e. 09/12/2014
        var sortedDonationItems = [DonationItem]() // Sorted by submittedAt
        var originalDate: NSDate
        var pickupDate: NSDate
        private var donationItems = [DonationItem]()

        init(donationItem: DonationItem) {
            self.name = donationItem.submittedAt.dateStringWithTimeTruncated()
            self.originalDate = donationItem.submittedAt
            self.pickupDate = donationItem.pickupScheduledAt
            self.donationItems.append(donationItem)
        }

        func addNewDonationItem(donationItem: DonationItem) {
            self.donationItems.append(donationItem)
        }

        func sort() {
            self.sortedDonationItems = sorted(donationItems) {
                $0.submittedAt.compare($1.submittedAt) == NSComparisonResult.OrderedDescending }
        }
    }
}
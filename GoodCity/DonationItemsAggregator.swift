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
            let key = donationItem.state
            if let section = sectionsByState[key] {
                section.addNewDonationItem(donationItem)
            } else {
                sectionsByState[key] = Section(donationItem: donationItem)
            }
        }

        // Sort results
        sortedSections = sectionsByState.values.array
        sortedSections.sort { (item1, item2) -> Bool in
            let itemState1 = ItemState.fromRaw(item1.name)
            let itemState2 = ItemState.fromRaw(item2.name)

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
            self.name = donationItem.state

            let donationGroup = DonationGroup(donationItem: donationItem)
            let key = donationItem.createdAt.description
            self.donationGroupsByDate[key] = donationGroup
        }

        func addNewDonationItem(donationItem: DonationItem) {
            let key = donationItem.createdAt.description

            if let donationGroup = donationGroupsByDate[key] {
                donationGroup.addNewDonationItem(donationItem)
            } else {
                donationGroupsByDate[key] = DonationGroup(donationItem: donationItem)
            }
        }

        func sort() {
            self.sortedDonationGroups = sorted(donationGroupsByDate.values.array) {
                $0.originalDate.compare($1.originalDate) == NSComparisonResult.OrderedAscending }
            for donationGroup in sortedDonationGroups {
                donationGroup.sort()
            }
        }
    }

     class DonationGroup {
        var name: String // i.e. 09/12/2014
        var sortedDonationItems = [DonationItem]() // Sorted by createdAt
        var originalDate: NSDate
        private var donationItems = [DonationItem]()

        init(donationItem: DonationItem) {
            self.name = donationItem.createdAt.dateStringWithTimeTruncated()
            self.originalDate = donationItem.createdAt
            self.donationItems.append(donationItem)
        }

        func addNewDonationItem(donationItem: DonationItem) {
            self.donationItems.append(donationItem)
        }

        func sort() {
            self.sortedDonationItems = sorted(donationItems) {
                $0.createdAt.compare($1.createdAt) == NSComparisonResult.OrderedAscending }
        }
    }
}
//
//  EventManager.swift
//  GoodCity
//
//  Created by Yili Aiwazian on 11/5/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import Foundation
import EventKit

private let sharedLocationManager = EventManager()

class EventManager: NSObject {
    
    class var sharedInstance : EventManager {
        struct Static {
            static let instance = EventManager()
        }
        return Static.instance
    }
    
    var eventStore: EKEventStore!
    var eventsAccessGranted: Bool!
    
    override init() {
        super.init()
        self.eventStore = EKEventStore()
    }
    
    func requestAccessToEvents() {
        self.eventStore.requestAccessToEntityType(EKEntityTypeEvent, completion: { (granted, error) -> Void in
            if (error == nil) {
                println("permission granted for calendar")
            }
            else {
                println("permission not granted for calendar")
            }
        })
    }
    
    func addEventToCalendar(timeSlot: PickupScheduleSlot) {
        self.eventStore.requestAccessToEntityType(EKEntityTypeEvent, completion: { (granted, error) -> Void in
            if (granted) {
                println("permission granted for calendar")
                let event = EKEvent(eventStore: self.eventStore)
                event.title = "GoodCity Donation Pickup"
                event.notes = "Scheduled pickup confirmed for " +  getFriendlyDateFormatterWithTime().stringFromDate(timeSlot.startDateTime)
                event.startDate = timeSlot.startDateTime
                event.endDate = event.startDate.dateByAddingTimeInterval(60*60)
                event.calendar = self.eventStore.defaultCalendarForNewEvents
                var err: NSError? = nil
                self.eventStore.saveEvent(event, span: EKSpanThisEvent, commit: true, error: &err)
                println(event.eventIdentifier)
                
            }
            else {
                println("permission not granted for calendar")
                return
            }
        })
    }
}
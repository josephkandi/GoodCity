//
//  ReviewComplete
//  GoodCity
//
//  Created by Nick Aiwazian on 11/9/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import Foundation

class ReviewComplete : PFObject, PFSubclassing {
    @NSManaged var reviews: Int

    // Must be called before Parse is initialized
    override class func load() {
        registerSubclass()
    }

    class func parseClassName() -> String! {
        return "ReviewComplete"
    }

    func description() -> String {
        return "\(self.reviews)"
    }

    class func sendReviewCompletePushNotifs() {
        var query = ReviewComplete.query()
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error != nil {
                println("Error trying to get ReviewComplete object: \(error)")
            } else {
                if objects.count > 0 {
                    if let row = objects[0] as? ReviewComplete {
                        row.incrementKey("reviews", byAmount: 1)
                        println("Triggering push notifs")
                    }
                }
            }
        }
        
    }
}
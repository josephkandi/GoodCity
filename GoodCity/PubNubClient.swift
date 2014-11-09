import Foundation

let PUB_NUB_PUBLISH_KEY = "pub-c-154b8726-8ec4-494a-a275-7552fe71ec14"
let PUB_NUB_SUBSCRIBE_KEY = "sub-c-91ed8d4c-625e-11e4-8dc6-02ee2ddab7fe"
let PUB_NUB_SECRET_KEY = "sec-c-ODVhYzFhMTAtNmQ0OC00MmZkLThmZGItZDc2MTIyODM4ZGNj"
let HEADING_CHANNEL = "heading_channel"

let DriverLocationDidChangeNotification = "driver_location_did_change"

private let pubNubClientSharedInstance = PubNubClient()

class PubNubClient: NSObject {

    // Shared Parse Client instance
    class var sharedInstance : PubNubClient {
        struct Static {
            static let instance = PubNubClient()
        }
        return Static.instance
    }

    private var publishChannel: PNChannel?

    func getPublishChannelName() -> String? {
        if (GoodCityUser.currentUser() != nil) {
            return GoodCityUser.currentUser().username
        } else {
            return nil
        }
    }

    func subscribeToChannel(channelName: String) {
        PubNub.subscribeOnChannel(PNChannel.channelWithName(channelName, shouldObservePresence: true) as PNChannel)

        /*

        if !isConnected {
            PubNub.connectWithSuccessBlock({ (origin) -> Void in
                println("Pubnub client connected to \(origin)")
                let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC))
                dispatch_after(popTime, dispatch_get_main_queue(), { () -> Void in
                    PubNub.subscribeOnChannel(PNChannel.channelWithName(channelName, shouldObservePresence: true) as PNChannel)
                });
                }, errorBlock: { (error) -> Void in
                    println("Connection failed: \(error.localizedDescription)")
            });
        }
        */
    }

    func publishHeadingToChannel(heading: CLHeading) {
        if getPublishChannelName() == nil {
            return
        }

        if publishChannel == nil {
            publishChannel = PNChannel.channelWithName(getPublishChannelName()) as? PNChannel
        }
        var message = ["heading": heading.trueHeading]
        //println("Sending heading update: heading:\(heading)")
        PubNub.sendMessage(message, toChannel: publishChannel)
    }

    func publishLocationToChannel(lat: Double, _ lng: Double) {
        if getPublishChannelName() == nil {
            return
        }

        if publishChannel == nil {
            publishChannel = PNChannel.channelWithName(getPublishChannelName()) as? PNChannel
        }

        var loc = ["lat": lat, "lng": lng]
        var message = ["loc": loc]
        //println("Sending location update: lat:\(lat) lng:\(lng)")
        PubNub.sendMessage(message, toChannel: publishChannel)
    }
}
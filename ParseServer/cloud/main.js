
var _scheduleSlotKey = "claimedCount";
var _claimedCountMax = 1; // Max amount of people that can grab a slot


Parse.Cloud.afterSave("ReviewComplete", function(request) {
  var userQuery = new Parse.Query("User");
  var promises = [];
  userQuery.find().then(function(users) {
    var promise = Parse.Promise.as();
    for (var i = 0; i < users.length; i++) {
      var notifQuery = new Parse.Query("DonationItem");
      notifQuery.equalTo("state", "Approved");
      notifQuery.equalTo("user", users[i]);

      var pushQuery = new Parse.Query(Parse.Installation);
      pushQuery.equalTo("deviceType", "ios");
      pushQuery.equalTo("owner", users[i]);
      promises.push(maybeNotifyUser(notifQuery, pushQuery));
    }
    return Parse.Promise.when(promises);
  }).then(function() {
    console.log("All push notifications sent!");
  });
});


Parse.Cloud.afterSave("DriverOnTheWay", function(request) {
  var userQuery = new Parse.Query("User");
  var promises = [];
  userQuery.find().then(function(users) {
    var promise = Parse.Promise.as();
    for (var i = 0; i < users.length; i++) {
      var notifQuery = new Parse.Query("DonationItem");
      notifQuery.equalTo("state", "On the way");
      notifQuery.equalTo("user", users[i]);

      var pushQuery = new Parse.Query(Parse.Installation);
      pushQuery.equalTo("deviceType", "ios");
      pushQuery.equalTo("owner", users[i]);
      promises.push(maybeSendDriverNotification(notifQuery, pushQuery, users[i].get("username")));
    }
    return Parse.Promise.when(promises);
  }).then(function() {
    console.log("All push notifications sent!");
  });
});


function maybeSendDriverNotification(notifQuery, pushQuery, driverObjectId) {
  notifQuery.count().then(function(countOfOnTheWayItems) {
    if (countOfOnTheWayItems > 0) {
      console.log("count of on the way items: " + countOfOnTheWayItems);
      Parse.Push.send({
        where: pushQuery,
        data: {
          alert: "Your driver is on the way!",
          driver: driverObjectId,
          vc: "historyView"
        }
      }).then(function() {
        console.log("Sent a driver push notif");
      });
    }
  });
}


function maybeNotifyUser(notifQuery, pushQuery) {
  notifQuery.count().then(function(countOfApprovedItems) {
        if (countOfApprovedItems > 0) {
          console.log("count of approved items: " + countOfApprovedItems);
          Parse.Push.send({
            where: pushQuery, // Set our Installation query
            data: {
              alert: "Your donation is approved!",
              badge: countOfApprovedItems,
              category: "DONATION_APPROVED_CATEGORY"
            }
          }).then(function() {
            console.log("Sent an items approved push notif");
          });
        }
  });
}


Parse.Cloud.define("getDonationStats", function(request, response) {
  var stats = {};
  var userQuery = new Parse.Query(Parse.User);
  userQuery.equalTo("objectId", request.params.userId);
  userQuery.first({
    success: function(result) {
      stats["user"] = result;

      var query = new Parse.Query("DonationItem");
      query.include("user");
      query.equalTo("user", result);
      query.containedIn("state", ["Picked up", "Approved", "Scheduled", "Notified", "On the way"]);
      query.find({
        success: function (results) {
          var sum = 0;
          var count = results.length;
          if (count == null) {
            count = 0;
          }
          for (var i = 0; i < count; i++) {
            var value = results[i].get("value");
            if (value != null) {
              sum += value;
            }
          }

          stats["totalDonationsCount"] = count;
          stats["totalDonationsValue"] = sum;
          response.success(stats);
        },
        error: function () {
          response.failure("DonationItem query failed");
        }
      });
    },
    error: function() {
      response.failure("Unable to find user");
    }
  });  
});


Parse.Cloud.define("grabPickupScheduleSlot", function(request, response) {
  var query = new Parse.Query("PickupScheduleSlot");
  query.equalTo("objectId", request.params.objectId);
  query.equalTo(_scheduleSlotKey, 0);
  query.find({
    success: function(results) {
      if (results.length == 0) {
        response.failure("Slot is already claimed");
      } else if (results.length > 1) {
        response.failure("Too many slots returned for query");
      } else {
        // Found the requested slot and it is currently still available
        results[0].increment(_scheduleSlotKey);
        results[0].save(null, {
          success: function(updatedScheduleSlot) {
            // Check if we got the slot
            if (updatedScheduleSlot.get(_scheduleSlotKey) <= _claimedCountMax) {
              // got the slot...update all items to "scheduled"
              var items = request.params.donationItemIds;
              var itemQuery = new Parse.Query("DonationItem");
              itemQuery.containedIn("objectId", items);
              itemQuery.find({
                success: function (donationItems) {
                  for (var j = 0; j < donationItems.length; j++) {
                    donationItems[j].set("state", "Scheduled");
                    donationItems[j].set("pickupScheduledAt", results[0].get("startDateTime"));
                  }
                  Parse.Object.saveAll(donationItems, {
                    success: function (savedItems) {
                      console.log("saving the following items:");
                      console.log(savedItems);
                      var jsonResponse = {};
                      jsonResponse["countOfItems"] = donationItems.length;
                      response.success(jsonResponse);
                    },
                    error: function(error) {
                      response.failure("Failure saving the updated items");
                    }
                  });
                },
                error: function() {
                  response.failure("Could not find donationItem with specified Id");
                }
              });
            } else {
              response.failure("Slot claimed by someone else at the last second");
            }
          },
          error: function() {
            response.failure("Error trying to increment claimedCount");
          }
        });
      }
    },
    error: function() {
      response.failure("Failure trying to query available schedule slots");
    }
  });
});

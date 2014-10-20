
var _scheduleSlotKey = "claimedCount";
var _claimedCountMax = 2; // Max amount of people that can grab a slot

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
              response.success("Slot claimed!");
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

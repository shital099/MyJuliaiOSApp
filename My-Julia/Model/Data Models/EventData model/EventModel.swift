//
//  EventModel.swift
//  My-Julia
//
//  Created by GCO on 09/03/2018.
//  Copyright © 2018 GCO. All rights reserved.
//

import UIKit

class EventModel: NSObject {
    
    var auth_token : String = ""

    //Event data
    var eventId : String = ""
    var eventCode : String = ""
    var eventName : String = ""
    var eventType : String = ""
    var eventLogoUrl : String = ""
    var eventCoverImageUrl : String = ""
    var eventStartDate : String = ""
    var eventEndDate : String = ""
    var eventVenue : String = ""
    var eventDescription : String = ""
    var eventCoverImage : UIImage!
    var attendeeId : String = ""
    var attendeeCode : String = ""
    var attendeeStatus : Bool = false

}

//
//  EventData.swift
//  EventApp
//
//  Created by GCO on 5/5/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit

class EventData: NSObject {
    
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


    // Can't init is singleton
    private override init() {
        
    }
    
    //MARK: Shared Instance
    
    static let sharedInstance: EventData = EventData()

    func resetEventDetails()  {
        eventId = ""
        eventCode = ""
        eventName = ""
        eventLogoUrl = ""
        eventCoverImageUrl = ""
        eventStartDate = ""
        eventDescription = ""
        eventCoverImage = nil
        attendeeId = ""
        attendeeCode = ""
    }
}

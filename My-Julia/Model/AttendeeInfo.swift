//
//  AttendeeInfo.swift
//  EventApp
//
//  Created by GCO on 8/2/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit

class AttendeeInfo: NSObject {

    var attendeeId : String = ""
    var speakerId : String = ""
    var attendeeName : String = ""
    var designation : String!
    var attendeeGroups : String = ""
    var eventId : String = ""
    var iconUrl : String = ""
    var group : String = ""
    var code : String = ""
    var email : String = ""
    var number : String = ""
    var qr_code : String = ""
    var isvisible : Bool = true
    var isDND : Bool = false
    var isSpeaker : Bool = false

    // Can't init is singleton
    private override init() {
        
    }
    
    //MARK: Shared Instance
    
    static let sharedInstance: AttendeeInfo = AttendeeInfo()

    func resetAttendeeDetails()  {
        eventId = ""
        attendeeId = ""
        attendeeName = ""
        designation = ""
        attendeeGroups = ""
        iconUrl = ""
        group = ""
        code = ""
        email = ""
        number = ""
        qr_code = ""
        isvisible = true
        isvisible = true

    }

}

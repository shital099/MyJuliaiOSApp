//
//  SessionsModel.swift
//  EventApp
//
//  Created by GCO on 8/24/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit

class SessionsModel: NSObject {
    
    var id : String = ""
    var eventId : String!

    var activitySessionId : String!
    var sessionId : String!
    var activityId : String!
    var day : String!
    var activityName : String!
    var agendaId : String!
    var agendaName : String!
    var location : String!
    var startTime : String!
    var endTime : String!
    var startActivityDate : String!
    var endActivityDate : String!
    var sortActivityDate : String!

    var isActive : Bool = false
}

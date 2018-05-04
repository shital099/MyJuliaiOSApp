//
//  AgendaModel.swift
//  My-Julia
//
//  Created by GCO on 5/11/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit

class AgendaModel: NSObject {
    
    var activitySessionId : String!
    var sessionId : String!
    var activityId : String!
    var activityName : String!
    var agendaId : String!
    var agendaName : String!
    var location : String!
    var descText: String!
    var startTime : String!
    var endTime : String!
    var speakerId : String!
    @objc var sortDate : String!
    var startActivityDate : String!
    var endActivityDate : String!
    var day : String!
    @objc var sortStartDate : String!
    @objc var sortEndDate : String!
    
    var isAddedToSchedule : Bool = false
    var activityStatus : Bool = false
    var isFutureActivity : Bool = false

    //Use for speaker details
    var isAgendaActivity : Bool = true

    var speakers : [PersonModel] = []  //Show speaker of agenda
}

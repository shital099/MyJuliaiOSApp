//
//  PollModel.swift
//  EventApp
//
//  Created by GCO on 23/05/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit

class PollModel: NSObject {
    
    var questionText : String!
    var eventId : String!
    var activityId : String!
    var answerText : String!
    var id : String!
    var isRatingType : Bool!
   var optionsArr : Array<Any> = []
    var optionValue : String!
    var optionOrder : String!
    var questionsId : String!
    var userAnswerId : String!
    var isUserAnswered : Bool!


    var actname : String!
    var opt1 : String!
    var op1Id : String!
    var opt2 : String!
    var opt2Id : String!
    var opt3 : String!
    var opt3Id : String!
    var opt4 : String!
    var opt4Id : String!
}

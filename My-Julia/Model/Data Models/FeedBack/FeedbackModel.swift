//
//  FeedbackModel.swift
//  EventApp
//
//  Created by GCO on 10/05/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit

class FeedbackModel: NSObject {

    var questionId : String!
    var questionText : String!
    //var optionText : Dictionary<String, Any> = [:]
    var answerText : String!
    var questionType : String!
    var optionsArr : Array<Any> = []
    var activityId : String!
    var eventId : String!
}

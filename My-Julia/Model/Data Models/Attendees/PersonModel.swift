//
//  AttedeeModel.swift
//  My-Julia
//
//  Created by GCO on 5/8/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit

class PersonModel: NSObject {
    
    @objc var name : String = ""
    var designation : String = ""
    var personId : String = ""
    var speakerId : String = ""
    var bioInfo : String = ""
    var iconUrl : String = ""
    var email : String = ""
    var contactNo : String = ""
    var address : String = ""
    var isSpeaker : Bool = false
    var activities : [AgendaModel] = []  //Show agenda's of speaker
    var isActiveSpeaker : Bool = false
    var privacySetting : Bool = false
    var dndSetting : Bool = false

}

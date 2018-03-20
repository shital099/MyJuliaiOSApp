//
//  EmailModel.swift
//  My-Julia
//
//  Created by GCO on 13/07/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit

class EmailModel: NSObject {

    var eId : String = ""
    var from : String = ""
    var to : String = ""
    var subject : String = ""
    var date : String = ""
    var content : String = ""
    var eTitle : String = ""
    var isPDF : Bool = false
    var attachments : NSArray = []
    var attendeeId : String = ""

}

//
//  Modules.swift
//  EventApp
//
//  Created by GCO on 5/25/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit

class Modules: NSObject {

    var index : Int = 0
    var moduleId : String = ""
    var name : String = ""
    var sIconUrl : String = ""
    var lIconUrl : String = ""
    var textColor : UIColor = UIColor(rgb: 0xFFFFFF)
    var isUserRelated : Bool = true
    var isCustomModule : Bool = false
    var moduleContent : String!
    var moduleSequence : Int = 0

}

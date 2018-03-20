//
//  Chat.swift
//  My-Julia
//
//  Created by GCO on 8/10/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit

class Message: NSObject {
    
    var id : String!
    var fromId : String!
    var fromName : String!
    var fromUserIcon : String!
    var toId : String!
    var toName : String!
    var toUserIcon : String!
    var message : String = ""
    var userIconUrl : String = ""
    var dateStr : String!
}

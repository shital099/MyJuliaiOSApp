//
//  ActivityFeedsModel.swift
//  My-Julia
//
//  Created by GCO on 5/4/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit

class ActivityFeedsModel: NSObject {

    var id : String = ""
    var userId : String = ""
    var userNameString : String = ""
    var userIconUrl : String = ""

    var postDateStr : String = ""
    var messageText : String = ""
    var postImageUrl : String = ""
    var commentsCount : String = ""
    var likesCount : String = ""
    
    var isUserLike : Bool = false
    var isImageDeleted : Bool = false
    var isRead : Bool = false

}

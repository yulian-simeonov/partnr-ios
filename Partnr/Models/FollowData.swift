//
//  CommentData.swift
//  Partnr
//
//  Created by Yosemite on 2/5/16.
//  Copyright © 2016 YulianMobile. All rights reserved.
//

import UIKit

import Parse

class FollowData {
    
    var id: String = ""
    var fromUserPointer: PFObject? = nil
    var toUserPointer: PFObject? = nil
    
    var fromUserData: UserData? = nil
    var toUserData: UserData? = nil
    
    class func initWithParseObject(parseObj: PFObject?) -> FollowData? {
        
        if (parseObj == nil) {
            return nil
        }
        let follow = FollowData()

        follow!.id = parseObj!.objectId!
        follow!.fromUserPointer = parseObj?.objectForKey("fromUser") as? PFObject
        follow!.toUserPointer = parseObj?.objectForKey("toUser") as? PFObject
        
        
        return follow
    }
    
    init?() {
        self.id = ""
    }
}

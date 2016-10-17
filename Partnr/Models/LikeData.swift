//
//  LikeData.swift
//  Partnr
//
//  Created by Yosemite on 2/7/16.
//  Copyright © 2016 YulianMobile. All rights reserved.
//

import UIKit

import Parse

class LikeData: NSObject {

    var id: String = ""
    var userName: String = ""
    var userId: String = ""
    
    class func initWithParseObject(parseObj: PFObject?) -> LikeData? {
        
        let like = LikeData()
        if (parseObj == nil) {
            return nil
        }
        like.id = parseObj!.objectId!
        like.userName = Utilities.getValidString(parseObj!["userName"] as? String, defaultString: "")
        like.userId = Utilities.getValidString(parseObj!["userId"] as? String, defaultString: "")
        return like
    }
}

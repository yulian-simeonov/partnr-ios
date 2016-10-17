//
//  CommentData.swift
//  Partnr
//
//  Created by Yosemite on 2/5/16.
//  Copyright © 2016 YulianMobile. All rights reserved.
//

import UIKit

import Parse

class ProjectCommentData {
    
    var id: String = ""
    var userName: String = ""
    var commentStr: String = ""
    var userId: String = ""
    var imageFile: PFFile? = nil
    
    class func initWithParseObject(parseObj: PFObject?) -> ProjectCommentData? {
        
        let user = ProjectCommentData()
        if (parseObj == nil) {
            return nil
        }
        user!.id = parseObj!.objectId!
        user!.userName = Utilities.getValidString(parseObj!["userName"] as? String, defaultString: "")
        user!.commentStr = Utilities.getValidString(parseObj!["commentStr"] as? String, defaultString: "")
        user!.userId = Utilities.getValidString(parseObj!["userId"] as? String, defaultString: "")
        if parseObj!["imageFile"] != nil {
            user!.imageFile = parseObj!["imageFile"] as? PFFile
        }
        
        return user
    }
    
    init?() {
        self.id = ""
    }
}

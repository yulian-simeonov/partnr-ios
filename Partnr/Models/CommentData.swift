//
//  CommentData.swift
//  Partnr
//
//  Created by Yulian Simeonov on 2/5/16.
//  Copyright © 2016 YulianMobile. All rights reserved.
//

import UIKit

import Parse

class CommentData {
    
    var id: String = ""
    var userName: String = ""
    var commentStr: String = ""
    var userId: String = ""
    
    var createdAt = NSDate()
    
    var userData: UserData? = nil
    
    class func initWithParseObject(parseObj: PFObject?) -> CommentData? {
        
        let user = CommentData()
        if (parseObj == nil) {
            return nil
        }
        user!.id = parseObj!.objectId!
        user!.userName = Utilities.getValidString(parseObj!["userName"] as? String, defaultString: "")
        user!.commentStr = Utilities.getValidString(parseObj!["commentStr"] as? String, defaultString: "")
        user!.userId = Utilities.getValidString(parseObj!["userId"] as? String, defaultString: "")
        
        user!.createdAt = parseObj!.createdAt!
        
        return user
    }
    
    func updateUserDataWithCallback(callback:((userData: UserData?, error: NSError?) -> Void)) {
        
        if userData == nil && !userId.isEmpty {
            
            PNAPIClient.sharedInstance.fetchUser(PFUser.init(withoutDataWithClassName: "_User", objectId: userId), callback: { (userData, error) -> Void in
                if error == nil && userData != nil {
                    self.userData = userData
                    callback(userData: self.userData, error: error)
                }
            })
        }
    }
    
    init?() {
        self.id = ""
    }
}

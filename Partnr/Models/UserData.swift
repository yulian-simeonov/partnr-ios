//
//  UserData.swift
//  Partnr
//
//  Created by Yosemite on 2/5/16.
//  Copyright © 2016 YulianMobile. All rights reserved.
//

import UIKit

import Parse

class UserData {
    
    var id: String = ""
    var facebookID: String = ""
    var name: String = ""
    var userName: String = ""
    var avatarImg: PFFile? = nil
    var email: String = ""
    var profession: String = ""
    var isCompany: Bool =  false
    var locationName: String = ""
    var bio: String = ""
    var website: String = ""
    var followStatus: NSInteger = -1
    var isAvailable: Bool = false
    var phoneNumber: String = ""
    
    var rate: CGFloat = -1
    
    var mutualFriends = [ContactData]()
    
    class func initWithParseObject(parseObj: PFUser?) -> UserData? {
        
        let user = UserData()
        if (parseObj == nil) {
            return nil
        }
        user!.id = parseObj!.objectId!
        user!.facebookID = Utilities.getValidString(parseObj!["facebookID"] as? String, defaultString: "")
        user!.name = Utilities.getValidString(parseObj!["name"] as? String, defaultString: "")
        user!.userName = Utilities.getValidString(parseObj!["username"] as? String, defaultString: "")
        user!.email = Utilities.getValidString(parseObj!["email"] as? String, defaultString: "")
        user!.avatarImg = parseObj!["avatarImg"] as? PFFile
        user!.profession = Utilities.getValidString(parseObj!["profession"] as? String, defaultString: "")
        user!.profession = user!.profession == "Other" ? "Creator - Partnr doesn't have my profession yet" : user!.profession
        user!.locationName = Utilities.getValidString(parseObj!["locationName"] as? String, defaultString: "")
        user!.bio = Utilities.getValidString(parseObj!["bio"] as? String, defaultString: "")
        user!.website = Utilities.getValidString(parseObj!["website"] as? String, defaultString: "")
        user!.isAvailable = parseObj!["isAvailable"] != nil ? parseObj!["isAvailable"].boolValue : false
        user!.phoneNumber = Utilities.getValidString(parseObj!["phoneNumber"] as? String, defaultString: "")
        
        return user
    }
    
    func updateWithUserData() {
        
        
    }
    
    init?() {
        self.id = ""
    }
}

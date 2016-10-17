//
//  UserData.swift
//  Partnr
//
//  Created by Yosemite on 2/5/16.
//  Copyright © 2016 YulianMobile. All rights reserved.
//

import UIKit

import Parse

class ProjectData: CommunityData {
    
    var id: String = ""
    var name: String = ""
    var profession: String = ""
    var brief: String = ""
    var deliverables: String = ""
    var price: Double = 0
    var dueDate: NSDate = NSDate()
    var updatedDate: NSDate = NSDate()
    var image: PFFile? = nil
    var userId: String = ""
    var status: EProjectStatus = .Open
    var partnrId: String = ""
    var briefUserId: String = ""
    
//    var createdAt = NSDate()

    var parseObj: PFObject? = nil
    
    var userData: UserData? = nil
    var partnrData: UserData? = nil

    class func initWithParseObject(parseObj: PFObject?) -> ProjectData? {
        
        let project = ProjectData()
        if (parseObj == nil) {
            return nil
        }
        
        project?.communityType = .Project
        
        project?.parseObj = parseObj
        
        project!.id = (parseObj?.objectId)!
        project!.userId = Utilities.getValidString(parseObj!["userId"] as? String, defaultString: "")
        project!.partnrId = Utilities.getValidString(parseObj!["partnrId"] as? String, defaultString: "")
        
        project!.name = Utilities.getValidString(parseObj!["name"] as? String, defaultString: "")
        project?.profession = Utilities.getValidString(parseObj!["profession"] as? String, defaultString: "")
        project!.brief = Utilities.getValidString(parseObj!["brief"] as? String, defaultString: "")
        project!.deliverables = Utilities.getValidString(parseObj!["deliverables"] as? String, defaultString: "")
        project!.price = Double(parseObj!["price"] as! NSNumber)
        project?.dueDate = parseObj!["dueDate"] as! NSDate
        project!.image = parseObj!["image"] as? PFFile
        
        project?.updatedDate = (parseObj?.updatedAt)!
        
        project?.status = EProjectStatus(rawValue: parseObj!["status"] as! NSInteger)!
        
        project!.createdAt = parseObj!.createdAt!
        
        project!.briefUserId = Utilities.getValidString(parseObj!["briefUserId"] as? String, defaultString: "")

        return project
    }
    
    func updateUserData(callback:((userData: UserData?, error: NSError?) -> Void)) {
        let pointer = PFObject.init(withoutDataWithClassName: "_User", objectId: userId)
        PNAPIClient.sharedInstance.fetchUser(pointer) { (userData, error) -> Void in
            self.userData = userData
            callback(userData: userData, error: error)
        }
    }
    
    func updatePartnrData(callback:((userData: UserData?, error: NSError?) -> Void)) {
        let pointer = PFObject.init(withoutDataWithClassName: "_User", objectId: partnrId)
        PNAPIClient.sharedInstance.fetchUser(pointer) { (userData, error) -> Void in
            self.partnrData = userData
            callback(userData: userData, error: error)
        }
    }
    
    func setStatusToOpen() {
        PNAPIClient.sharedInstance.setProjectStatusTo(self.id, status: EProjectStatus.Open) { (finished, error) -> Void in
            
        }
    }
    
    func isPendingExpired() -> Bool {
        let timeInterval = NSDate().timeIntervalSinceDate(self.updatedDate)
        if timeInterval > 24*3600 && self.status == .WaitingForFunding {
            return true
        } else {
            return false
        }
    }
    
//    override init?() {
//        self.id = ""
//    }
}

//
//  UserData.swift
//  Partnr
//
//  Created by Yulian Simeonov on 2/5/16.
//  Copyright © 2016 YulianMobile. All rights reserved.
//

import UIKit

import Parse

class ApplicantData {
    
    var id: String = ""
    var projectId: String = ""
    var userId: String = ""
    var status: EApplicantStatus = .None
    var price: Double = 0
    var parseObj: PFObject? = nil
    
    var userData: UserData? = nil
    var projectData: ProjectData? = nil
    
    class func initWithParseObject(parseObj: PFObject?) -> ApplicantData? {
        
        let project = ApplicantData()
        if (parseObj == nil) {
            return nil
        }
        project?.parseObj = parseObj
        project!.id = (parseObj?.objectId)!
        project!.userId = Utilities.getValidString(parseObj!["userId"] as? String, defaultString: "")
        project!.projectId = Utilities.getValidString(parseObj!["projectId"] as? String, defaultString: "")
        project?.status = EApplicantStatus(rawValue: parseObj!["status"] as! NSInteger)!
        project!.price = Double(parseObj!["price"] as! NSNumber)
        
        return project
    }
    
    func updateUserData(callback:((userData: UserData?, error: NSError?) -> Void)) {
        let pointer = PFObject.init(withoutDataWithClassName: "_User", objectId: userId)
        PNAPIClient.sharedInstance.fetchUser(pointer) { (userData, error) -> Void in
            self.userData = userData
            callback(userData: userData, error: error)
        }
    }
    
    func updateProjectData(callback:((projectData: ProjectData?, error: NSError?) -> Void)) {
        PNAPIClient.sharedInstance.fetchProject(projectId) { (projectData, error) -> Void in
            self.projectData = projectData
            callback(projectData: projectData, error: error)
        }
    }
    
    init?() {
        self.id = ""
    }
}

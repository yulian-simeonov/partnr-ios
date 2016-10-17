//
//  SharedDataManager.swift
//  NimbleSoftWare
//
//  Created by Yosemite on 10/9/15.
//  Copyright © 2015 YulianMobile. All rights reserved.
//

import UIKit
import CoreLocation

@objc class SharedDataManager: NSObject {
    var userId: String!
    var userName: String!
    var password: String!
    var isLoggedIn: Bool!

    var userData: UserData!
    
    var isFBLogin: Bool!
    var facebookInfo: NSDictionary!
    var isPushEnabled: Bool! {
        didSet {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setObject(isPushEnabled, forKey: "IsPushEnabled")
        }
    }
    
    // Project Type Array 
    var projectTypes = [NSInteger]()
    var isFirstToProjectFeed = true
    
    var rootVC: RootViewController!
    var accessToken: String!
    
    
    class var sharedInstance: SharedDataManager {
        struct Static {
            static let instance: SharedDataManager = SharedDataManager()
        }
        return Static.instance
    }
    
    override init () {
//        super.init()
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        print(userDefaults.boolForKey("IsLoggedIn"))
        userId = userDefaults.stringForKey("UserId")
        userName = userDefaults.stringForKey("UserName")
        password = userDefaults.stringForKey("Password")
        isLoggedIn = userDefaults.boolForKey("IsLoggedIn")
        isPushEnabled = userDefaults.boolForKey("IsPushEnabled")
    }
    
    func saveUserInfo() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        userDefaults.setObject(userId, forKey: "UserId")
        userDefaults.setObject(userName, forKey: "UserName")
        userDefaults.setObject(isLoggedIn, forKey: "IsLoggedIn")
        userDefaults.setObject(password, forKey: "Password")
        userDefaults.synchronize()
    }
    
    func removeUserInfo() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.removePersistentDomainForName(NSBundle.mainBundle().bundleIdentifier!)
        userDefaults .synchronize()
        
        userId = ""
        userName = ""
        password = ""
        isLoggedIn = false
        userData = nil
        isPushEnabled = false
    }
}

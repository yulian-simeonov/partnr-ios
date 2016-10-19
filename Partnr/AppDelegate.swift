//
//  AppDelegate.swift
//  Partnr
//
//  Created by Yulian Simeonov on 1/22/16.
//  Copyright © 2016 YulianMobile. All rights reserved.
//

import UIKit

import Parse
import FBSDKCoreKit
import ParseFacebookUtilsV4
import ParseUI
import Braintree

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var locationTracker: LocationTracker!
    var locationUpdateTimer: NSTimer!


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
//        let types:UIUserNotificationType = ([.Alert, .Sound, .Badge])
//        let notificationSettings = UIUserNotificationSettings(forTypes: types, categories: nil)
//        application.registerUserNotificationSettings(notificationSettings)  // types are UIUserNotificationType members
        
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
        _ = PFImageView()
        Parse.enableLocalDatastore()
        
        // ****************************************************************************
        // Uncomment this line if you want to enable Crash Reporting
        // ParseCrashReporting.enable()
        //
        // Uncomment and fill in with your Parse credentials:
//        let configuration = ParseClientConfiguration {
//            $0.applicationId = parse_app_id
//            $0.clientKey = parse_client_key
//            $0.server = "http://52.36.103.236"
//        }
//        Parse.initializeWithConfiguration(configuration)
        
        Parse.setApplicationId(parse_app_id,
            clientKey: parse_client_key)
        //
        // If you are using Facebook, uncomment and add your FacebookAppID to your bundle's plist as
        // described here: https://developers.facebook.com/docs/getting-started/facebook-sdk-for-ios/
        // Uncomment the line inside ParseStartProject-Bridging-Header and the following line here:
        PFFacebookUtils.initialize()
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        // ****************************************************************************
        
        //PFUser.enableAutomaticUser()
        
        let defaultACL = PFACL();
        
        // If you would like all objects to be private by default, remove this line.
        defaultACL.publicReadAccess = true
        
        PFACL.setDefaultACL(defaultACL, withAccessForCurrentUser:true)
        
        BTAppSwitch.setReturnURLScheme("com.Partnrinc.Partnr.payments")

        
        if application.applicationState != UIApplicationState.Background {
            // Track an app open here if we launch with a push, unless
            // "content_available" was used to trigger a background push (introduced in iOS 7).
            // In that case, we skip tracking here to avoid double counting the app-open.
            
            let preBackgroundPush = !application.respondsToSelector("backgroundRefreshStatus")
            let oldPushHandlerOnly = !self.respondsToSelector("application:didReceiveRemoteNotification:fetchCompletionHandler:")
            var noPushPayload = false;
            if let options = launchOptions {
                noPushPayload = options[UIApplicationLaunchOptionsRemoteNotificationKey] != nil;
            }
            if (preBackgroundPush || oldPushHandlerOnly || noPushPayload) {
                PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
            }
        }
        
        self.locationTracker = LocationTracker.init()
        self.startLocationTracking()
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        return true
    }

    func startLocationTracking() {
        self.updateLocation()
        self.locationTracker .startLocationTracking()
        self.locationUpdateTimer = NSTimer.scheduledTimerWithTimeInterval(60.0, target: self, selector: Selector("updateLocation"), userInfo: nil, repeats: true)
    }
    
    func updateLocation() {
        self.locationTracker .updateLocationToServer()
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        
        if url.scheme.localizedCaseInsensitiveCompare("com.Partnrinc.Partnr.payments") == .OrderedSame {
            return BTAppSwitch.handleOpenURL(url, sourceApplication:sourceApplication)
        }
        print("Can Open URL? - \(FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation))")
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
//    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
//        
//        let state = application.applicationState
//        if state == .Active {
//            
//            let projectId = notification.userInfo!["ProjectId"] as? String
//            if projectId != nil {
//                PNAPIClient.sharedInstance.fetchProject(projectId!, callback: { (projectData, error) -> Void in
//                    
//                    if projectData?.status == .WaitingForFunding {
//                        Utilities.showMsg(notification.alertBody!, delegate: SharedDataManager.sharedInstance.rootVC)
//                    }       
//
//                })
//            }
//        }
//        
//        application.applicationIconBadgeNumber = 0
//    }
}


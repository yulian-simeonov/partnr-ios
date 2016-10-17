//
//  RootViewController.swift
//  Partnr
//
//  Created by Yosemite on 1/22/16.
//  Copyright © 2016 YulianMobile. All rights reserved.
//

import UIKit

import Parse

extension String {
    func stringByAppendingPathComponent(pathComponent: String) -> String {
        return (self as NSString).stringByAppendingPathComponent(pathComponent)
    }
}

class RootViewController: JASidePanelController {

    override func awakeFromNib() {
        
        self.leftPanel = self.storyboard?.instantiateViewControllerWithIdentifier("LeftNC")
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        SharedDataManager.sharedInstance.rootVC = self
        
        PFUser.logOut()

        if NSUserDefaults.standardUserDefaults().boolForKey("HasLaunchedOnce") == false{
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "HasLaunchedOnce")
            self.performSelectorOnMainThread(Selector("showTutorialVC"), withObject: nil, waitUntilDone: false)
        }
        else{
            if SharedDataManager.sharedInstance.isLoggedIn != true {
                self.performSelectorOnMainThread(Selector("didLogOut"), withObject: nil, waitUntilDone: false)
            } else {
                
                let password = SharedDataManager.sharedInstance.password != nil ? SharedDataManager.sharedInstance.password : ""
                
                SVProgressHUD.show()
                PNAPIClient.sharedInstance.loginToGeneralUser(SharedDataManager.sharedInstance.userName, password: password) { (nsData, error) -> Void in
                    
                    SVProgressHUD.dismiss()
                    
                    if error == nil && nsData != nil {
                        self.didLogIn()
                    } else {
                        Utilities.showMsg("Login failed! \(error!.userInfo["error"])", delegate: self)
                        self.performSelectorOnMainThread(Selector("didLogOut"), withObject: nil, waitUntilDone: false)
                    }
                }
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didLoggedOutWithAnimation() {
        
        SharedDataManager.sharedInstance.removeUserInfo()
        self.performSegueWithIdentifier(kShowWelcomeWithAnimation, sender: self)
    }
    
    func didLogOut() {
        SharedDataManager.sharedInstance.removeUserInfo()
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "HasLaunchedOnce")
        self.performSegueWithIdentifier(kShowWelcome, sender: self)
    }
    
    func showTutorialVC(){
        self.performSegueWithIdentifier("showTutorial", sender: self)
//        let dic = NSDictionary(contentsOfFile: NSBundle.mainBundle().bundlePath.stringByAppendingPathComponent("Config.plist"))
//        print("Plist Data: \(dic)")
//        
//        let images = dic!["Tutorial"]!["Images"] as! [AnyObject]
//        let labels = dic!["Tutorial"]!["Labels"] as! [AnyObject]
//        
//        let vc = AOTutorialController(backgroundImages: images, andInformations: labels)
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func didsignup() {
        SVProgressHUD.show()
        PNAPIClient.sharedInstance.loginToGeneralUser(SharedDataManager.sharedInstance.userName, password: SharedDataManager.sharedInstance.password) { (nsData, error) -> Void in
            
            SVProgressHUD.dismiss()
            
            if error == nil && nsData != nil {
                SharedDataManager.sharedInstance.rootVC.didLogIn()
                    PNAPIClient.sharedInstance.initialRateToUserId(SharedDataManager.sharedInstance.userData.id, rateStar: 3.0, callback: { (finished, error) -> Void in
                        print("Initial Rating Error:\(error)")
                    })
            } else {
                Utilities.showMsg("Login failed! \(error?.userInfo["error"]!)", delegate: self)
            }
        }
        
        
//        SharedDataManager.sharedInstance.userData = UserData.initWithParseObject(PFUser.currentUser())
//        print("Current User: \(PFUser.currentUser())")
//        NSNotificationCenter.defaultCenter().postNotificationName(kNotiRefreshSideMenu, object: nil)
//        UIApplication.sharedApplication().statusBarHidden = false
//        
//        PNAPIClient.sharedInstance.loginToGeneralUser(SharedDataManager.sharedInstance.userData.userName, password: SharedDataManager.sharedInstance.password) { (nsData, error) -> Void in
//            
//            SVProgressHUD.dismiss()
//            
//            if error == nil && nsData != nil {
//                self .dismissViewControllerAnimated(true, completion: { () -> Void in
//                    self.centerPanel = self.storyboard?.instantiateViewControllerWithIdentifier("ProjectsNC")
//                    PNAPIClient.sharedInstance.initialRateToUserId(SharedDataManager.sharedInstance.userData.id , rateStar: 3.0, callback: { (finished, error) -> Void in
//                        print("Error: \(error)")
//                    })
//                })
//            } else {
//                Utilities.showMsg("Login failed! \(error?.userInfo["error"]!)", delegate: self)
//            }
//        }
    }
    
    func didLogIn() {
        SharedDataManager.sharedInstance.userData = UserData.initWithParseObject(PFUser.currentUser())
        print("Current User: \(PFUser.currentUser())")
        NSNotificationCenter.defaultCenter().postNotificationName(kNotiRefreshSideMenu, object: nil)
        UIApplication.sharedApplication().statusBarHidden = false
        
        self.centerPanel = self.storyboard?.instantiateViewControllerWithIdentifier("ProjectsNC")
    }
    
    func showProjectView() {
        self.centerPanel = self.storyboard?.instantiateViewControllerWithIdentifier("ProjectsNC")
    }
    
    func showCommunityView() {
        self.centerPanel = self.storyboard?.instantiateViewControllerWithIdentifier("NewsfeedNC")
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showTutorial" {
        }
    }

}

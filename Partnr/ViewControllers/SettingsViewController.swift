//
//  SettingsViewController.swift
//  Partnr
//
//  Created by Yosemite on 2/25/16.
//  Copyright © 2016 YulianMobile. All rights reserved.
//

import UIKit

import ParseUI
import MessageUI

class MyStringItemSource: NSObject, UIActivityItemSource {
    @objc func activityViewControllerPlaceholderItem(activityViewController: UIActivityViewController) -> AnyObject {
        return ""
    }
    
    @objc func activityViewController(activityViewController: UIActivityViewController, itemForActivityType activityType: String) -> AnyObject? {
        if activityType == UIActivityTypeMessage {
            return "Join Partnr today and collaborate with creators and brands you trust."
        } else if activityType == UIActivityTypeMail {
            return "Join Partnr today and collaborate with creators and brands you trust."
        } else if activityType == UIActivityTypePostToTwitter {
            return "Join Partnr today and collaborate with creators and brands you trust."
        } else if activityType == UIActivityTypePostToFacebook {
            return "Join Partnr today and collaborate with creators and brands you trust."
        }
        return nil
    }
    
    func activityViewController(activityViewController: UIActivityViewController, subjectForActivityType activityType: String?) -> String {
        if activityType == UIActivityTypeMessage {
            return "Partnr"
        } else if activityType == UIActivityTypeMail {
            return "Partnr"
        } else if activityType == UIActivityTypePostToTwitter {
            return "Partnr"
        } else if activityType == UIActivityTypePostToFacebook {
            return "Partnr"
        }
        return ""
    }
    
    func activityViewController(activityViewController: UIActivityViewController, thumbnailImageForActivityType activityType: String!, suggestedSize size: CGSize) -> UIImage! {
        if activityType == UIActivityTypeMessage {
            return UIImage(named: "thumbnail-for-message")
        } else if activityType == UIActivityTypeMail {
            return UIImage(named: "thumbnail-for-mail")
        } else if activityType == UIActivityTypePostToTwitter {
            return UIImage(named: "thumbnail-for-twitter")
        } else if activityType == UIActivityTypePostToFacebook {
            return UIImage(named: "thumbnail-for-facebook")
        }
        return UIImage(named: "some-default-thumbnail")
    }
}

class SettingsViewController: CustomBaseViewController, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate {

    let cellIdentifiers = ["AccountCell", "PushNotificationsCell", "ChangeEmailCell", "LogoutCell", "MoreCell", "InviteFriendsCell", "RateUsCell", "TermsOfServiceCell", "PrivacyPolicyCell", "ContactUsCell"]
    
    var pushSwitch: UISwitch? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableViewDataSource
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return indexPath.row == 0 || indexPath.row == 4 ? 35.0 : 45.0
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellIdentifiers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifiers[indexPath.row], forIndexPath: indexPath)
        
        if indexPath.row == 1 {
            pushSwitch = cell.viewWithTag(1) as? UISwitch
            pushSwitch?.addTarget(self, action: Selector("onSwitchChanged:"), forControlEvents: .ValueChanged)
            pushSwitch?.setOn(SharedDataManager.sharedInstance.isPushEnabled, animated: true)
        }
        
        return cell
    }
    
    func onSwitchChanged(sender: UISwitch) {
        SharedDataManager.sharedInstance.isPushEnabled = sender.on
    }
    
    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.row == 1 { // Push Notification
            
        } else if indexPath.row == 3 { // Log out
            let alertVC = UIAlertController.init(title: kTitle_APP, message: NSLocalizedString("Are you sure you want to log out?", comment: "Are you sure you want to log out?"), preferredStyle: UIAlertControllerStyle.Alert)
            
            let defaultAction = UIAlertAction(title: NSLocalizedString("Ok", comment: "Ok"), style: .Default) { (alert: UIAlertAction!) -> Void in
                
                PFUser.logOutInBackgroundWithBlock { (error) -> Void in
                    if error == nil {
                        SharedDataManager.sharedInstance.rootVC.didLogOut()
                    }
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .Default) { (alert: UIAlertAction!) -> Void in
                alertVC.dismissViewControllerAnimated(true, completion: { () -> Void in
                    
                })
            }
            alertVC.addAction(defaultAction)
            alertVC.addAction(cancelAction)
            
            self.presentViewController(alertVC, animated: true, completion: nil)
           
        } else if indexPath.row == 5 { // Invite Friends
            let activityVC = UIActivityViewController.init(activityItems: [MyStringItemSource()], applicationActivities: nil)
            self.presentViewController(activityVC, animated: true, completion: { () -> Void in
                
            })
        } else if indexPath.row == 6 { // Rate Us
            UIApplication.sharedApplication().openURL(NSURL.init(string: "https://itunes.apple.com/us/app/partnr/id1071349858?ls=1&mt=8")!)
        } else if indexPath.row == 7 { // Terms of Service
            UIApplication.sharedApplication().openURL(NSURL.init(string: "https://www.partnrinc.com/termsofservice")!)
        } else if indexPath.row == 8 { // Privacy Policy
            UIApplication.sharedApplication().openURL(NSURL.init(string: "https://www.partnrinc.com/privacypolicy")!)
        } else if indexPath.row == 9 { // Contact Us
            let mailComposeViewController = configuredMailComposeViewController()
            if MFMailComposeViewController.canSendMail() {
                self.presentViewController(mailComposeViewController, animated: true, completion: nil)
            } else {
                self.showSendMailErrorAlert()
            }
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients(["partnrsupport@partnrinc.com"])
        mailComposerVC.setSubject("Join Partnr: A Community & Career Management Network")
        mailComposerVC.setMessageBody("Dedicated to Creators www.partnrinc.com/signup", isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        Utilities.showMsg("Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self)
    }
    
    // MARK: MFMailComposeViewControllerDelegate
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    @IBAction func onClickFindPartnr(sender: AnyObject) {
        ModalDialogViewController.showDialogWithType(EDialogType.FindPartnr, delegate: self) { (nsData, error) -> Void in
            
            SharedDataManager.sharedInstance.isFirstToProjectFeed = false
            
            let response = nsData!["response"].intValue
            if response == 1 { // Search partnr
                let profession = nsData!["profession"].stringValue
                let searchPartnrVC = self.storyboard?.instantiateViewControllerWithIdentifier("SelectPartnrVC") as! SelectPartnrViewController
                searchPartnrVC.profession = profession
                self.navigationController?.pushViewController(searchPartnrVC, animated: true)
            } else if response == 2 { // Create new project
                let postProjectVC = self.storyboard?.instantiateViewControllerWithIdentifier("PostProjectVC") as! PostProjectViewController
                self.navigationController?.pushViewController(postProjectVC, animated: true)
            } else if response == 3 { // View the community
                SharedDataManager.sharedInstance.rootVC.showCommunityView()
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

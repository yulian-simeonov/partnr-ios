//
//  SideMenuViewController.swift
//  NimbleSchedule
//
//  Created by Yulian Simeonov on 10/12/15.
//  Copyright © 2015 YulianMobile. All rights reserved.
//

import UIKit
import ParseUI

// Menu Type
enum EMenuType: Int {
    case MyProjects = 0
    case Home
//    case Search
    case Settings
    case Avatar
    case Available
}

class AvailableTableCell: UITableViewCell {

    @IBOutlet weak var availButton: UIButton!
    @IBOutlet weak var availLabel: UILabel!
}

class AvatarTableCell: UITableViewCell {
    
    @IBOutlet weak var avatarImage: PFImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var pointButton: UIButton!
    @IBOutlet weak var ratingView: FloatRatingView!
    @IBOutlet weak var markLabel: UILabel!
    @IBOutlet weak var rateButton: UIButton!
}

class SideMenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    
    let cellsArray: [String] = ["MyProjectsCell", "HomeCell", "SettingsCell", "AvatarCell", "AvailableCell"]
    
    @IBOutlet weak var menuTable: UITableView?
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        NSNotificationCenter.defaultCenter().addObserverForName("Noti:SideMenuRefresh", object: nil, queue: nil) { (noti) -> Void in
            self.menuTable?.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableViewDataSource, UITableViewDelegate
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int
    {
        return cellsArray.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == EMenuType.Available.rawValue {
            return 100
        }
        return indexPath.row == EMenuType.Avatar.rawValue ? IS_IPHONE4 ? 164 : 184 : IS_IPHONE4 ? 45 : 60
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier(cellsArray[indexPath.row])!
        
        let titleLabel = cell.viewWithTag(1) as? UILabel
        if titleLabel != nil {
//            let langKeys = ["Dashboard", "Schedule", "RequestsAndApprovals", "ClockInOut", "MyAvailability", "Timesheets", "Messages", "Employees", "Locations"]
//            titleLabel?.text = langKeys[indexPath.row]
        }
        
        if indexPath.row == EMenuType.Avatar.rawValue {
            let avatarCell = cell as! AvatarTableCell
            avatarCell.usernameLabel.text = SharedDataManager.sharedInstance.userData.name
            avatarCell.avatarImage.file = SharedDataManager.sharedInstance.userData?.avatarImg
            avatarCell.avatarImage.loadInBackground { (image, error) -> Void in
                
            }
            
            PNAPIClient.sharedInstance.getLatestRateFromUserId((PFUser.currentUser()?.objectId)!, callback: { (rate, error) -> Void in
                avatarCell.rateButton.setTitle(NSString(format: "%.01f", rate) as String, forState: .Normal)
//                avatarCell.ratingView.rating = Float(rate)
//                avatarCell.markLabel.text = NSString(format: "%.02f", rate) as String
            })
        } else if indexPath.row == EMenuType.Available.rawValue {
            let availCell = cell as! AvailableTableCell
            availCell.availButton.selected = SharedDataManager.sharedInstance.userData.isAvailable
            availCell.availLabel.text = SharedDataManager.sharedInstance.userData.isAvailable ? "AVAILABLE" : "NOT AVAILABLE"
            
            availCell.availButton.addTarget(self, action: Selector("onClickAvailable:"), forControlEvents: .TouchUpInside)
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        var storyboardID: String = "NewsfeedNC"
        switch(indexPath.row) {
        case EMenuType.Home.rawValue:
            storyboardID = "NewsfeedNC"
            
            SharedDataManager.sharedInstance.rootVC.centerPanel = self.storyboard?.instantiateViewControllerWithIdentifier(storyboardID)
            break
        case EMenuType.MyProjects.rawValue:
            storyboardID = "ProjectsNC"
            SharedDataManager.sharedInstance.rootVC.centerPanel = self.storyboard?.instantiateViewControllerWithIdentifier(storyboardID)
            break
//        case EMenuType.Search.rawValue:
//            storyboardID = "SearchNC"
//            let searchNC = self.storyboard?.instantiateViewControllerWithIdentifier(storyboardID) as! UINavigationController
//            SharedDataManager.sharedInstance.rootVC.centerPanel = searchNC
//            break
        case EMenuType.Settings.rawValue:
            self.onClickSetting(UIButton())
            break
        case EMenuType.Avatar.rawValue:
            storyboardID = "ProfileNC"
            let profileNC = self.storyboard?.instantiateViewControllerWithIdentifier(storyboardID) as! UINavigationController
            (profileNC.viewControllers[0] as! ProfileViewController).userData = SharedDataManager.sharedInstance.userData
            (profileNC.viewControllers[0] as! ProfileViewController).isMe = true

            SharedDataManager.sharedInstance.rootVC.centerPanel = profileNC
            break;
        default:
            break
            
        }
    }

    @IBAction func onClickSetting(sender: AnyObject) {
        let settingsNC = self.storyboard?.instantiateViewControllerWithIdentifier("SettingsNC") as! UINavigationController
        
        SharedDataManager.sharedInstance.rootVC.centerPanel = settingsNC
    }
    
    @IBAction func logOut(){
        let alertVC = UIAlertController.init(title: kTitle_APP, message: NSLocalizedString("Are you sure you want to log out?", comment: "Are you sure you want to log out?"), preferredStyle: UIAlertControllerStyle.Alert)
        
        let defaultAction = UIAlertAction(title: NSLocalizedString("Ok", comment: "Ok"), style: .Default) { (alert: UIAlertAction!) -> Void in
           self.logOutSession()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default) { (alert: UIAlertAction!) -> Void in
          alertVC.dismissViewControllerAnimated(true, completion: { () -> Void in
            
          })
        }
        alertVC.addAction(defaultAction)
        alertVC.addAction(cancelAction)
        
        self.presentViewController(alertVC, animated: true, completion: nil)
        
     }
    
    func onClickAvailable(sender: UIButton) {
        SVProgressHUD.show()
        PNAPIClient.sharedInstance.updateAvailable(!SharedDataManager.sharedInstance.userData.isAvailable) { (success, error) -> Void in
            SVProgressHUD.dismiss()
            if success == true {
                SharedDataManager.sharedInstance.userData.isAvailable = !SharedDataManager.sharedInstance.userData.isAvailable
                self.menuTable?.reloadData()
            }
        }
    }
    
    func logOutSession(){
        PFUser.logOutInBackgroundWithBlock { (error) -> Void in
            if error == nil {
                SharedDataManager.sharedInstance.rootVC.didLogOut()
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

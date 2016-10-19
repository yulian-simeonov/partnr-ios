//
//  UserListViewController.swift
//  Partnr
//
//  Created by Yulian Simeonov on 2/16/16.
//  Copyright © 2016 YulianMobile. All rights reserved.
//

import UIKit

import ParseUI

class UserListViewController: CustomBaseViewController, UITableViewDataSource, UITableViewDelegate {

    private let cellIdentifier = "UserCell"
    
    @IBOutlet weak var userTable: UITableView!
    @IBOutlet weak var titleButton: UIButton!
    
    var userType = EUserType.Follower
    var userArray = [FollowData]()
    var userId: String? = nil
    var partnrArray = [String]()
    var partnrUserDict = NSMutableDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        var title = "FOLLOWERS"
        
        SVProgressHUD.show()

        if userType == EUserType.Follower {
            title = "FOLLOWERS"
            
            PNAPIClient.sharedInstance.fetchFollowers(userId!, callback: { (succeed, followArray, error) -> Void in
                SVProgressHUD.dismiss()
                if succeed {
                    self.userArray = followArray!
                    self.userTable.reloadData()
                }
            })
        } else if userType == EUserType.Following {
            title = "FOLLOWING"
            
            PNAPIClient.sharedInstance.fetchFollowing(userId!, callback:{ (succeed, followArray, error) -> Void in
                SVProgressHUD.dismiss()
                if succeed {
                    self.userArray = followArray!
                    self.userTable.reloadData()
                }
            })
        } else if userType == EUserType.Partnr {
            title = "PARTNRS"
            PNAPIClient.sharedInstance.fetchPartnr(userId!, callback:{ (succeed, partnrArray, error) -> Void in
                SVProgressHUD.dismiss()
                if succeed {
                    self.partnrArray = partnrArray!
                    self.userTable.reloadData()
                }
            })
        }
        
        titleButton.setTitle(title, forState: .Normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userType == .Partnr ? partnrArray.count : userArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! UserTableCell
        
        if userType == .Follower {
            let followData = userArray[indexPath.row]
            
            if (followData.fromUserData == nil) {
                PNAPIClient.sharedInstance.fetchUser(followData.fromUserPointer!, callback: { (userData, error) -> Void in
                    followData.fromUserData = userData
                    cell.proceedContent(userData!)
                    cell.updateFollowingStatus(userData!)
                    
                })
            } else {
                cell.proceedContent(followData.fromUserData!)
                cell.updateFollowingStatus(followData.fromUserData!)
                
            }
        } else if userType == .Following {
            let followData = userArray[indexPath.row]
            
            if (followData.toUserData == nil) {
                PNAPIClient.sharedInstance.fetchUser(followData.toUserPointer!, callback: { (userData, error) -> Void in
                    followData.toUserData = userData
                    cell.proceedContent(userData!)
                    cell.updateFollowingStatus(userData!)
                })
            } else {
                cell.proceedContent(followData.toUserData!)
                cell.updateFollowingStatus(followData.toUserData!)
            }
        } else if userType == .Partnr {
            let userData = partnrUserDict[partnrArray[indexPath.row]] as? UserData
            
            if (userData == nil) {
                let pointer = PFUser.init(withoutDataWithClassName: "_User", objectId: partnrArray[indexPath.row])
                PNAPIClient.sharedInstance.fetchUser(pointer, callback: { (userData, error) -> Void in
                    self.partnrUserDict.setObject(userData!, forKey: self.partnrArray[indexPath.row])
                    cell.proceedContent(userData!)
                    cell.updateFollowingStatus(userData!)
                })
            } else {
                cell.proceedContent(userData!)
                cell.updateFollowingStatus(userData!)
            }
        }
        
        return cell
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

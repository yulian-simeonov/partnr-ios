//
//  UserTableCell.swift
//  Partnr
//
//  Created by Yosemite on 2/24/16.
//  Copyright © 2016 YulianMobile. All rights reserved.
//

import UIKit
import ParseUI

class UserTableCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var avatarImage: PFImageView!
    @IBOutlet weak var followButton: NSLoadingButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var professionLabel: UILabel!
    
    @IBOutlet weak var shadowImage: PFImageView!
    
    var targetUserData: UserData? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func proceedContent(userData: UserData) {
        self.nameLabel.text = userData.name
        self.usernameLabel.text = userData.userName
        if self.professionLabel != nil {
            self.professionLabel.text = userData.profession
        }
        
        self.avatarImage.file = userData.avatarImg
        self.avatarImage.loadInBackground { (image, error) -> Void in
            if self.shadowImage != nil {
                self.shadowImage.image = image
            }
        }
        
        self.targetUserData = userData
        
//        self.updateFollowingStatus(userData)
    }
    
    func updateFollowingStatus(userData: UserData) {
        if self.followButton != nil {
            PNAPIClient.sharedInstance.checkIfFollow((PFUser.currentUser()?.objectId)!, toUserId: userData.id, callback: { (isFollowed, error) -> Void in
                if error == nil {
                    self.followButton.selected = isFollowed
                    self.followButton.loading = false
                }
            })
        }
    }

    @IBAction func onClickFollow(sender: AnyObject) {
        if self.followButton.selected {
            self.followButton.loading = true
            PNAPIClient.sharedInstance.unfollowToUserId(self.targetUserData!.id, callback: { (succeed, error) -> Void in
                self.updateFollowingStatus(self.targetUserData!)
            })
        } else {
            self.followButton.loading = true
            PNAPIClient.sharedInstance.followToUserId(self.targetUserData!.id, callback: { (succeed, error) -> Void in
                self.updateFollowingStatus(self.targetUserData!)
            })
        }
    }
    
}

//
//  FeedTableCell.swift
//  Partnr
//
//  Created by Yosemite on 2/12/16.
//  Copyright © 2016 YulianMobile. All rights reserved.
//

import UIKit
import ParseUI

class PeopleFeedTableCell: FeedBaseTableCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var adminAvatarImage: PNRoundedShadowView!
    @IBOutlet weak var avatarShadowImage: UIImageView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var fullnameLabel: UILabel!
    
    @IBOutlet weak var followButton: NSLoadingButton!
    var newsData: NewsData? = nil
    
    override func awakeFromNib() {
        
//        containerView.layer.borderColor = UIColor.init(red: 239/255.0, green: 239/255.0, blue: 239/255.0, alpha: 1.0).CGColor
//        containerView.layer.borderWidth = 0.7
    }
    
    func proceeedContent(newsData: NewsData) {
        self.newsData = newsData
        self.usernameLabel.text = "@\(newsData.userName)"
        self.captionLabel.text = newsData.caption
        
        // Update UserInfo
        if newsData.userData == nil {
            newsData.updateUserDataWithCallback({ (userData, error) -> Void in
                self.loadAvatarImage()
            })
        } else {
            self.loadAvatarImage()
        }
        
        if self.newsData?.userId == PFUser.currentUser()?.objectId {
            self.followButton.hidden = true
        } else {
            if self.newsData?.userData?.followStatus == -1 {
                PNAPIClient.sharedInstance.checkIfFollow((PFUser.currentUser()?.objectId)!, toUserId: newsData.userId) { (isFollowed, error) -> Void in
                    if error == nil {
                        self.followButton.selected = isFollowed
                    }
                }
            } else {
                self.followButton.selected = self.newsData?.userData?.followStatus == 0 ? false : true
            }
        }
    }
    
    func loadAvatarImage() {
        self.fullnameLabel.text = self.newsData?.userData?.name
        
        self.adminAvatarImage.file = self.newsData?.userData?.avatarImg
        self.adminAvatarImage.loadInBackground { (image, error) -> Void in
            self.avatarShadowImage.image = image
        }
    }
    
    @IBAction func onClickFollow(sender: AnyObject) {
        if self.followButton.selected {
            self.followButton.loading = true
            PNAPIClient.sharedInstance.unfollowToUserId(self.newsData!.userId, callback: { (succeed, error) -> Void in
                self.followButton.loading = false
                self.followButton.selected = false
            })
        } else {
            self.followButton.loading = true
            PNAPIClient.sharedInstance.followToUserId(self.newsData!.userId, callback: { (succeed, error) -> Void in
                self.followButton.loading = false
                self.followButton.selected = true
            })
        }
    }
}
//
//  FeedTableCell.swift
//  Partnr
//
//  Created by Yosemite on 2/12/16.
//  Copyright © 2016 YulianMobile. All rights reserved.
//

import UIKit
import ParseUI

class CommunityFeedTableCell: FeedBaseTableCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var avatarImage: PNRoundedShadowView!
    @IBOutlet weak var avatarShadowImage: UIImageView!
    
    @IBOutlet weak var timeAgoLabel: UILabel!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
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
        
        // Update Height
        self.layoutIfNeeded()
    }
    
    func loadAvatarImage() {
        self.usernameLabel.text = self.newsData?.userData?.name
        
        self.avatarImage.file = self.newsData?.userData?.avatarImg
        self.avatarImage.loadInBackground { (image, error) -> Void in
            self.avatarShadowImage.image = image
        }
    }
    
}
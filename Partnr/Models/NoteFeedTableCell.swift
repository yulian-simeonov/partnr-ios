//
//  FeedTableCell.swift
//  Partnr
//
//  Created by Yulian Simeonov on 2/12/16.
//  Copyright © 2016 YulianMobile. All rights reserved.
//

import UIKit
import ParseUI

class NoteFeedTableCell: FeedBaseTableCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var avatarImage: PFImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timeAgoLabel: UILabel!

    @IBOutlet weak var newsImage: PFImageView!
    @IBOutlet weak var avatarActivity: UIActivityIndicatorView!
    @IBOutlet weak var imgContainerHeiConstraint: NSLayoutConstraint!

    @IBOutlet weak var backImage: UIImageView!
    
    @IBOutlet weak var noteContainer: PNRoundedShadowView!
    @IBOutlet weak var profileContainer: UIView!
    
    @IBOutlet weak var labelImage: UIImageView!
    @IBOutlet weak var labelView: PNRoundedShadowView!
    
    var newsData: NewsData? = nil
    
    override func awakeFromNib() {
        
//        containerView.layer.borderColor = UIColor.init(red: 239/255.0, green: 239/255.0, blue: 239/255.0, alpha: 1.0).CGColor
//        containerView.layer.borderWidth = 0.7
//        
//        noteContainer.layer.borderColor = UIColor.init(red: 210/255.0, green: 210/255.0, blue: 210/255.0, alpha: 1.0).CGColor
//        noteContainer.layer.borderWidth = 1.0
        //
        //        containerView.layer.shadowColor = UIColor.lightGrayColor().CGColor;
        //        containerView.layer.shadowOffset = CGSizeMake(0, -2);
        //        containerView.layer.shadowOpacity = 0.6;
        //        containerView.layer.shadowRadius = 1.0;
    }
    
    func proceeedContent(newsData: NewsData) {
        self.newsData = newsData
        
        usernameLabel.text = newsData.userName
        timeAgoLabel.text = newsData.createdAt.timeAgoSimple()
        captionLabel.text = newsData.caption
        
        labelImage.image = Utilities.imageFromNoteLabel(newsData.noteLabel)
        labelView.backgroundColor = Utilities.colorFromNoteLabel(newsData.noteLabel)
        
        // Update UserInfo
        if newsData.userData == nil {
            newsData.updateUserDataWithCallback({ (userData, error) -> Void in
                self.usernameLabel.text = userData?.name
                self.loadAvatarImage()
            })
        } else {
            self.usernameLabel.text = newsData.userData?.name
            self.loadAvatarImage()
        }
    }
    
    func loadAvatarImage() {
        
        self.avatarActivity.hidden = false
        self.avatarActivity.startAnimating()
        self.avatarImage.file = self.newsData?.userData?.avatarImg
        self.avatarImage.loadInBackground { (image, error) -> Void in
            self.backImage.image = image
            self.avatarActivity.stopAnimating()
            self.avatarActivity.hidden = true
        }
    }
}
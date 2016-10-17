//
//  FeedTableCell.swift
//  Partnr
//
//  Created by Yosemite on 2/12/16.
//  Copyright © 2016 YulianMobile. All rights reserved.
//

import UIKit
import ParseUI

class PhotoFeedTableCell: FeedBaseTableCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var avatarImage: PFImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var newsImage: PFImageView!
    @IBOutlet weak var avatarActivity: UIActivityIndicatorView!
    @IBOutlet weak var imgContainerHeiConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var labelImage: UIImageView!
    @IBOutlet weak var labelView: PNRoundedShadowView!
    
    @IBOutlet var commentLabels: [KILabel]!
    
    var newsData: NewsData? = nil
    
    override func awakeFromNib() {
        
//        containerView.layer.borderColor = UIColor.init(red: 239/255.0, green: 239/255.0, blue: 239/255.0, alpha: 1.0).CGColor
//        containerView.layer.borderWidth = 0.7
        //
        //        containerView.layer.shadowColor = UIColor.lightGrayColor().CGColor;
        //        containerView.layer.shadowOffset = CGSizeMake(0, -2);
        //        containerView.layer.shadowOpacity = 0.6;
        //        containerView.layer.shadowRadius = 1.0;
    }
    
    func proceeedContent(newsData: NewsData) {
        self.newsData = newsData
        
        if newsData.photoFile != nil {
            newsImage.file = newsData.photoFile!
            newsImage.loadInBackground { (image, error) -> Void in
                //            print(image!.size)
                
                
            }
        }
        usernameLabel.text = newsData.userName
        timeAgoLabel.text = newsData.createdAt.timeAgoSimple()
        
        labelImage.image = Utilities.imageFromPhotoLabel(newsData.photoLabel)
        labelView.backgroundColor = Utilities.colorFromPhotoLabel(newsData.photoLabel)
        //        // Update Like Count
        //        if !newsData.isLikeUpdated {
        //            newsData.updateLikeInfoWithCallback({ (likeCount) -> Void in
        //                self.likesButton.setTitle("\(likeCount)", forState: .Normal)
        //            })
        //        } else {
        //            self.likesButton.setTitle("\(newsData.likeCount)", forState: .Normal)
        //        }
        
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
        
        // Update Height
//        let hei = newsData.photoSize.height * ( SCRN_WIDTH / newsData.photoSize.width)
//        imgContainerHeiConstraint.constant = hei
//        self.layoutIfNeeded()
    }
    
    func buildCommentsContainer(newsData: NewsData) {
        
        if newsData.comments.count > 0 {
            var count = newsData.comments.count > 3 ? 2 : newsData.comments.count-1
            if  newsData.caption.isEmpty == false {
                count = count - 1
            }
            self.commentLabels.forEach { (label) -> () in
                label.hidden = true
            }
            let startIndex = newsData.caption.isEmpty ? 0 : 1
            
            if newsData.caption.isEmpty == false {
                let label = self.commentLabels[0]
                label.hidden = false
                label.text = "\(PFUser.currentUser()!.username!) \(newsData.caption)"
            }
            if count > 0 {
                for i in 0 ... count {
                    let commentData = newsData.comments[i] as! CommentData
                    let label = self.commentLabels[i+startIndex]
                    label.hidden = false
                    label.text = "\(commentData.userName) \(commentData.commentStr)"
                }
            }
        }
    }
    
    func loadAvatarImage() {
        
        self.avatarActivity.hidden = false
        self.avatarActivity.startAnimating()
        self.avatarImage.file = self.newsData?.userData?.avatarImg
        self.avatarImage.loadInBackground { (image, error) -> Void in
            self.avatarActivity.stopAnimating()
            self.avatarActivity.hidden = true
        }
    }
}
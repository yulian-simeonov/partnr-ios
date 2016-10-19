//
//  FeedTableCell.swift
//  Partnr
//
//  Created by Yulian Simeonov on 2/12/16.
//  Copyright © 2016 YulianMobile. All rights reserved.
//

import UIKit
import ParseUI

class PartnrFeedTableCell: FeedBaseTableCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var adminAvatarImage: PNRoundedShadowView!
    @IBOutlet weak var partnrAvatarImage: PNRoundedShadowView!
    @IBOutlet weak var projectImage: PNRoundedShadowView!
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var newsImage: PFImageView!
    
    
    var newsData: NewsData? = nil
    
    override func awakeFromNib() {
        
//        containerView.layer.borderColor = UIColor.init(red: 239/255.0, green: 239/255.0, blue: 239/255.0, alpha: 1.0).CGColor
//        containerView.layer.borderWidth = 0.7
    }
    
    func proceeedContent(newsData: NewsData) {
        self.newsData = newsData
        
        if self.newsData!.projectData == nil {
            PNAPIClient.sharedInstance.fetchProject((self.newsData?.projectId)!) { (projectData, error) -> Void in
                if error == nil && projectData != nil {
                    self.newsData?.projectData = projectData
                    
                    let userPointer = PFObject.init(withoutDataWithClassName: "_User", objectId: projectData?.userId)
                    PNAPIClient.sharedInstance.fetchUser(userPointer, callback: { (userData, error) -> Void in
                        self.newsData?.userData = userData
                        self.loadAdminAvatarImage()
                        
                        if self.newsData?.partnrUserData != nil {
                            self.updateCaption()
                        }
                    })
                    
                    let partnrUserPointer = PFObject.init(withoutDataWithClassName: "_User", objectId: projectData?.partnrId)
                    PNAPIClient.sharedInstance.fetchUser(partnrUserPointer, callback: { (userData, error) -> Void in
                        self.newsData?.partnrUserData = userData
                        self.loadPartnrAvatarImage()
                        
                        if self.newsData?.userData != nil {
                            self.updateCaption()
                        }
                    })
                    
                    self.loadProjectImage()
                }
            }
        } else {
            self.loadProjectImage()
            
            if self.newsData?.userData != nil && self.newsData?.partnrUserData != nil {
                self.updateCaption()
            }
        }
        
        timeAgoLabel.text = newsData.createdAt.timeAgoSimple()
        
        // Update UserInfo
        if newsData.userData != nil {
            self.loadAdminAvatarImage()
        }
        
        // Update Partnr UserInfo
        if newsData.partnrUserData != nil {
            self.loadAdminAvatarImage()
        }
        
        // Update Height
        self.layoutIfNeeded()
    }
    
    func updateCaption() {
        if self.newsData != nil && self.newsData?.projectData != nil {
            let caption = "\((self.newsData?.userData?.userName)!) Partnr'd with \((self.newsData?.partnrUserData?.userName)!) for the project \((self.newsData?.projectData?.name)!). Congrats!"
            self.captionLabel.text = caption
        }
    }
    
    func loadProjectImage() {
        projectImage.file = self.newsData?.projectData?.image
        projectImage.loadInBackground { (image, error) -> Void in
            
        }
    }
    
    func loadAdminAvatarImage() {
        
        self.adminAvatarImage.file = self.newsData?.userData?.avatarImg
        self.adminAvatarImage.loadInBackground { (image, error) -> Void in
        }
    }
    
    func loadPartnrAvatarImage() {
        self.partnrAvatarImage.file = self.newsData?.partnrUserData?.avatarImg
        self.partnrAvatarImage.loadInBackground { (image, error) -> Void in
        }
    }
}
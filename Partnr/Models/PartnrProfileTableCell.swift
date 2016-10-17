//
//  PartnrProfileTableCell.swift
//  Partnr
//
//  Created by Yosemite on 4/17/16.
//  Copyright © 2016 YulianMobile. All rights reserved.
//

import UIKit

import ParseUI

class PartnrProfileTableCell: UITableViewCell {

    @IBOutlet weak var avatarImage: PFImageView!
    @IBOutlet weak var backImage: PFImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var projectnameLabel: UILabel!
    @IBOutlet weak var professionLabel: UILabel!
    @IBOutlet weak var ratingView: FloatRatingView!
    @IBOutlet weak var reviewLabel: UILabel!
    @IBOutlet weak var avatarButton: UIButton!
    
    var projectData: ProjectData? = nil
    var rateData: PFObject? = nil
    var partnrUserData: UserData? = nil
    var userId: String? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // Update Content
    func processContent(projectData: ProjectData) {
        self.projectData = projectData
        
        self.professionLabel.text = projectData.profession
        self.projectnameLabel.text = projectData.name
        
        self.backImage.file = projectData.image
        self.backImage.loadInBackground { (image, error) -> Void in
        }
        
        // Update UserInfo
        if self.partnrUserData == nil {
            if self.userId == projectData.partnrId {
                self.projectData!.updateUserData({ (userData, error) -> Void in
                    self.partnrUserData = userData
                    self.loadAvatarImage()
                })
            } else {
                self.projectData!.updatePartnrData({ (userData, error) -> Void in
                    self.partnrUserData = userData
                    self.loadAvatarImage()
                })
            }
        } else {
            self.loadAvatarImage()
        }
        
        if self.rateData == nil {
            let userId = self.userId == projectData.partnrId ? projectData.userId : projectData.partnrId
            PNAPIClient.sharedInstance.getRateDataFromPartnrId(userId, projectId: projectData.id, callback: { (rateObj, error) -> Void in
                if rateObj != nil && error == nil {
                    self.rateData = rateObj
                    self.loadPartnrRate()
                }
            })
        } else {
            self.loadPartnrRate()
        }
        
    }

    func loadAvatarImage() {
        if let userData = self.partnrUserData {
            self.usernameLabel.text = userData.name
            
            self.avatarImage.file = userData.avatarImg
            self.avatarImage.loadInBackground { (image, error) -> Void in
            }
        }
    }
    
    func loadPartnrRate() {
        if let rateData = self.rateData {
            self.ratingView.rating = rateData["rate"].floatValue
            self.reviewLabel.text = rateData["review"].stringValue
        }
    }
}

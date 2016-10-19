//
//  ProjectTableCell.swift
//  Partnr
//
//  Created by Yulian Simeonov on 2/18/16.
//  Copyright © 2016 YulianMobile. All rights reserved.
//

import UIKit
import ParseUI

class ProjectTableCell: UITableViewCell {

    @IBOutlet weak var shadowImage: PFImageView!
    @IBOutlet weak var projectImage: PFImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var professionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var creatorLabel: UILabel!
    @IBOutlet weak var dayagoLabel: UILabel!
    
    // Only Available for MyProject Tab
    @IBOutlet weak var projectStatusImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func statusImage(projectData: ProjectData) -> UIImage {
        if projectData.userId == PFUser.currentUser()?.objectId {
            return UIImage.init(named: "myproject-status-admin")!
        } else if projectData.status == .Pending || projectData.status == .WaitingForFunding {
            return UIImage.init(named: "myproject-status-pending")!
        } else if projectData.status == .InProgress {
            return UIImage.init(named: "myproject-status-inprogress")!
        } else if projectData.status == .Completed {
            return UIImage.init(named: "myproject-status-completed")!
        } else if !projectData.briefUserId.isEmpty {
            return UIImage.init(named: "myproject-status-newBrief")!
        }
        return UIImage()
    }
    
    // Update Content
    func processContent(projectData: ProjectData) {
        self.nameLabel.text = projectData.name
        self.professionLabel.text = projectData.profession
        self.priceLabel.text = NSString.init(format: "$%.02f", projectData.price) as String
        if self.dayagoLabel != nil {
            self.dayagoLabel.text = projectData.dueDate.timeAgoSimple()
        }
        
        self.projectImage.file = projectData.image
        self.projectImage.loadInBackground { (image, error) -> Void in
            self.shadowImage.image = image
        }
        
        if self.projectStatusImage != nil {
            self.projectStatusImage.image = self.statusImage(projectData)
        }
    }

}

//
//  ApplicantTableCell.swift
//  Partnr
//
//  Created by Yulian Simeonov on 2/28/16.
//  Copyright © 2016 YulianMobile. All rights reserved.
//

import UIKit

import ParseUI

class ApplicantTableCell: UITableViewCell {
    
    @IBOutlet weak var avatarImage: PFImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var shadowImage: PFImageView!
    @IBOutlet weak var hiremeButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    
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
        self.avatarImage.file = userData.avatarImg
        self.avatarImage.loadInBackground { (image, error) -> Void in
            self.shadowImage.image = image
        }
        
        
    }

}

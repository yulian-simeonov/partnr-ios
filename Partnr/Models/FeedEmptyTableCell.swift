//
//  FeedTableCell.swift
//  Partnr
//
//  Created by Yosemite on 2/12/16.
//  Copyright © 2016 YulianMobile. All rights reserved.
//

import UIKit

class FeedEmptyTableCell: UITableViewCell {
    
    @IBOutlet weak var emptyImage: UIImageView!
    
    override func awakeFromNib() {
        
    }
    
    func putEmptyImage(image: UIImage) {
        emptyImage.image = image
    }
    
}
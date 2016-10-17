//
//  FeedBaseTableCell.swift
//  Partnr
//
//  Created by Yosemite on 3/8/16.
//  Copyright © 2016 YulianMobile. All rights reserved.
//

import UIKit

class FeedBaseTableCell: UITableViewCell {

    @IBOutlet weak var likesButton: UIButton!
    @IBOutlet weak var commentsButton: UIButton!
    @IBOutlet weak var dotsButton: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var profileButton: UIButton!

    @IBOutlet weak var captionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

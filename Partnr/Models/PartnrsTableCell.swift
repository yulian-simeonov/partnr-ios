//
//  PartnrsTableCell.swift
//  Partnr
//
//  Created by Yosemite on 2/12/16.
//  Copyright © 2016 YulianMobile. All rights reserved.
//

import UIKit

import ParseUI

class PartnrsTableCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var viewPartnrButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var isFollowers = false
    var userData: UserData? = nil
    var partnrArray = [String]()
    var partnrUserDict = NSMutableDictionary()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func proceedContent(partnrs: [String]) {
        partnrArray = partnrs
        collectionView.reloadData()
    }
    
    // MARK: - UICollectcionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return partnrArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PartnrsCell", forIndexPath: indexPath)
        
        let profileImage = cell.viewWithTag(1) as! PFImageView
        let activity = cell.viewWithTag(2) as! UIActivityIndicatorView
        activity.hidden = false
        
        
        activity.startAnimating()
        
        let userData = partnrUserDict[partnrArray[indexPath.row]] as? UserData
        
        if (userData == nil) {
            let pointer = PFUser.init(withoutDataWithClassName: "_User", objectId: partnrArray[indexPath.row])
            PNAPIClient.sharedInstance.fetchUser(pointer, callback: { (userData, error) -> Void in
                self.partnrUserDict.setObject(userData!, forKey: self.partnrArray[indexPath.row])
                self.loadAvatar(userData?.avatarImg!, imageView: profileImage, activity: activity)
            })
        } else {
            self.loadAvatar(userData?.avatarImg!, imageView: profileImage, activity: activity)
        }
        
        return cell
    }
    
    func loadAvatar(imageFile: PFFile?, imageView: PFImageView, activity: UIActivityIndicatorView) {
        if imageFile != nil {
            imageView.file = imageFile
            imageView.loadInBackground({ (image, error) -> Void in
                activity.stopAnimating()
                activity.hidden = true
            })
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let wid = CGFloat(SCRN_WIDTH - 40) / 4
        return CGSizeMake(wid, wid)
    }

}

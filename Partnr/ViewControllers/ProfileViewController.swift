//
//  ProfileViewController.swift
//  Partnr
//
//  Created by Yosemite on 2/10/16.
//  Copyright © 2016 YulianMobile. All rights reserved.
//

import UIKit

import ParseUI

class BriefTableCell: UITableViewCell {

    @IBOutlet weak var professionLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
}


class ProfileViewController: CustomBaseViewController, CKRadialMenuDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {

    var cameraMenu: CKRadialMenu!
    
    var userData = UserData()
    var photoShareDialog: ModalDialogViewController!
    
    @IBOutlet weak var avatarArea: UIView!
    @IBOutlet weak var segmentBar: UIView!
    @IBOutlet weak var segmentView: UIView!
    @IBOutlet weak var segmentBarCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var seg1CenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var seg2CenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var seg1Button: UIButton!
    @IBOutlet weak var seg2Button: UIButton!
    
    @IBOutlet weak var avatarBackImage: UIImageView!
    @IBOutlet weak var avatarImage: PFImageView!
    @IBOutlet weak var profileTable: UITableView!
    @IBOutlet weak var tableBtmConstraint: NSLayoutConstraint!
    @IBOutlet weak var overView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
 
    @IBOutlet weak var sendBriefButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var cameraShotButton: UIButton!
    @IBOutlet weak var rateButton: UIButton!
    
    @IBOutlet weak var mapImage: UIImageView!
    @IBOutlet weak var viewWebButton: UIButton!
    
    @IBOutlet weak var availButton: UIButton!
    var imagePicker: UIImagePickerController!
    
    var curSegment = 1
    private let photoCellIdentifier = "PhotoFeedCell"
    private let emptyCellIdentifier = "EmptyFeedCell"

    var newsArray = NSMutableArray()
    var selIndex = 0
    var partnrsArray: NSArray!
    var userType: EUserType = .Follower
    var isEditMode = false
    var isMe = false
    var isAvatarChanged = false
    var isPostUpload = false
    var gestureRecognizer: UITapGestureRecognizer? = nil
    
    var bioTextView: UITextView? = nil
    var professionTextField: UITextField? = nil
    var locationTextField: UITextField? = nil
    var websiteTextField: UITextField? = nil

    var followingArray = []
    var followerArray = []
    var partnrArray = [ProjectData]()
    
    var aboutShowCells = ["BriefCell"]
    var aboutEditCells = ["AboutCell", "AboutCell", "AboutCell", "BioCell"]
    var peopleCells = ["PartnrCell"]

    override func viewDidLoad() {
        super.viewDidLoad()

        profileTable.tableFooterView = UIView()
        
        imagePicker = UIImagePickerController.init()
        imagePicker.delegate = self
        // Do any additional setup after loading the view.
        self.moveSegmentBar()
        self.configureUI()
        self.updateContent()
        self.updateFollowingInfo()
        partnrsArray = ["", "", "", "", "", "", ""]
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.reloadNewsFeed()
        self.availButton.selected = SharedDataManager.sharedInstance.userData.isAvailable
        
        // Listen for changes to keyboard visibility so that we can adjust the text view accordingly.
        let notificationCenter = NSNotificationCenter.defaultCenter()
        
        notificationCenter.addObserver(self, selector: "handleKeyboardNotification:", name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: "handleKeyboardNotification:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateAvatarImage() {
        avatarImage.file = userData?.avatarImg
        avatarImage.loadInBackground { (image, error) -> Void in
            self.avatarBackImage .setImageToBlur(self.avatarImage.image, blurRadius: 0.9) { () -> Void in
                
            }
        }
    }
    
    func reloadNewsFeed() {
        PNAPIClient.sharedInstance.feedNews(userData?.id, newsType: .Photo, callback: { (nsData, error) -> Void in
            self.newsArray = NSMutableArray.init(array: nsData as! NSArray)
            self.profileTable.reloadData()

        })
    }
    
    func configureUI() {
        
//        cameraMenu = CKRadialMenu.init(frame: CGRectMake(SCRN_WIDTH-20-66, SCRN_HEIGHT-20-66-66, 66, 66))
//        cameraMenu.delegate = self
//        cameraMenu.addPopoutView(nil, withIndentifier: "Camera")
//        cameraMenu.addPopoutView(nil, withIndentifier: "Library")
//        //        cameraMenu.enableDevelopmentMode()
//        cameraMenu.distanceBetweenPopouts = 74.4
//        cameraMenu.startAngle = -82.16
//        cameraMenu.distanceFromCenter = 84.29
//        self.view.addSubview(cameraMenu)
        
        var frame = overView.frame
        frame.size.height = SCRN_WIDTH / 375 * 200 + 35
        overView.frame = frame
        
        avatarImage.layer.cornerRadius = 3
        
        profileTable.tableFooterView = UIView()
        
        self.gestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("handleTap:"))
        self.gestureRecognizer?.delegate = self
        self.avatarArea.addGestureRecognizer(self.gestureRecognizer!)
        self.profileTable.userInteractionEnabled = true
    }
    
    func updateFollowingInfo() {
        if !isMe {
            PNAPIClient.sharedInstance.checkIfFollow(PFUser.currentUser()!.objectId!, toUserId: userData!.id) { (isFollowed, error) -> Void in
//                self.followButton.selected = isFollowed
            }
        }
        
        let userId = isMe ? PFUser.currentUser()!.objectId! : userData?.id
        
        PNAPIClient.sharedInstance.fetchFollowing(userId!, callback:{ (succeed, followArray, error) -> Void in
            if succeed {
                self.followingArray = followArray!
                self.profileTable.reloadData()
            }
        })
        PNAPIClient.sharedInstance.fetchFollowers(userId!, callback: { (succeed, followArray, error) -> Void in
            if succeed {
                self.followerArray = followArray!
                self.profileTable.reloadData()
            }
        })
        
        PNAPIClient.sharedInstance.fetchPartnrProject(userId!, callback:{ (succeed, projectArray, error) -> Void in
            SVProgressHUD.dismiss()
            if succeed {
                self.partnrArray = projectArray!
                self.profileTable.reloadData()
            }
        })
    }
    
    func updateContent() {
        // Fill content
        cameraShotButton.layer.cornerRadius = 2.5
        
        if userData != nil {
            professionTextField?.text = userData!.profession
            nameLabel.text = userData!.name
            
            PNAPIClient.sharedInstance.getLatestRateFromUserId(userData!.id, callback: { (rate, error) -> Void in
                self.rateButton.setTitle(NSString(format: "%.01f", rate) as String, forState: .Normal)
                
                NSNotificationCenter.defaultCenter().postNotificationName(kNotiRefreshSideMenu, object: nil)
            })
//            usernameLabel.text = userData!.userName
            
            isMe = PFUser.currentUser()?.objectId == userData!.id
            if isMe {
                editProfileButton.hidden = false
                sendBriefButton.hidden = true
//                followButton.hidden = true
//                cameraShotButton.hidden = false
            } else {
                sendBriefButton.hidden = false
                editProfileButton.hidden = true
//                followButton.hidden = false
//                cameraShotButton.hidden = true
            }
            
            self.updateAvatarImage()
        }
    }
    
    // MARK: - UI Functions
    func moveSegmentBar() {
        
        segmentBarCenterConstraint.constant = curSegment == 1 ? seg1CenterConstraint.constant : seg2CenterConstraint.constant
        UIView.animateWithDuration(0.5) { () -> Void in
            self.segmentView.layoutIfNeeded()
        }
    }
    
    // MARK: - CKRadialMenuDelegate
    func radialMenu(radialMenu: CKRadialMenu!, didSelectPopoutWithIndentifier identifier: String!) {
        isPostUpload = true
        if identifier == "Camera" {
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .Camera
            
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
        } else if identifier == "Library" {
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .PhotoLibrary
            
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        picker .dismissViewControllerAnimated(true) { () -> Void in
            
            let wid = SCRN_WIDTH * 1.5
            let hei = image.size.height * (wid / image.size.width)
            
//            let resizedImage = imageResizeCoreGraphics(image, size: CGSizeMake(wid, hei))
            let resizedImage = image.imageByScalingAndCroppingForSize(CGSizeMake(wid, hei))
            if resizedImage != nil {
                if self.isPostUpload {
                    self.photoShareDialog = ModalDialogViewController.showDialogWithType(EDialogType.SharePhoto, delegate: self) { (nsData, error) -> Void in
                        self.reloadNewsFeed()
                    }
                    self.photoShareDialog.addPhoto(resizedImage!)
                } else {
                    self.isAvatarChanged = true
                    self.userData?.avatarImg = PFFile.init(data: UIImageJPEGRepresentation(resizedImage!, 1.0)!)
//                    self.updateAvatarImage()
                    self.avatarImage.image = resizedImage
                }
            } else {
                Utilities.showMsg("Invalid photo, please try again", delegate: self)
            }
            //            self.performSelector(Selector("addPhotoToDialog:"), withObject: image, afterDelay: 2)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - UIButton Action
    @IBAction func onClickSegment(sender: AnyObject) {
        
        curSegment = sender.tag
        
        if curSegment == 1 {
            seg1Button.selected = true
            seg2Button.selected = false
        } else {
            seg1Button.selected = false
            seg2Button.selected = true
        }
        
        if curSegment == 2 && isEditMode == false {
            mapImage.hidden = false
            viewWebButton.hidden = false
            tableBtmConstraint.constant = 40
        } else {
            mapImage.hidden = true
            viewWebButton.hidden = true
            tableBtmConstraint.constant = -15
        }
        
        self.moveSegmentBar()
        
        profileTable.reloadData()
    }
    @IBAction func onClickFollow(sender: UIButton) {
        SVProgressHUD.show()
        
        if sender.selected == true {
            PNAPIClient.sharedInstance.unfollowToUserId(userData!.id) { (succeed, error) -> Void in
                SVProgressHUD.dismiss()

                if succeed {
                    sender.selected = false
                    
                    self.updateFollowingInfo()
                }
            }
        } else {
            PNAPIClient.sharedInstance.followToUserId(userData!.id) { (succeed, error) -> Void in
                SVProgressHUD.dismiss()

                if succeed {
                    sender.selected = true

                    self.updateFollowingInfo()
                }
            }
        }
    }
    
    @IBAction func onClickViewWebSite(sender: AnyObject) {
        var url = NSURL.init(string: userData!.website)
        if !userData!.website.hasPrefix("http://") && !userData!.website.hasPrefix("https://") {
            url = NSURL.init(string: "http://\(userData!.website)")
        }

        UIApplication.sharedApplication().openURL(url!)
    }
    
    @IBAction func onClickSendBrief(sender: AnyObject) {
        
        let postProjectVC = self.storyboard?.instantiateViewControllerWithIdentifier("SendBriefVC") as! SendBriefViewController
        postProjectVC.briefUserData = userData
        self.navigationController?.pushViewController(postProjectVC, animated: true)
    }
    
    @IBAction func onClickEditProfile(sender: AnyObject) {
        isEditMode = !isEditMode
        
        if !isEditMode { // Save Profile
            if locationTextField != nil {
                PFUser.currentUser()?.setObject(locationTextField!.text!, forKey: "locationName")
            }
            if bioTextView != nil {
                PFUser.currentUser()?.setObject(bioTextView!.text!, forKey: "bio")
            }
            if websiteTextField != nil {
                PFUser.currentUser()?.setObject(websiteTextField!.text!, forKey: "website")
            }
            if professionTextField != nil {
                PFUser.currentUser()?.setObject(professionTextField!.text!, forKey: "profession")
            }
            if isAvatarChanged {
                let avatarFile = PFFile.init(name: "avatar.png", data: UIImageJPEGRepresentation(avatarImage.image!, 1.0)!)
                PFUser.currentUser()?.setObject(avatarFile!, forKey: "avatarImg")
            }
            SVProgressHUD.show()
            PFUser.currentUser()?.saveInBackgroundWithBlock({ (finished, error) -> Void in
                print(error)
                SVProgressHUD.dismiss()
                if finished && error == nil {
                    self.userData = UserData .initWithParseObject(PFUser.currentUser())
                    SharedDataManager.sharedInstance.userData = self.userData
                    self.updateContent()
                    self.profileTable.reloadData()
                    
                    if self.bioTextView?.text.isEmpty == false && self.websiteTextField?.text?.isEmpty == false && self.isAvatarChanged {
                        PNAPIClient.sharedInstance.shareCommunityToNews({ (finished, error) -> Void in
                            
                        })
                    }
                    
                } else {
                    Utilities.showMsg("Error occured! Please try again@", delegate: self)
                }
            })
            viewWebButton.hidden = false
        } else {
            viewWebButton.hidden = true
            self.profileTable.reloadData()

            if CLLocationManager.locationServicesEnabled() {
//                APPDELGATE.startLocationTracking()
                
                let ceo = CLGeocoder.init()
                let loc = CLLocation.init(latitude: APPDELGATE.locationTracker.myLocation.latitude, longitude: APPDELGATE.locationTracker.myLocation.longitude)
                SVProgressHUD.show()
                ceo.reverseGeocodeLocation(loc, completionHandler: { (placeMarks, error) -> Void in
                    SVProgressHUD.dismiss()
                    
                    if error != nil {
                        Utilities.showMsg("Failed, Please try again!", delegate: self)
                    } else {
                        let placeMark = placeMarks![0]
                        if Utilities.isValidData(placeMark.locality) == false {
                            Utilities.showMsg("Failed, Please try again!", delegate: self)
                            return
                        }
                        let adminArea = placeMark.administrativeArea == nil ? "" : placeMark.administrativeArea!
                        let locality = placeMark.locality == nil ? "" : placeMark.locality!
                        if self.locationTextField != nil {
                            self.locationTextField!.text = "\(locality), \(adminArea)"
                        }
                    }
                })
            } else {
                Utilities.showMsg("Locatin is not enabled! Please go to Settings and enable it!", delegate: self)
                return
            }
            
        }
        
        editProfileButton.selected = isEditMode
//        if websiteTextField != nil {
//            locationTextField!.userInteractionEnabled = isEditMode
//        }
        if professionTextField != nil {
            professionTextField!.userInteractionEnabled = isEditMode
        }
        if bioTextView != nil {
            bioTextView!.userInteractionEnabled = isEditMode
        }
        if websiteTextField != nil {
            websiteTextField!.userInteractionEnabled = isEditMode
        }
        
        tableBtmConstraint.constant = -15
    }
    
    func showProfessionList() {
        if !isEditMode {
            return
        }
        
        if !isEditMode {
            return
        }
        isPostUpload = false
        // 1
        let optionMenu = UIAlertController(title: nil, message: "Choose Profession", preferredStyle: .ActionSheet)
        
        let array = PROF_LIST
        for i in 0 ... array.count-1 {
            let action = UIAlertAction(title: array[i], style: .Default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.professionTextField?.text = array[i]
            })
            
            optionMenu.addAction(action)
        }
        
        //
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        optionMenu.addAction(cancelAction)
        
        // 5
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    @IBAction func onClickCamera(sender: AnyObject) {
        
        if !isEditMode {
            return
        }
        isPostUpload = false
        // 1
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .ActionSheet)
        
        // 2
        let deleteAction = UIAlertAction(title: "Camera", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            
        })
        let saveAction = UIAlertAction(title: "Photo Library", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .PhotoLibrary
            
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
            
        })
        
        //
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        
        // 4
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(saveAction)
        optionMenu.addAction(cancelAction)
        
        // 5
        self.presentViewController(optionMenu, animated: true, completion: nil)
        
    }
    
// MARK: - Table UIButton Action
    func onClickViewPartnr(sender: UIButton) {
        userType = .Partnr
        self.performSegueWithIdentifier("ShowUserListVC", sender: self)
    }
    
    func onClickWebsite(sender: UIButton) {
        let url = NSURL.init(string: sender.titleForState(.Normal)!)
        UIApplication.sharedApplication().openURL(url!)
    }
    
    func onClickFollower(sender: UIButton) {
        userType = .Follower
        self.performSegueWithIdentifier("ShowUserListVC", sender: self)
    }
    
    func onClickFollowing(sender: UIButton) {
        userType = .Following
        self.performSegueWithIdentifier("ShowUserListVC", sender: self)
    }
    
    @IBAction func onClickViewMore(sender: AnyObject) {
        
        selIndex = sender.tag
        self.performSegueWithIdentifier("ShowNewsDetailVC", sender: self)
    }
    
    @IBAction func onClickDots(sender: AnyObject) {
        
        selIndex = sender.tag
        let newsData = newsArray[sender.tag] as! NewsData
        
        // 1
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        // 2
        let isCreator = newsData.userId == PFUser.currentUser()?.objectId
        
        let deleteAction = UIAlertAction(title: isCreator ? "Delete this post" : "Report this post", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            if isCreator {
                SVProgressHUD.show()
                PNAPIClient.sharedInstance.deleteNews(newsData.id, callback: { (finished, error) -> Void in
                    SVProgressHUD.dismiss()
                    self.reloadNewsFeed()
                })
            }
        })
        
        //
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        
        // 4
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(cancelAction)
        
        // 5
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    func onClickLike(sender: UIButton) {
        let newsData = newsArray[sender.tag] as! NewsData
        sender.enabled = false
        if sender.selected {
            PNAPIClient.sharedInstance.postUnLike(newsData.id, callback: { (succeed, error) -> Void in
                sender.enabled = true
                newsData.isLikeUpdated = false
                self.profileTable.reloadRowsAtIndexPaths([NSIndexPath.init(forRow: 0, inSection: sender.tag)], withRowAnimation: UITableViewRowAnimation.None)
            })
        } else {
            PNAPIClient.sharedInstance.postLike(newsData.id, callback: { (succeed, likeData, error) -> Void in
                sender.enabled = true
                newsData.isLikeUpdated = false
                self.profileTable.reloadRowsAtIndexPaths([NSIndexPath.init(forRow: 0, inSection: sender.tag)], withRowAnimation: UITableViewRowAnimation.None)
            })
        }
    }
    
    @IBAction func onClickFindPartnr(sender: AnyObject) {
        ModalDialogViewController.showDialogWithType(EDialogType.FindPartnr, delegate: self) { (nsData, error) -> Void in
            
            SharedDataManager.sharedInstance.isFirstToProjectFeed = false
            
            let response = nsData!["response"].intValue
            if response == 1 { // Search partnr
                let profession = nsData!["profession"].stringValue
                let searchPartnrVC = self.storyboard?.instantiateViewControllerWithIdentifier("SelectPartnrVC") as! SelectPartnrViewController
                searchPartnrVC.profession = profession
                self.navigationController?.pushViewController(searchPartnrVC, animated: true)
            } else if response == 2 { // Create new project
                let postProjectVC = self.storyboard?.instantiateViewControllerWithIdentifier("PostProjectVC") as! PostProjectViewController
                self.navigationController?.pushViewController(postProjectVC, animated: true)
            } else if response == 3 { // View the community
                SharedDataManager.sharedInstance.rootVC.showCommunityView()
            }
        }
    }
    // MARK: - UITableViewDataSource, UITableViewDelegate
    
    func tableView(_tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if cell.respondsToSelector("setSeparatorInset:") {
            cell.separatorInset = UIEdgeInsetsMake(0, 8, 0, 8)
        }
        if cell.respondsToSelector("setLayoutMargins:") {
            cell.layoutMargins = UIEdgeInsetsZero
        }
        if cell.respondsToSelector("setPreservesSuperviewLayoutMargins:") {
            cell.preservesSuperviewLayoutMargins = false
        }
    }
    
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int
    {
        print("Cell Count: \(curSegment == 2 ? isEditMode ? 4 : 1 : partnrArray.count > 0 ? partnrArray.count : 1)")
        return curSegment == 2 ? isEditMode ? 4 : 1 : partnrArray.count > 0 ? partnrArray.count : 1
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1;
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return curSegment == 1 ? 15 : 0
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let footerView = UIView.init(frame: CGRectMake(0, 0, SCRN_WIDTH, 15))
        footerView.backgroundColor = UIColor.whiteColor()
        
        
        return footerView
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        var hei = CGFloat(60)
//        if curSegment == 1 {
//            if newsArray.count == 0 { // Feed Tab
//                hei = tableView.frame.size.height - overView.frame.size.height;
//            } else {
//                hei = self.heightForIndexPath(indexPath)
//            }
//            
//            //        hei = hei > defaultHei ? hei : defaultHei
//        } else
        if curSegment == 1 { // PARTNR Tab
            hei = partnrArray.count > 0 ? max(143, self.heightWithCellAtIndexPath(indexPath)) : CGFloat(95)
        } else if curSegment == 2 { // STORY Tab
            hei = isEditMode ? indexPath.row == 3 ? 80 : 50 : max(60, self.heightWithCellAtIndexPath(indexPath))
            
        }
        return hei
    }
    
    func heightForIndexPath(indexPath: NSIndexPath) -> CGFloat {
        var hei = CGFloat(0)
        let newsData = newsArray[indexPath.section] as! NewsData
        if newsData.type == .Photo {
            hei = SCRN_WIDTH + CGFloat(76)
        }
        return hei
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var hei = CGFloat(60)
        if curSegment == 1 {
            hei = self.heightWithCellAtIndexPath(indexPath)
        //        hei = hei > defaultHei ? hei : defaultHei
        }
        return hei
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var identifier = newsArray.count == 0 ? emptyCellIdentifier : photoCellIdentifier;
        
        if curSegment == 1 {
            identifier = partnrArray.count > 0 ? "PartnrCell" : "EmptyCell"
        } else if curSegment == 2 {
            identifier = isEditMode ? aboutEditCells[indexPath.row] : aboutShowCells[0]
        }
        
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath)
        
        if cell.isKindOfClass(PhotoFeedTableCell) {
            let newsData = newsArray[indexPath.section] as! NewsData
            let feedCell = (cell as! PhotoFeedTableCell)
            
            feedCell.likesButton.tag = indexPath.section
            feedCell.dotsButton.tag = indexPath.section
            
            feedCell.likesButton.addTarget(self, action: Selector("onClickLike:"), forControlEvents: .TouchUpInside)
            feedCell.dotsButton.addTarget(self, action: Selector("onClickDots:"), forControlEvents: .TouchUpInside)
            
            feedCell.proceeedContent(newsData)
            
            // Update Comment Count
            
            if !newsData.isCommentUpdated {
                newsData.updateCommentInfoWithCallback({ (commentCount) -> Void in
                    feedCell.commentLabel.text = "\(commentCount)"
                    //                    feedCell.buildCommentsContainer(newsData)
                    //                    tableView.endUpdates()
                })
            } else {
                feedCell.commentLabel.text = "\(newsData.commentCount)"
                //                feedCell.buildCommentsContainer(newsData)
            }
            
            if !newsData.isLikeUpdated {
                newsData.updateLikeInfoWithCallback({ (likeCount, isLiked) -> Void in
                    print("\(indexPath.section) = \(likeCount)")
                    
                    newsData.isLiked = isLiked
                    feedCell.likesButton.selected = isLiked
                    
                    feedCell.likeLabel.text = "\(likeCount)"
                    tableView.endUpdates()
                })
            } else {
                print("newsData: \(indexPath.section) = \(newsData.likeCount)")
                feedCell.likeLabel.text = "\(newsData.likeCount)"
                feedCell.likesButton.selected = newsData.isLiked
            }
            
        } else if identifier == "BioCell" {
            bioTextView = cell.viewWithTag(1) as? UITextView
            bioTextView?.delegate = self
            bioTextView?.text = userData?.bio
//            bioTextView?.userInteractionEnabled = isEditMode
        } else if identifier == "AboutCell" {
            let textField = cell.viewWithTag(1) as? UITextField
            if indexPath.row == 0 {
                textField?.text = userData?.profession
                professionTextField = textField
            } else if indexPath.row == 1 {
                textField?.text = userData?.locationName
                locationTextField = textField
            } else if indexPath.row == 2 {
                textField?.text = userData?.website
                websiteTextField = textField
            }
            
            textField?.delegate = self
            textField?.userInteractionEnabled = isEditMode
            
            locationTextField?.userInteractionEnabled = true
        } else if identifier == "ButtonCell" {
            let followerButton = cell.viewWithTag(1) as! UIButton
            let followingButton = cell.viewWithTag(2) as! UIButton
            let followerLabel = cell.viewWithTag(11) as! UILabel
            let followingLabel = cell.viewWithTag(12) as! UILabel
//            followerButton.selected = isFollowers
//            followingButton.selected = !isFollowers
            followerLabel.text = "\(followerArray.count)"
            followingLabel.text = "\(followingArray.count)"
            
            followerButton .addTarget(self, action: Selector("onClickFollower:"), forControlEvents: .TouchUpInside)
            followingButton .addTarget(self, action: Selector("onClickFollowing:"), forControlEvents: .TouchUpInside)
            
        } else if identifier == "PartnrCell" {
            let partnrsCell = (cell as! PartnrProfileTableCell)
            partnrsCell.userId = self.userData!.id
            partnrsCell.processContent(partnrArray[indexPath.row])
            partnrsCell.avatarButton.addTarget(self, action: Selector("onClickAvatar:"), forControlEvents: .TouchUpInside)
            partnrsCell.avatarButton.tag = indexPath.row
        } else if identifier == "BriefCell" {
            let briefCell = (cell as! BriefTableCell)
            briefCell.professionLabel.text = userData?.profession
            briefCell.locationLabel.text = userData?.locationName
            briefCell.bioLabel.text = userData?.bio
        } else if identifier == "BioShowCell" {
            let bioLabel = cell.viewWithTag(1) as? UILabel
            bioLabel?.text = userData?.bio
        }
        
        return cell
    }
    
    func onClickAvatar(sender: UIButton) {
        
        let projectData = partnrArray[sender.tag]
        let userId = self.userData!.id == projectData.partnrId ? projectData.userId : projectData.partnrId
        
        SVProgressHUD.show()
        PNAPIClient.sharedInstance.fetchUser(PFUser.init(withoutDataWithClassName: "_User", objectId: userId), callback: { (userData, error) -> Void in
            SVProgressHUD.dismiss()
            if error == nil && userData != nil {
                let profileVC = self.storyboard?.instantiateViewControllerWithIdentifier("ProfileVC") as! ProfileViewController
                profileVC.userData = userData
                self.navigationController?.pushViewController(profileVC, animated: true)
            }
        })
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
//        if curSegment == 1 && newsArray.count > 0 {
//            selIndex = indexPath.section
//            self.performSegueWithIdentifier("ShowNewsDetailVC", sender: self)
//        } else
//        if curSegment == 2 && indexPath.row == 1 {
//            if (Utilities.isValidUrl(websiteTextField?.text)) {
//                let url = NSURL.init(string: websiteTextField!.text!)
//                UIApplication.sharedApplication().openURL(url!)
//            } else {
//                Utilities.showMsg("Invalid url", delegate: self)
//            }
//        }
    }
    
    //------------------ Dynamic Cell Height --------------------------//
    
    // MARK: - UITableView Calc Height
    func heightWithCellAtIndexPath(indexPath: NSIndexPath) -> CGFloat {
        
        let identifier = curSegment
            == 1 ? "PartnrCell" : "BriefCell"
        
        
        var sizingCell: UITableViewCell!
        var onceToken: dispatch_once_t = 0
        dispatch_once(&onceToken) { () -> Void in
            sizingCell = self.profileTable.dequeueReusableCellWithIdentifier(identifier)
            if self.curSegment == 2 {
                (sizingCell as! BriefTableCell).bioLabel.text = self.userData?.bio
            } else if self.curSegment == 1 {
                let partnrCell = sizingCell as! PartnrProfileTableCell
                if let rateData = partnrCell.rateData {
                    let review = rateData["review"] as? String
                    (sizingCell as! PartnrProfileTableCell).reviewLabel.text = review
                }
            }
        }
        
        return self.calculateHeightForConfiguredSizingCell(sizingCell)
    }
    
    func calculateHeightForConfiguredSizingCell(sizingCell: UITableViewCell) -> CGFloat {
        
        sizingCell.bounds = CGRectMake(0, 0, CGRectGetWidth(self.profileTable.frame), CGRectGetHeight(sizingCell.bounds))
        sizingCell.setNeedsLayout()
        sizingCell.layoutIfNeeded()
        
        let size: CGSize = sizingCell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        return size.height + 1
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if isEditMode == true && textField == professionTextField {
            self.showProfessionList()
            return false
        }
        if textField == locationTextField{
            locationTextField?.endEditing(true)
            bioTextView?.endEditing(true)
            websiteTextField?.endEditing(true)
        }
        return isEditMode
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField == locationTextField {
            return
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - UITextViewDelegate
    func textViewDidBeginEditing(textView: UITextView) {
        
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        
        return isEditMode
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
        }
        return true
    }
    
    func textViewDidEndEditing(textView: UITextView){
        textView.resignFirstResponder()
    }
    
    // MARK: -Gesture Recongnizer
    func handleTap(sender: UITapGestureRecognizer? = nil) {
        // handling code
            self.locationTextField?.resignFirstResponder()
            self.bioTextView?.resignFirstResponder()
            self.websiteTextField?.resignFirstResponder()
    }
    
    func handleKeyboardNotification(notification: NSNotification) {
        let userInfo = notification.userInfo!
        
        // Get information about the animation.
        let animationDuration: NSTimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        let rawAnimationCurveValue = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).unsignedLongValue
        let animationCurve = UIViewAnimationOptions(rawValue: rawAnimationCurveValue)
        
        // Convert the keyboard frame from screen to view coordinates.
        let keyboardScreenBeginFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        let keyboardViewBeginFrame = view.convertRect(keyboardScreenBeginFrame, fromView: view.window)
        let keyboardViewEndFrame = view.convertRect(keyboardScreenEndFrame, fromView: view.window)
        
        // Determine how far the keyboard has moved up or down.
        let originDelta = keyboardViewEndFrame.origin.y - keyboardViewBeginFrame.origin.y
        
        // Adjust the table view's scroll indicator and content insets.
        profileTable.scrollIndicatorInsets.bottom -= originDelta
        profileTable.contentInset.bottom -= originDelta
        
        // Inform the view that its the layout should be updated.
        profileTable.setNeedsLayout()
        
        // Animate updating the view's layout by calling layoutIfNeeded inside a UIView animation block.
        let animationOptions: UIViewAnimationOptions = [animationCurve, .BeginFromCurrentState]
        UIView.animateWithDuration(animationDuration, delay: 0, options: animationOptions, animations: {
            self.view.layoutIfNeeded()
            }, completion: nil)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "ShowUserListVC" {
            let destVC = segue.destinationViewController as! UserListViewController
            destVC.userType = userType
            destVC.userId = self.userData?.id
        }
    }

}

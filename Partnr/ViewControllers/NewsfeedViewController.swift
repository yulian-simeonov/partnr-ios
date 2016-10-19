//
//  NewsfeedViewController.swift
//  Partnr
//
//  Created by Yulian Simeonov on 1/30/16.
//  Copyright © 2016 YulianMobile. All rights reserved.
//

import UIKit
import ParseUI
import MessageUI



class NewsfeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CKRadialMenuDelegate, MFMailComposeViewControllerDelegate, TOCropViewControllerDelegate, UITextFieldDelegate {

    let photoCellIdentifier = "PhotoFeedCell"
    let partnrCellIdentifier = "PartnrFeedCell"
    let peopleCellIdentifier = "PeopleFeedCell"
    let noteCellIdentifier = "NoteFeedCell"
    let projectCellIdentifier = "ProjectCell"
    let communityCellIdentifier = "CommunityFeedCell"
    let userCellIdentifier = "UserCell"
    let emptyCellIdentifier = "EmptyFeedCell"
    
    var photoShareDialog: ModalDialogViewController!
    var isKeyboardShown = false
    var communityArray = [AnyObject]()
//    var newsArray = [NewsData]()
//    var projectsArray = [ProjectData]()
    var selIndex = 0
    
    var cameraMenu: CKRadialMenu!
    
    @IBOutlet weak var feedTable: UITableView!
    @IBOutlet weak var segmentBar: UIView!
    @IBOutlet weak var segmentView: UIView!
    
    @IBOutlet weak var searchTextField: NSCustomTextField!
    @IBOutlet weak var segmentBarCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var seg1CenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var seg2CenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var globalButton: UIButton!
    @IBOutlet weak var followButton: UIButton!
    
    var curSegment = 1
    var searchArray = NSArray()
    var isSearched = false
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        feedTable.registerNib(UINib.init(nibName: "PhotoFeedTableCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: photoCellIdentifier)
        feedTable.registerNib(UINib.init(nibName: "PartnrFeedTableCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: partnrCellIdentifier)
        feedTable.registerNib(UINib.init(nibName: "PeopleFeedTableCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: peopleCellIdentifier)
        feedTable.registerNib(UINib.init(nibName: "NoteFeedTableCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: noteCellIdentifier)
        feedTable.registerNib(UINib.init(nibName: "CommunityFeedTableCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: communityCellIdentifier)
        feedTable.registerNib(UINib.init(nibName: "FeedEmptyTableCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: emptyCellIdentifier)
        feedTable.registerNib(UINib.init(nibName: "UserCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: userCellIdentifier)

        // Do any additional setup after loading the view.
        self.shyNavBarManager.scrollView = self.feedTable
        self.shyNavBarManager.extensionView = self.segmentView;
//        self.shyNavBarManager.stickyExtensionView = true
//        self.moveSegmentBar()
        
        imagePicker.delegate = self
        imagePicker.navigationBar.translucent = false
        imagePicker.navigationBar.barTintColor = NAV_COLOR
        imagePicker.navigationBar.tintColor = UIColor.whiteColor()
        imagePicker.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName : UIColor.whiteColor()
        ]
        self.configureUI()
        
        NSNotificationCenter.defaultCenter().addObserverForName(kNotiRefreshNewsFeed, object: nil, queue: nil) { (noti) -> Void in
            
            self.reloadNewsFeed()
        }
        self.reloadNewsFeed()        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        searchTextField.resignFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadNewsFeed() {
        SVProgressHUD.show()
        PNAPIClient.sharedInstance.feedNews ("", callback: { (nsData, error) -> Void in
            SVProgressHUD.dismiss()
            
//            self.newsArray = nsData!.sort({ $0.createdAt.timeIntervalSince1970 > $1.createdAt.timeIntervalSince1970 })
            for newsData in nsData! {
                self.communityArray.append(newsData)
            }

            PNAPIClient.sharedInstance.feedOpenProject([]) { (projects, error) -> Void in
                SVProgressHUD.dismiss()
                if error == nil {
                    for projectData in projects! {
                        self.communityArray.append(projectData)
                    }
                    self.communityArray = self.communityArray.sort({ ($0 as! CommunityData).createdAt.timeIntervalSince1970 > ($1 as! CommunityData).createdAt.timeIntervalSince1970 })
//                    self.newsArray = nsData?.sort({ $0.createdAt.timeIntervalSince1970 > $1.createdAt.timeIntervalSince1970 })
//                    self.projectsArray = projects!.sort({ $0.createdAt.timeIntervalSince1970 > $1.createdAt.timeIntervalSince1970 })
                    self.feedTable.reloadData()
                }
            }
            self.feedTable.reloadData()
        })
    }
    
    func reloadAllProjects() {
        SVProgressHUD.show()
        PNAPIClient.sharedInstance.feedOpenProject([]) { (projects, error) -> Void in
            SVProgressHUD.dismiss()
            if error == nil {
//                self.projectsArray = projects!.sort({ $0.createdAt.timeIntervalSince1970 > $1.createdAt.timeIntervalSince1970 })
                self.feedTable.reloadData()
            }
        }
    }
    
    func configureUI() {
        
//        cameraMenu = CKRadialMenu.init(frame: CGRectMake(SCRN_WIDTH-20-66, SCRN_HEIGHT-20-66, 66, 66))
//        cameraMenu.delegate = self
//        cameraMenu.addPopoutView(nil, withIndentifier: "Camera")
//        cameraMenu.addPopoutView(nil, withIndentifier: "Library")
////        cameraMenu.enableDevelopmentMode()
//        cameraMenu.distanceBetweenPopouts = 74.4
//        cameraMenu.startAngle = -82.16
//        cameraMenu.distanceFromCenter = 84.29
//        self.view.addSubview(cameraMenu)
    }
    
    func doSearch(searchKey: String) {
        SVProgressHUD.show()
        PNAPIClient.sharedInstance.doSearch(searchKey) { (searchResult, error) -> Void in
            SVProgressHUD.dismiss()
            self.isSearched = true
            self.searchArray = searchResult!
            self.feedTable.reloadData()
        }
    }

    // MARK: - UIButton Action
    
    @IBAction func onClickSegment(sender: AnyObject) {
        
        curSegment = sender.tag
        
        if curSegment == 1 {
            globalButton.selected = true
            followButton.selected = false
            
            self.reloadNewsFeed()
        } else {
            globalButton.selected = false
            followButton.selected = true
            
            self.reloadAllProjects()
        }
        
        self.moveSegmentBar()
    }
    
    @IBAction func onClickCamera(sender: AnyObject) {
        
        // 1
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .ActionSheet)
        
        // 2
        let deleteAction = UIAlertAction(title: "Camera", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .Camera
            
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
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
    
    @IBAction func onClickProfile(sender: AnyObject) {
        selIndex = sender.tag
        self .performSegueWithIdentifier("ShowProfileVC", sender: self)
    }
    
    @IBAction func onClickViewMore(sender: AnyObject) {
        
        selIndex = sender.tag
        self.performSegueWithIdentifier("ShowNewsDetailVC", sender: self)
    }
    
    @IBAction func onClickDots(sender: AnyObject) {
        
        selIndex = sender.tag
        let newsData = self.communityArray[sender.tag] as! NewsData

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
            } else {
//                PNAPIClient.sharedInstance.deleteNews(newsData.id, callback: { (finished, error) -> Void in
//                    SVProgressHUD.dismiss()
//                })
                let emailTitle = "Report"
                let messageBody = "Report this post"
                let toRecipents = ["support@partnr.com"]
                let mc: MFMailComposeViewController = MFMailComposeViewController()
                mc.mailComposeDelegate = self
                mc.setSubject(emailTitle)
                mc.setMessageBody(messageBody, isHTML: false)
                mc.setToRecipients(toRecipents)
                
                self.presentViewController(mc, animated: true, completion: nil)
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
        let newsData = self.communityArray[sender.tag] as! NewsData
        sender.enabled = false
        if sender.selected {
            PNAPIClient.sharedInstance.postUnLike(newsData.id, callback: { (succeed, error) -> Void in
                sender.enabled = true
                newsData.isLikeUpdated = false
                
                let indexPath = NSIndexPath.init(forRow: 0, inSection: sender.tag)
                let curCell = self.feedTable.cellForRowAtIndexPath(indexPath) as! FeedBaseTableCell
                self.updateCellActions(curCell, indexPath: indexPath)
                
//                self.feedTable.reloadRowsAtIndexPaths([NSIndexPath.init(forRow: 0, inSection: sender.tag)], withRowAnimation: UITableViewRowAnimation.None)
            })
        } else {
            PNAPIClient.sharedInstance.postLike(newsData.id, callback: { (succeed, likeData, error) -> Void in
                sender.enabled = true
                newsData.isLikeUpdated = false
                
                let indexPath = NSIndexPath.init(forRow: 0, inSection: sender.tag)
                let curCell = self.feedTable.cellForRowAtIndexPath(indexPath) as! FeedBaseTableCell
                self.updateCellActions(curCell, indexPath: indexPath)
//                self.feedTable.reloadRowsAtIndexPaths([NSIndexPath.init(forRow: 0, inSection: sender.tag)], withRowAnimation: UITableViewRowAnimation.None)
            })
        }
    }
    
    func onClickComment(sender: UIButton) {
        selIndex = sender.tag
        self.performSegueWithIdentifier("ShowNewsDetailVC", sender: self)
    }
    
    // MARK: - MFMailComposeViewControllerDelegate
    func mailComposeController(controller:MFMailComposeViewController, didFinishWithRvesult result:MFMailComposeResult, error:NSError?) {
        switch result {
        case MFMailComposeResultCancelled: break
        case MFMailComposeResultSaved: break
        case MFMailComposeResultSent: break
        case MFMailComposeResultFailed: break
        default:
            break
        }
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    // MARK: - CropViewController
    func showImageCropView(image: UIImage) {
        let cropView = TOCropViewController.init(image: image)
        cropView.delegate = self
        self .presentViewController(cropView, animated: true, completion: nil)
    }
    
    // MARK: - CropViewControllerDelegate
    func cropViewController(cropViewController: TOCropViewController!, didCropToImage image: UIImage!, withRect cropRect: CGRect, angle: Int) {
        cropViewController .dismissViewControllerAnimated(true) { () -> Void in
            self.photoShareDialog = ModalDialogViewController.showDialogWithType(EDialogType.SharePhoto, delegate: self) { (nsData, error) -> Void in
                self.reloadNewsFeed()
            }
            self.photoShareDialog.addPhoto(image)
        }
    }
    
    // MARK: - CKRadialMenuDelegate
    func radialMenu(radialMenu: CKRadialMenu!, didSelectPopoutWithIndentifier identifier: String!) {
        if identifier == "Camera" {
            self.onClickCamera(UIButton())
//            self.imagePicker.allowsEditing = false
//            self.imagePicker.sourceType = .Camera
            
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
        } else if identifier == "Library" {
            ModalDialogViewController.showDialogWithType(EDialogType.ShareNote, delegate: self, callback: { (nsData, error) -> Void in
                if nsData != nil && error == nil {
                    self.reloadNewsFeed()
                }
            })
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        picker .dismissViewControllerAnimated(true) { () -> Void in
            
            let wid = SCRN_WIDTH * 1.5
            let hei = image.size.height * (wid / image.size.width)
            
            let resizedImage = image.imageByScalingAndCroppingForSize(CGSizeMake(wid, hei))
            if resizedImage != nil {
                self.showImageCropView(image)
            } else {
                Utilities.showMsg("Invalid photo, please try again", delegate: self)
            }
//            self.performSelector(Selector("addPhotoToDialog:"), withObject: image, afterDelay: 2)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - UI Functions
    func moveSegmentBar() {
        
        segmentBarCenterConstraint.constant = curSegment == 1 ? seg1CenterConstraint.constant : seg2CenterConstraint.constant
        UIView.animateWithDuration(0.5) { () -> Void in
            self.segmentView.layoutIfNeeded()
        }
    }
    
    // MARK: - UITableViewDataSource, UITableViewDelegate
                                                                                                                                                                                                                                
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int
    {
        if self.isSearched == true{
            if searchArray.count == 0 {
                return 1
            }
            return searchArray.count
        }
        else{
            return 1
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if self.isSearched == true{
            return 1
        }
        else{
//        if curSegment == 1 {
            return self.communityArray.count
//        } else {
//            return projectsArray.count
//        }
        }
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if self.isSearched == true{
            return 0
        }
        else{
            return 8
        }
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if self.isSearched == true{
            let footerView = UIView.init(frame: CGRectMake(0, 0, SCRN_WIDTH, 5))
            footerView.backgroundColor = UIColor.whiteColor()
            
            return footerView
        }
        else{
            let footerView = UIView.init(frame: CGRectMake(0, 0, SCRN_WIDTH, 15))
            footerView.backgroundColor = UIColor.whiteColor()
            
            return footerView
        }
    }
    
    func heightForIndexPath(indexPath: NSIndexPath) -> CGFloat {
        var hei = CGFloat(0)
        if let newsData = self.communityArray[indexPath.section] as? NewsData {
            if newsData.type == .Photo {
                hei = (SCRN_WIDTH-25) + CGFloat(70)
            } else if newsData.type == .Partnr {
                hei = 157
            } else if newsData.type == .Community {
                hei = 145
            } else {
                return max(120, self.heightWithCellAtIndexPath(indexPath))
            }
        }
        return hei
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if self.isSearched == true{
            if searchArray.count == 0 {
                return 392.0
            } else {
                return 81.0
            }
        }
        else{
            let communityData = self.communityArray[indexPath.section] as! CommunityData
            if communityData.communityType == .News {
                return self.heightForIndexPath(indexPath)
            } else {
                return 105
            }
        }
    }
    
//    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        
//        return self.heightForIndexPath(indexPath)
//    }
    
    func cellIdentifierForIndexPath(indexPath: NSIndexPath) -> String {
        if curSegment == 1 { // All Activity
            let newsData = self.communityArray[indexPath.section] as! NewsData
            var identifier = photoCellIdentifier
            
            switch newsData.type {
            case .Partnr:
                identifier = partnrCellIdentifier
                break
            case .People:
                identifier = peopleCellIdentifier
                break
            case .Note:
                identifier = noteCellIdentifier
                break
            case .Community:
                identifier = communityCellIdentifier
                break
            default:
                identifier = photoCellIdentifier
                break
            }
            return identifier
        } else {
            return projectCellIdentifier
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if self.isSearched == false{
            let communityData = self.communityArray[indexPath.section] as! CommunityData
            if communityData.communityType == .News {
                let newsData = self.communityArray[indexPath.section] as! NewsData

                let identifier = self.cellIdentifierForIndexPath(indexPath)
            
                let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath)
            
                self.updateCellActions(cell as! FeedBaseTableCell, indexPath: indexPath)
            
                if cell.isKindOfClass(PhotoFeedTableCell) {
                    let feedCell = (cell as! PhotoFeedTableCell)
                
                    feedCell.proceeedContent(newsData)
                
                    // Update Comment Count
                } else if cell.isKindOfClass(NoteFeedTableCell) {
                    let feedCell = (cell as! NoteFeedTableCell)
                    feedCell.proceeedContent(newsData)
                } else if cell.isKindOfClass(PeopleFeedTableCell) {
                    let feedCell = (cell as! PeopleFeedTableCell)
                    feedCell.proceeedContent(newsData)
                } else if cell.isKindOfClass(PartnrFeedTableCell) {
                    let feedCell = (cell as! PartnrFeedTableCell)
                    feedCell.proceeedContent(newsData)
                } else if cell.isKindOfClass(CommunityFeedTableCell) {
                    let feedCell = (cell as! CommunityFeedTableCell)
                    feedCell.proceeedContent(newsData)
                }
            
                return cell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier(projectCellIdentifier) as! ProjectTableCell
            
                let projectData = self.communityArray[indexPath.section] as! ProjectData
            
                cell.processContent(projectData)
            
                cell.priceLabel.text = NSString.init(format: "%.02f", projectData.price) as String
            
                if projectData.userData == nil {
                    projectData.updateUserData({ (userData, error) -> Void in
                        if error == nil {
                            cell.creatorLabel.text = "Posted by \(userData!.name)"
                        }
                    })
                } else {
                    cell.creatorLabel.text = "Posted by \(projectData.userData!.name)"
                }
                return cell
            }
        }
        else{
            if searchArray.count == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier(emptyCellIdentifier, forIndexPath: indexPath) as! FeedEmptyTableCell
                cell.putEmptyImage(UIImage.init(named: isSearched ? "img-emptySearch" : "img-desc-search")!)
                return cell
            } else {
                let searchItem = searchArray[indexPath.row]
                if searchItem.isKindOfClass(UserData) {
                    let cell = tableView.dequeueReusableCellWithIdentifier(userCellIdentifier, forIndexPath: indexPath) as! UserTableCell
                    cell.proceedContent(searchItem as! UserData)
                    return cell
                } else if searchItem.isKindOfClass(ProjectData) {
                    let cell = tableView.dequeueReusableCellWithIdentifier(projectCellIdentifier, forIndexPath: indexPath) as! ProjectTableCell
                    return cell
                }
            }
            return UITableViewCell.init()
        }
    }
    
    func updateCellActions(feedCell: FeedBaseTableCell, indexPath: NSIndexPath) {
//        let indexPath = self.feedTable.indexPathForCell(feedCell)
        let newsData = self.communityArray[indexPath.section] as! NewsData
        
        feedCell.likesButton.tag = indexPath.section
        //            feedCell.viewmoreButton.tag = indexPath.section
        feedCell.dotsButton.tag = indexPath.section
        
        if feedCell.profileButton != nil {
            feedCell.profileButton.tag = indexPath.section
        }
        
        feedCell.likesButton.addTarget(self, action: Selector("onClickLike:"), forControlEvents: .TouchUpInside)
        feedCell.dotsButton.addTarget(self, action: Selector("onClickDots:"), forControlEvents: .TouchUpInside)
        
        if feedCell.profileButton != nil {
            feedCell.profileButton.addTarget(self, action: Selector("onClickProfile:"), forControlEvents: .TouchUpInside)
        }
        
        feedCell.commentsButton.addTarget(self, action: Selector("onClickComment:"), forControlEvents: .TouchUpInside)
        
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
                feedCell.likeLabel.textColor = isLiked ? NAV_COLOR : UIColor.init(red: 136/255.0, green: 136/255.0, blue: 136/255.0, alpha: 1.0)
                
                feedCell.likeLabel.text = "\(likeCount)"
                self.feedTable.endUpdates()
            })
        } else {
            print("newsData: \(indexPath.section) = \(newsData.likeCount)")
            feedCell.likeLabel.text = "\(newsData.likeCount)"
            feedCell.likesButton.selected = newsData.isLiked
        }

    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if self.isSearched == true{
            selIndex = indexPath.row
            let selData = searchArray[selIndex]
            
            if selData.isKindOfClass(UserData) {
                self.performSegueWithIdentifier("ShowUserDetailVC", sender: self)
            } else if selData.isKindOfClass(ProjectData) {
                self.performSegueWithIdentifier("ShowProjectDetailVC", sender: self)
            }
        }
        else{
            let communityData = self.communityArray[indexPath.section] as! CommunityData
            if communityData.communityType == .News {
                selIndex = indexPath.section
                self.performSegueWithIdentifier("ShowNewsDetailVC", sender: self)
            } else {
                selIndex = indexPath.section
                self.performSegueWithIdentifier("ShowProjectDetailVC", sender: self)
            }
        }
    }

    //------------------ Dynamic Cell Height --------------------------//
    
    // MARK: - UITableView Calc Height
    func heightWithCellAtIndexPath(indexPath: NSIndexPath) -> CGFloat {
        
        let newsData = self.communityArray[indexPath.section] as! NewsData
        
        let identifier = self.cellIdentifierForIndexPath(indexPath)

        
        var sizingCell: UITableViewCell!
        var onceToken: dispatch_once_t = 0
        dispatch_once(&onceToken) { () -> Void in
            sizingCell = self.feedTable.dequeueReusableCellWithIdentifier(identifier)
        }
        if identifier == noteCellIdentifier {
            (sizingCell as! NoteFeedTableCell).captionLabel.text = newsData.caption
        } else if identifier == peopleCellIdentifier {
            (sizingCell as! PeopleFeedTableCell).captionLabel.text = newsData.caption
        } else if identifier == partnrCellIdentifier {
            (sizingCell as! PartnrFeedTableCell).captionLabel.text = newsData.caption
        }
        
        return self.calculateHeightForConfiguredSizingCell(sizingCell)
    }
    
    func calculateHeightForConfiguredSizingCell(sizingCell: UITableViewCell) -> CGFloat {
        
        sizingCell.bounds = CGRectMake(0, 0, CGRectGetWidth(self.feedTable.frame), CGRectGetHeight(sizingCell.bounds))
        sizingCell.setNeedsLayout()
        sizingCell.layoutIfNeeded()
        
        let size: CGSize = sizingCell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        return size.height + 1
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldDidBeginEditing(textField: UITextField) {
        isKeyboardShown = true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        isKeyboardShown = false
        
        if textField.text == ""{
            self.isSearched = false
            self.feedTable.reloadData()
        }
        else{
            self.doSearch(textField.text!)
        }
        
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        searchTextField.resignFirstResponder()
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if isKeyboardShown {
            searchTextField.resignFirstResponder()
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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if self.isSearched == true{
            if segue.identifier == "ShowUserDetailVC" {
                let selData = searchArray[selIndex]
                let destVC = segue.destinationViewController as! ProfileViewController
                destVC.userData = selData as? UserData
            } else if segue.identifier == "ShowProjectDetailVC" {
                let selData = searchArray[selIndex]
                let destVC = segue.destinationViewController as! ProjectDetailViewController
            }
        }
        else{
            if segue.identifier == "ShowNewsDetailVC" {
                let destVC = segue.destinationViewController as! NewsDetailViewController
                let newsData = self.communityArray[selIndex] as! NewsData
                destVC.newsData = newsData
            } else if segue.identifier == "ShowProfileVC" {
                let destVC = segue.destinationViewController as! ProfileViewController
                let newsData = self.communityArray[selIndex] as! NewsData
                destVC.userData = newsData.userData
            } else if segue.identifier == "ShowProjectDetailVC" {
                let destVC = segue.destinationViewController as! ProjectDetailViewController
                destVC.projectData = self.communityArray[selIndex] as? ProjectData
            }
        }
    }
}
 
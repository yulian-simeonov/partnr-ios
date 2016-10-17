//
//  ProjectDetailViewController.swift
//  Partnr
//
//  Created by Yosemite on 2/20/16.
//  Copyright © 2016 YulianMobile. All rights reserved.
//

import UIKit

import ParseUI
import MessageUI

protocol ProjectDetailViewControllerDelegate {
    func projectStatusDidChange(status: EProjectStatus)
}

class SubDetailTableCell: UITableViewCell {
    
    @IBOutlet weak var subContentLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
}

class ProjectDetailViewController: CustomBaseViewController, RateViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MFMailComposeViewControllerDelegate {

    let kCommentSection = 1
    let imagePicker = UIImagePickerController()
    
    @IBOutlet weak var projectTable: UITableView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var projectImage: PFImageView!
    @IBOutlet weak var shadowImage: PFImageView!
    @IBOutlet weak var projectNameLabel: UILabel!
    @IBOutlet weak var professionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var dueButton: UIButton!
    @IBOutlet weak var dueBtnHeiConstraint: NSLayoutConstraint!

    @IBOutlet weak var tblBtmConstraint: NSLayoutConstraint!
    
    var projectCompleteButton: UIButton?
    
    var commentInputTextField: UITextField? = nil
    
    var progressLabel: UILabel!
    
    var projectData: ProjectData?
    var projectComments = [ProjectCommentData]()
    
    var identifiers = [String]()
    var projectBrief = ""
    var deliverables = ""
    
    var projectStatus = EProjectStatus.Open
    var isAdmin = false
    var isPartnr = false
    
    var delegate: ProjectDetailViewControllerDelegate? = nil

    var price = 0.0
    var fundAmount = 0.0
    
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var contactButton: UIButton!
    @IBOutlet weak var notInterestedButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dueBtnHeiConstraint.constant = 0
        
        self.imagePicker.delegate = self
        imagePicker.navigationBar.translucent = false
        imagePicker.navigationBar.barTintColor = NAV_COLOR
        imagePicker.navigationBar.tintColor = UIColor.whiteColor()
        imagePicker.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName : UIColor.whiteColor()
        ]
        
        // Do any additional setup after loading the view.
        
        if self.projectData?.userId == PFUser.currentUser()?.objectId {
            isAdmin = true
        }
        
        if self.projectData?.status == .Open {
            if self.projectData?.briefUserId.isEmpty == false {
                actionButton.setTitle("SEND PRICE", forState: .Normal)
                
            }
        }
        
        if self.projectData?.partnrId.isEmpty == false {
            if self.projectData?.partnrId == PFUser.currentUser()?.objectId {
                isPartnr = true
            }
            
            self.projectData!.updatePartnrData({ (userData, error) -> Void in
                if error == nil {
                    self.projectTable.reloadData()
                }
            })
            
            self.projectStatus = (self.projectData?.status)!
            
            if self.projectStatus == .WaitingForFunding {
                self.projectStatus = .Pending
            }
            
            self.updateContent()
        } else {
            if isAdmin == false {
                PNAPIClient.sharedInstance.isAcceptedToProject((self.projectData?.id)!) { (isAccepted, error) -> Void in
                    self.projectStatus = isAccepted ? EProjectStatus.Pending : EProjectStatus.Open
                    self.updateContent()
                }
            } else {
                self.projectStatus = (self.projectData?.status)!
                if self.projectData?.status == .Pending {
                    self.projectStatus = .Open
                }
                self.updateContent()
            }
        }
        
        self.getProjectComments()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - API 
    func getProjectComments() {
        SVProgressHUD.show()
        PNAPIClient.sharedInstance.fetchProjectComments((self.projectData?.id)!) { (comments, error) -> Void in
            SVProgressHUD.dismiss()
            
            if error == nil {
                self.projectComments = comments
                self.projectTable.reloadData()
            }
        }
    }
    
    // MARK: - Configure UI
    func updateContent() {
        
        if self.projectData == nil {
            return
        }
        
        
        dueButton.hidden = false
        dueBtnHeiConstraint.constant = 30
        
        let dueDate = self.projectData?.dueDate
        let timeInterval = dueDate?.timeIntervalSinceNow
        var dueStr = ""
        if timeInterval > 0 {
            let days = Int(timeInterval! / (24*3600))
            let timeFormat = NSDateFormatter.init()
            timeFormat.dateFormat = "h:mm aa"
            dueStr = "DUE IN \(days) DAYS AT \(timeFormat.stringFromDate(dueDate!))"
        } else {
            let days = -1 * Int(timeInterval! / (24*3600))
            dueStr = "DUE IN \(days) DAYS"
            
            dueButton.setTitleColor(UIColor.redColor(), forState: .Normal)
        }
        dueButton.setTitle(dueStr, forState: .Normal)
        
        self.projectNameLabel.text = projectData!.name
        self.professionLabel.text = projectData!.profession
        self.priceLabel.text = NSString.init(format: "$%.02f", projectData!.price) as String
        
        self.projectImage.file = projectData!.image
        self.projectImage.loadInBackground { (image, error) -> Void in
            self.shadowImage.image = image
        }
        
        fundAmount = (self.projectData?.price)! / 5

        if (
            self.projectData?.status == .InProgress ||
            self.projectData?.status == .PartnrCompleted ||
            self.projectData?.status == .Completed
            ) && (
                isAdmin || isPartnr
            ) {
                
            actionButton.removeFromSuperview()
            
            identifiers = ["AdminCell", "BriefCell", "DeliverablesCell", "ProjectCompleteCell", "CommentInputCell"]
            projectTable.reloadData()
            
            
            
            if isPartnr {
                actionButton.enabled = false
            }
        } else {
//            dueButton.hidden = true
//            dueBtnHeiConstraint.constant = 0
    
            if (isAdmin) {
                identifiers = ["AdminCell", "BriefCell", "DeliverablesCell"]
                actionButton.setBackgroundImage(UIImage(), forState: .Normal)
                actionButton.setImage(UIImage.init(named: "btn-viewApplicants"), forState: .Normal)
                projectTable.reloadData()
                
                self.view.layoutIfNeeded()
            } else {
                if projectStatus == .Open {
                    identifiers = ["PartnrCell", "BriefCell", "DeliverablesCell", "MyRateCell"]
                    if self.projectData?.briefUserId.isEmpty == true {
                        actionButton.setTitle("HIRE ME", forState: .Normal)
//                        actionButton.setImage(UIImage.init(named: "btn-hireme"), forState: .Normal)
                    } else {
                        contactButton.hidden = false
                        notInterestedButton.hidden = false
                        actionButton.setTitle("SEND PRICE", forState: .Normal)
                    }
                    projectTable.reloadData()
                } else if projectStatus == .Pending || projectStatus == .WaitingForFunding {
                    contactButton.hidden = true
                    notInterestedButton.hidden = true
                    
                    identifiers = ["PartnrCell", "BriefCell", "DeliverablesCell"]
                    actionButton.setBackgroundImage(UIImage(), forState: .Normal)
                    actionButton.setImage(UIImage.init(named: "btn-pending"), forState: .Normal)
                    projectTable.reloadData()
                    
                    UIView .animateWithDuration(0.5) { () -> Void in
                        self.projectTable.backgroundColor = UIColor.init(red: 64/255.0, green: 64/255.0, blue: 64/255.0, alpha: 1.0)
                        
                    }
                }
            }
        }
        actionButton.hidden = false
        headerView.hidden = false
    }
    
    // MARK: - UIButton Action
    @IBAction func onClickHireMe(sender: AnyObject) {

        if (isAdmin) {
            self.performSegueWithIdentifier("ShowApplicantsVC", sender: self)
        } else {
            if projectStatus == .Open {
                let alertVC = UIAlertController.init(title: kTitle_APP, message: kHireMeConfirmMessage, preferredStyle: UIAlertControllerStyle.Alert)
                
                let defaultAction = UIAlertAction(title: "Yes", style: .Default) { (alert:  UIAlertAction!) -> Void in
                    
                    SVProgressHUD.show()
                    PNAPIClient.sharedInstance.acceptToProject((self.projectData?.id)!, price: NSNumber.init(double: self.price), callback: { (finished, error) -> Void in
                        SVProgressHUD.dismiss()
                        if finished {
                            self.projectStatus = .Pending
                            self.updateContent()
                        }
                    })
                }

                let noAction = UIAlertAction(title: "No", style: .Default) { (alert: UIAlertAction!) -> Void in
                    
                    
                }
                
                alertVC.addAction(defaultAction)
                alertVC.addAction(noAction)
                
                self.presentViewController(alertVC, animated: true, completion: nil)
                
            }
        }
    }
    
    @IBAction func onClickContact(sender: AnyObject) {
        self.showMessage()
    }
    
    @IBAction func onClickNotInterested(sender: AnyObject) {
        SVProgressHUD.show()
        PNAPIClient.sharedInstance.removeBrief((self.projectData?.id)!) { (finished, error) -> Void in
            SVProgressHUD.dismiss()
            NSNotificationCenter.defaultCenter().postNotificationName(kNotiRefreshProjectsFeed, object: nil)
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func onClickImage(sender: AnyObject) {
        // 1
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .ActionSheet)
        
        // 2
        let deleteAction = UIAlertAction(title: "Camera", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.imagePicker.allowsEditing = true
            self.imagePicker.sourceType = .Camera
            self.presentViewController(self.imagePicker, animated: true, completion: nil)

        })
        let saveAction = UIAlertAction(title: "Photo Library", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            self.imagePicker.allowsEditing = true
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

    @IBAction func onClickFund(sender: AnyObject) {

    }
    
    func onClickProjectComplete(sender: UIButton) {
        NSLog("Project Complete")
        if isPartnr {
//            SVProgressHUD.show()
//            PNAPIClient.sharedInstance.setProjectStatusTo((self.projectData?.id)!, status: .PartnrCompleted, callback: { (finished, error) -> Void in
//                SVProgressHUD.dismiss()
//                if finished && error == nil {
//                    self.projectData?.status = .PartnrCompleted
//                    self.projectStatus = .PartnrCompleted
//                    self.projectTable.reloadData()
//                } else {
//                    Utilities.showMsg("Failed! Please try again.", delegate: self)
//                }
//            })
            self.performSegueWithIdentifier("ShowRateVC", sender: self)
        } else {
            if self.projectStatus == .PartnrCompleted {
                self.performSegueWithIdentifier("ShowRateVC", sender: self)
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if (
        self.projectData?.status == .InProgress ||
        self.projectData?.status == .PartnrCompleted ||
        self.projectData?.status == .Completed
        ) && (
        isAdmin || isPartnr
            ) {
                
            return 2
        } else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == kCommentSection {
            return projectComments.count
        }
        return identifiers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == kCommentSection {
            let commentData = projectComments[indexPath.row]
            let cellIdentifier = commentData.imageFile == nil ? "CommentCell" : "CommentImageCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! CommentTableCell
            
            cell.commentLabel.text = "@\(commentData.userName) \(commentData.commentStr)"
            
            if commentData.imageFile != nil {
                cell.commentImage.file = commentData.imageFile
                cell.commentImage.loadInBackground()
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(identifiers[indexPath.row], forIndexPath: indexPath)
            if identifiers[indexPath.row] == "BriefCell" {
                (cell as! SubDetailTableCell).subContentLabel.text = projectData?.brief
                (cell as! SubDetailTableCell).subContentLabel.textColor = projectStatus != .Pending ? UIColor.darkGrayColor() : UIColor.whiteColor()
                (cell as! SubDetailTableCell).titleLabel.textColor = projectStatus != .Pending ? UIColor.darkGrayColor() : UIColor.init(red: 254/255.0, green: 181/255.0, blue: 9/255.0, alpha: 1.0)
                
                projectBrief = (projectData?.brief)!
            } else if identifiers[indexPath.row] == "DeliverablesCell" {
                (cell as! SubDetailTableCell).subContentLabel.text = projectData?.deliverables
                (cell as! SubDetailTableCell).subContentLabel.textColor = projectStatus != .Pending ? UIColor.darkGrayColor() : UIColor.whiteColor()
                (cell as! SubDetailTableCell).titleLabel.textColor = projectStatus != .Pending ? UIColor.darkGrayColor() : UIColor.init(red: 254/255.0, green: 181/255.0, blue: 9/255.0, alpha: 1.0)
                
                deliverables = projectData!.deliverables
            } else if identifiers[indexPath.row] == "PartnrCell" {
                if projectData?.userData != nil {
                    let adminImage = cell.viewWithTag(2) as! PFImageView
                    adminImage.file = projectData?.userData?.avatarImg
                    adminImage.loadInBackground({ (finihed, error) -> Void in
                        
                    })
                }
                
                if projectData?.partnrData != nil {
                    let partnrImage = cell.viewWithTag(1) as! PFImageView
                    partnrImage.file = projectData?.partnrData?.avatarImg
                    partnrImage.loadInBackground({ (finihed, error) -> Void in
                        
                    })
                }
            } else if identifiers[indexPath.row] == "AdminCell" {
                if projectData?.userData != nil {
                    let adminImage = cell.viewWithTag(1) as! PFImageView
                    adminImage.file = projectData?.userData?.avatarImg
                    adminImage.loadInBackground({ (finihed, error) -> Void in
                        
                    })
                }
                
                if projectData?.partnrData != nil {
                    let partnrImage = cell.viewWithTag(2) as! PFImageView
                    partnrImage.file = projectData?.partnrData?.avatarImg
                    partnrImage.loadInBackground({ (finihed, error) -> Void in
                        
                    })
                }
            } else if identifiers[indexPath.row] == "MyRateCell" {
                progressLabel = cell.viewWithTag(1) as! UILabel
                let slider = cell.viewWithTag(2) as! UISlider
                
                let offset = Float((projectData?.price)! / 4)
                slider.minimumValue = Float((projectData?.price)!) - offset
                slider.maximumValue = Float((projectData?.price)!) + offset

                self.onProgressChanged(slider)
            } else if identifiers[indexPath.row] == "CommentInputCell" {
                commentInputTextField = cell.viewWithTag(1) as? UITextField
                commentInputTextField?.delegate = self
                
                let imageButton = cell.viewWithTag(2) as! UIButton
                imageButton.addTarget(self, action: Selector("onClickImage:"), forControlEvents: .TouchUpInside)
            } else if identifiers[indexPath.row] == "ProjectCompleteCell" {
                projectCompleteButton = cell.viewWithTag(1) as? UIButton
                if isAdmin {
                    projectCompleteButton?.enabled = self.projectStatus == .PartnrCompleted
                } else if isPartnr {
                    projectCompleteButton?.enabled = self.projectStatus == .InProgress
                } else {
                    projectCompleteButton?.enabled = false
                }

                projectCompleteButton?.addTarget(self, action: Selector("onClickProjectComplete:"), forControlEvents: .TouchUpInside)
            }
            return cell
        }
    }
    
    @IBAction func onProgressChanged(sender: UISlider) {
        
        price = Double(sender.value)
        progressLabel.text = NSString.init(format: "$%.02f", sender.value) as String
    }
    
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        picker .dismissViewControllerAnimated(true) { () -> Void in
            
            let wid = SCRN_WIDTH * 1.5
            let hei = image.size.height * (wid / image.size.width)
            
            let resizedImage = image.imageByScalingAndCroppingForSize(CGSizeMake(wid, hei))
            if resizedImage != nil {
                SVProgressHUD.show()
                PNAPIClient.sharedInstance.postCommentImageToProject((self.projectData?.id)!, commentImage: resizedImage!, commentStr: (self.commentInputTextField?.text)!, callback: { (succeed, commentData, error) -> Void in
                    SVProgressHUD.dismiss()
                    
                    self.commentInputTextField?.text = ""
                    
                    if succeed == true {
                        self.projectComments.insert(commentData!, atIndex: 0)
                        self.projectTable.reloadData()
                    }
                })
            } else {
                Utilities.showMsg("Invalid photo, please try again", delegate: self)
            }
            //            self.performSelector(Selector("addPhotoToDialog:"), withObject: image, afterDelay: 2)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //------------------ Dynamic Cell Height --------------------------//
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.section == kCommentSection {
            return max(30, self.heightForCommentCellAtIndexPath(indexPath))
        }
        
        if identifiers[indexPath.row] == "BriefCell" ||
            identifiers[indexPath.row] == "DeliverablesCell" {
            return max(60, self.heightWithCellAtIndexPath(indexPath))
        } else if identifiers[indexPath.row] == "CommentInputCell" {
            return 50
        } else {
            return indexPath.row == 0 ? 105 : 103
        }
    }
    
    // MARK: - UITableView Calc Height
    func heightWithCellAtIndexPath(indexPath: NSIndexPath) -> CGFloat {
        
        var sizingCell: UITableViewCell!
        var onceToken: dispatch_once_t = 0
        dispatch_once(&onceToken) { () -> Void in
            sizingCell = self.projectTable.dequeueReusableCellWithIdentifier(self.identifiers[indexPath.row])
        }
        let label = (sizingCell as! SubDetailTableCell).subContentLabel
        
        label?.text = identifiers[indexPath.row] == "BriefCell" ? projectBrief : deliverables
        return self.calculateHeightForConfiguredSizingCell(sizingCell)
    }
    
    func heightForCommentCellAtIndexPath(indexPath: NSIndexPath) -> CGFloat {
        
        var sizingCell: UITableViewCell!
        var onceToken: dispatch_once_t = 0
        
        let commentData = projectComments[indexPath.row]
        let cellIdentifier = commentData.imageFile == nil ? "CommentCell" : "CommentImageCell"
        
        dispatch_once(&onceToken) { () -> Void in
            sizingCell = self.projectTable.dequeueReusableCellWithIdentifier(cellIdentifier)
        }
        
        let label = (sizingCell as! CommentTableCell).commentLabel
        
        label?.text = commentData.commentStr
        
        return self.calculateHeightForConfiguredSizingCell(sizingCell)
    }
    
    func calculateHeightForConfiguredSizingCell(sizingCell: UITableViewCell) -> CGFloat {
        
        sizingCell.bounds = CGRectMake(0, 0, CGRectGetWidth(self.projectTable.frame), CGRectGetHeight(sizingCell.bounds))
        sizingCell.setNeedsLayout()
        sizingCell.layoutIfNeeded()
        
        let size: CGSize = sizingCell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        return size.height + 1
    }
    
    func showMessage() {
        
        let emailTitle = "\(self.projectData!.name) + Partnr Intro"
        let messageBody = ""
        let toRecipents = [projectData!.userData!.email]
        let mc: MFMailComposeViewController = MFMailComposeViewController()
        mc.mailComposeDelegate = self
        mc.setSubject(emailTitle)
        mc.setMessageBody(messageBody, isHTML: false)
        mc.setToRecipients(toRecipents)
        
        self.presentViewController(mc, animated: true, completion: nil)
    }
    
    // MARK: - MFMailComposeViewControllerDelegate
    func mailComposeController(controller:MFMailComposeViewController, didFinishWithResult result:MFMailComposeResult, error:NSError?) {
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
    
    // MARK: - UITextFieldDeelgate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if textField.text!.isEmpty {
            return false
        }
        
        tblBtmConstraint.constant = 0
        UIView.animateWithDuration(0.3) { () -> Void in
            self.projectTable.layoutIfNeeded()
        }
        
        SVProgressHUD.show()
        PNAPIClient.sharedInstance.postCommentStrToProject((self.projectData?.id)!, commentStr: textField.text!) { (succeed, commentData, error) -> Void in
            SVProgressHUD.dismiss()
            
            textField.text = ""
            
            if succeed == true {
                self.projectComments.insert(commentData!, atIndex: 0)
                self.projectTable.reloadData()
            }
        }
        
        return false
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        tblBtmConstraint.constant = 260
        UIView.animateWithDuration(0.3) { () -> Void in
            self.projectTable.layoutIfNeeded()
        }
        return true
    }
    
    // MARk: - UIScrollViewDelegate
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        if tblBtmConstraint.constant != 0 {
            tblBtmConstraint.constant = 0
            commentInputTextField?.resignFirstResponder()
            UIView.animateWithDuration(0.3) { () -> Void in
                self.projectTable.layoutIfNeeded()
            }
        }
    }
    
    // MARK: - RateViewControllerDelegate
    func projectStatusDidChange(status: EProjectStatus) {
        self.projectStatus = status
        self.updateContent()
        self.delegate?.projectStatusDidChange(status)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController
        // Pass the selected object to the new view controller.
        if segue.identifier == "ShowApplicantsVC" {
            let destVC = segue.destinationViewController as! ApplicantListViewController
            destVC.projectData = self.projectData
        } else if segue.identifier == "ShowRateVC" {
            let destVC = segue.destinationViewController as! RateViewController
            destVC.projectId = (self.projectData?.id)!
            destVC.isPartnr = isPartnr
            destVC.delegate = self
            destVC.userData = isPartnr ? self.projectData?.userData : self.projectData?.partnrData
        }
    }

}

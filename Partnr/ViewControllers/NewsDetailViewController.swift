//
//  NewsDetailViewController.swift
//  Partnr
//
//  Created by Yulian Simeonov on 2/5/16.
//  Copyright © 2016 YulianMobile. All rights reserved.
//

import UIKit

import Parse
import ParseUI

class CommentTableCell: UITableViewCell {

    @IBOutlet weak var commentLabel: KILabel!
    @IBOutlet weak var commentImage: PFImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timeagoLabel: UILabel!
    @IBOutlet weak var avatarImage: PFImageView!
    
    func loadAvatar(imageFile: PFFile) {
        avatarImage.file = imageFile
        avatarImage .loadInBackground()
    }
    
}

class NewsDetailViewController: CustomBaseViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tagContainer: UIView!
    @IBOutlet weak var tableBtmConstraint: NSLayoutConstraint!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var commentTable: UITableView!
    @IBOutlet weak var tagContainerHeiConstraint: NSLayoutConstraint!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var newsPhotoImage: PFImageView!
    @IBOutlet weak var imgContainer: UIView!
    @IBOutlet weak var tableBtmView: UIView!
    
    let photoCellIdentifier = "PhotoFeedCell"
    let partnrCellIdentifier = "PartnrFeedCell"
    let peopleCellIdentifier = "PeopleFeedCell"
    let noteCellIdentifier = "NoteFeedCell"
    let communityCellIdentifier = "CommunityFeedCell"

    var tagsView: ANTagsView? = nil
    
    var newsData: NewsData? = nil
    
    var feedCellIdentifier: String = ""
    var cellIdentifier: String = "CommentCell"
    var commentArray: NSMutableArray!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        commentArray = NSMutableArray()
        
        if newsData != nil {
            self.reloadCommentData()
//            self.reloadLikeData()
            
            if newsData?.type == .Photo {
//                self.newsPhotoImage.file = newsData?.photoFile
//                self.newsPhotoImage.loadInBackground()
                self.createTagsView()
//                let hei = newsData!.photoSize.height * ( SCRN_WIDTH / newsData!.photoSize.width)
//                var frame = imgContainer.frame
//                frame.size.height = hei
//                imgContainer.frame = frame                
            }
            
            
            if self.newsData?.type == .Photo {
                feedCellIdentifier = photoCellIdentifier
                commentTable.registerNib(UINib.init(nibName: "PhotoFeedTableCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: photoCellIdentifier)
            } else if self.newsData?.type == .Partnr {
                feedCellIdentifier = partnrCellIdentifier
                commentTable.registerNib(UINib.init(nibName: "PartnrFeedTableCell", bundle:
                NSBundle.mainBundle()), forCellReuseIdentifier: partnrCellIdentifier)
            } else if self.newsData?.type == .People {
                feedCellIdentifier = peopleCellIdentifier
                commentTable.registerNib(UINib.init(nibName: "PeopleFeedTableCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: peopleCellIdentifier)
            } else if self.newsData?.type == .Note {
                feedCellIdentifier = noteCellIdentifier
                commentTable.registerNib(UINib.init(nibName: "NoteFeedTableCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: noteCellIdentifier)
            } else if self.newsData?.type == .Community {
                feedCellIdentifier = communityCellIdentifier
                commentTable.registerNib(UINib.init(nibName: "CommunityFeedTableCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: communityCellIdentifier)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadLikeData() {
        
        PNAPIClient.sharedInstance.fetchLikeInfo(newsData!.id, callback: { (succeed, nsData, isLiked, error) -> Void in
            self.likeButton.setTitle("\(nsData?.count)", forState: .Normal)
            self.likeButton.selected = isLiked
        })
    }
    
    func reloadCommentData() {
        PNAPIClient.sharedInstance.fetchCommentInfo(newsData!.id, callback: { (succeed, nsData, error) -> Void in
            if succeed && nsData as? NSArray != nil {
                self.commentArray = NSMutableArray.init(array: nsData as! NSArray)
//                self.commentButton.setTitle("\(self.commentArray.count)", forState: .Normal)
                self.commentTable.reloadData()
            }
        })
    }
    
    // MARK: - UI Configure
    func createTagsView() {
        if newsData!.tags.count > 0 {
            self.tagsView = ANTagsView.init(tags: newsData!.tags as [AnyObject], frame: CGRectMake(0, 5, SCRN_WIDTH, tagContainer.frame.size.height))
            tagsView?.setTagCornerRadius(10)
            tagsView?.setTagBackgroundColor(UIColor.init(red: 239/255.0, green: 239/255.0, blue: 244/255.0, alpha: 1.0))
            tagsView?.setTagTextColor(UIColor.darkGrayColor())
            tagsView?.backgroundColor = UIColor.whiteColor()
            tagsView?.setFrameWidth(Int32(SCRN_WIDTH))
            print(tagsView?.frame)
            
            var frame = tableBtmView.frame
            frame.size.height = 54
            tableBtmView.frame = frame
            
            tagContainerHeiConstraint.constant = (tagsView?.frame.size.height)! + 15
            self.tagContainer.addSubview(tagsView!)
        } else {
            var frame = tableBtmView.frame
            frame.size.height = 0
            tableBtmView.frame = frame
            tagContainerHeiConstraint.constant = 0
        }
    }
    
    // MARK: - UIButtonAction
    
    @IBAction func onClickSend(sender: AnyObject) {
//        textField.resignFirstResponder()
        
        if !textField.text!.isEmpty {
            SVProgressHUD.show()
            PNAPIClient.sharedInstance.postComment(textField.text!, newsId: newsData!.id, callback: { (succeed, commentData, error) -> Void in
                self.textField.text = ""
                SVProgressHUD.dismiss()
                if succeed {
                    self.reloadCommentData()
                    self.performSelector(Selector("moveTableToBottom"), withObject: nil, afterDelay: 0.3)
                }
            })
        }
    }
    
    
    
    @IBAction func onClickLike(sender: UIButton) {
        sender.enabled = false
        if sender.selected {
            PNAPIClient.sharedInstance.postUnLike(newsData!.id, callback: { (succeed, error) -> Void in
                sender.enabled = true
                self.reloadLikeData()
            })
        } else {
            PNAPIClient.sharedInstance.postLike(newsData!.id, callback: { (succeed, likeData, error) -> Void in
                sender.enabled = true
                self.reloadLikeData()
            })
        }
    }
    
    func moveTableToBottom() {
        
        self.commentTable.scrollToRowAtIndexPath(NSIndexPath.init(forRow: commentArray.count-1, inSection: 0), atScrollPosition: .Top, animated: true)
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        tableBtmConstraint.constant = 255
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.commentTable.layoutIfNeeded()

        }) { (finished) -> Void in
            let indexPath = NSIndexPath.init(forRow: self.commentArray.count, inSection: 0)

            self.commentTable.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)
   
        }
//        self.commentTable.setContentOffset(CGPointMake(0, self.commentTable.contentSize.height - self.commentTable.frame.size.height), animated: true)
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        tableBtmConstraint.constant = 0
        UIView.animateWithDuration(0.3) { () -> Void in
            self.commentTable.layoutIfNeeded()
        }
    }
    
    
    // MARK: - UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return commentArray.count+1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 { // FeedCell
            let cell = tableView.dequeueReusableCellWithIdentifier(feedCellIdentifier, forIndexPath: indexPath)
            
            self.updateCellActions(cell as! FeedBaseTableCell, indexPath: indexPath)
            
            if cell.isKindOfClass(PhotoFeedTableCell) {
                let feedCell = (cell as! PhotoFeedTableCell)
                
                feedCell.proceeedContent(newsData!)
                
                // Update Comment Count
            } else if cell.isKindOfClass(NoteFeedTableCell) {
                let feedCell = (cell as! NoteFeedTableCell)
                feedCell.proceeedContent(newsData!)
            } else if cell.isKindOfClass(PeopleFeedTableCell) {
                let feedCell = (cell as! PeopleFeedTableCell)
                feedCell.proceeedContent(newsData!)
            } else if cell.isKindOfClass(PartnrFeedTableCell) {
                let feedCell = (cell as! PartnrFeedTableCell)
                feedCell.proceeedContent(newsData!)
            } else if cell.isKindOfClass(CommunityFeedTableCell) {
                let feedCell = (cell as! CommunityFeedTableCell)
                feedCell.proceeedContent(newsData!)
            }
            
            return cell
        } else {    // Comment Cell
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! CommentTableCell
            
            let commentData = commentArray[indexPath.row-1] as! CommentData
            
            cell.commentLabel.text = commentData.commentStr
            
            // Update UserInfo
            if commentData.userData == nil {
                commentData.updateUserDataWithCallback({ (userData, error) -> Void in
                    cell.usernameLabel.text = userData?.name
                    cell.loadAvatar((commentData.userData?.avatarImg)!)
                })
            } else {
                cell.usernameLabel.text = commentData.userData?.name
                cell.loadAvatar((commentData.userData?.avatarImg)!)
            }
            
            cell.timeagoLabel.text = commentData.createdAt.timeAgo()
            
            return cell
        }
    }
    
    func updateCellActions(feedCell: FeedBaseTableCell, indexPath: NSIndexPath) {
        //        let indexPath = self.feedTable.indexPathForCell(feedCell)
        let newsData = self.newsData!
        
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
                self.commentTable.endUpdates()
            })
        } else {
            print("newsData: \(indexPath.section) = \(newsData.likeCount)")
            feedCell.likeLabel.text = "\(newsData.likeCount)"
            feedCell.likesButton.selected = newsData.isLiked
            feedCell.likeLabel.textColor = newsData.isLiked ? NAV_COLOR : UIColor.init(red: 136/255.0, green: 136/255.0, blue: 136/255.0, alpha: 1.0)

        }
        
    }
    
    //------------------ Dynamic Cell Height --------------------------//
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            var hei = CGFloat(0)
            let newsData = self.newsData!
            if newsData.type == .Photo {
                hei = (SCRN_WIDTH-25) + CGFloat(70)
            } else if newsData.type == .Partnr {
                hei = 157
            } else if newsData.type == .Community {
                hei = 145
            } else {
                return max(120, self.heightWithCellAtIndexPath(indexPath))
            }
            return hei
        } else {
            return max(80, self.heightWithCellAtIndexPath(indexPath))
        }
    }
    
    // MARK: - UITableView Calc Height
    func heightWithCellAtIndexPath(indexPath: NSIndexPath) -> CGFloat {
        
        var sizingCell: UITableViewCell!
        var onceToken: dispatch_once_t = 0
        
        let identifier = indexPath.row == 0 ? feedCellIdentifier : cellIdentifier
        
        dispatch_once(&onceToken) { () -> Void in
            sizingCell = self.commentTable.dequeueReusableCellWithIdentifier( identifier)
        }
        
        let newsData = self.newsData!
        
        if identifier == noteCellIdentifier {
            (sizingCell as! NoteFeedTableCell).captionLabel.text = newsData.caption
        } else if identifier == peopleCellIdentifier {
            (sizingCell as! PeopleFeedTableCell).captionLabel.text = newsData.caption
        } else if identifier == partnrCellIdentifier {
            (sizingCell as! PartnrFeedTableCell).captionLabel.text = newsData.caption
        } else if identifier == cellIdentifier {
            let commentCell = sizingCell as! CommentTableCell
            let label = commentCell.commentLabel
            let commentData = commentArray[indexPath.row-1] as! CommentData
            
            label?.text = commentData.commentStr
        }
        
        return self.calculateHeightForConfiguredSizingCell(sizingCell)
    }
    
    func calculateHeightForConfiguredSizingCell(sizingCell: UITableViewCell) -> CGFloat {
        
        sizingCell.bounds = CGRectMake(0, 0, CGRectGetWidth(self.commentTable.frame), CGRectGetHeight(sizingCell.bounds))
        sizingCell.setNeedsLayout()
        sizingCell.layoutIfNeeded()
        
        let size: CGSize = sizingCell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        return size.height + 1
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

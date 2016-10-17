//
//  ProjectAcceptModalView.swift
//  Partnr
//
//  Created by Yosemite on 3/2/16.
//  Copyright © 2016 YulianMobile. All rights reserved.
//

import UIKit

import ParseUI

class ProjectAcceptModalView: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var respondBlock: ((isAccept:Bool?, error: NSError?) -> (Void))?

    var projectData: ProjectData? = nil
    var applicantData: ApplicantData? = nil
    
    var identifiers = [String]()
    var projectBrief = ""
    var deliverables = ""
    
    @IBOutlet weak var projectTable: UITableView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var projectImage: PFImageView!
    @IBOutlet weak var shadowImage: PFImageView!
    @IBOutlet weak var projectNameLabel: UILabel!
    @IBOutlet weak var professionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var creatorLabel: UILabel!
    @IBOutlet weak var dayagoLabel: UILabel!
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    class func showPopup(projectData: ProjectData, applicantData: ApplicantData, delegate: AnyObject, callback:((isAccept:Bool?, error: NSError?) -> Void)) -> ProjectAcceptModalView {
        
        let modalDialog = UIStoryboard.init(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("ProjectAcceptModal") as! ProjectAcceptModalView
        modalDialog.providesPresentationContextTransitionStyle = true
        modalDialog.definesPresentationContext = true
        modalDialog.modalPresentationStyle = UIModalPresentationStyle.Custom
        modalDialog.modalTransitionStyle = .CrossDissolve
        modalDialog.respondBlock = callback
        
        modalDialog.projectData = projectData
        
        delegate.presentViewController(modalDialog, animated: true, completion: nil)
        
        return modalDialog
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.updateContent()
    }
    
    // MARK: - Configure UI
    func updateContent() {
        
        if self.projectData == nil {
            return
        }
        if self.projectData?.userId == PFUser.currentUser()?.objectId {
            return
        }
        
        self.projectNameLabel.text = projectData!.name
        self.professionLabel.text = projectData!.profession
        
        let offset = Float((projectData?.price)! / 4)
        let min = Float((projectData?.price)!) - offset
        let max = Float((projectData?.price)!) + offset
        
        self.priceLabel.text = "$\(min) - $\(max)"
        
        self.projectImage.file = projectData!.image
        self.projectImage.loadInBackground { (image, error) -> Void in
            self.shadowImage.image = image
        }
        
        
        identifiers = ["BriefCell", "DeliverablesCell", "DueDateCell", "PriceCell"]
        projectTable.reloadData()
        
        headerView.hidden = false
    }
    
    // MARK: - UIButton Action
    
    @IBAction func onClickAccept(sender: AnyObject) {
        self.dismissViewControllerAnimated(true) { () -> Void in
            if self.respondBlock != nil {
                self.respondBlock!(isAccept: true, error: nil)
            }
        }
    }

    @IBAction func onClickDecline(sender: AnyObject) {
        self.dismissViewControllerAnimated(true) { () -> Void in
            if self.respondBlock != nil {
                self.respondBlock!(isAccept: false, error: nil)
            }
        }
        
    }
    // MARK: - UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return identifiers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(identifiers[indexPath.row], forIndexPath: indexPath)
        
        if identifiers[indexPath.row] == "BriefCell" {
            (cell as! SubDetailTableCell).subContentLabel.text = projectData?.brief
            projectBrief = projectData!.brief
        } else if identifiers[indexPath.row] == "DeliverablesCell" {
            (cell as! SubDetailTableCell).subContentLabel.text = projectData?.deliverables
            deliverables = projectData!.deliverables
        } else if identifiers[indexPath.row] == "DueDateCell" {
            (cell as! SubDetailTableCell).subContentLabel.text = Utilities.stringFromDate(projectData?.dueDate, formatStr: "MMMM dd yyyy @ h:mmaa ZZZ")
        } else if identifiers[indexPath.row] == "PriceCell" {
            (cell as! SubDetailTableCell).subContentLabel.text = "$\(projectData!.price)"
        }
        
        return cell
    }
    //------------------ Dynamic Cell Height --------------------------//
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if identifiers[indexPath.row] == "BriefCell" ||
            identifiers[indexPath.row] == "DeliverablesCell" {
                return max(60, self.heightWithCellAtIndexPath(indexPath))
        } else {
            return 60
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
    
    func calculateHeightForConfiguredSizingCell(sizingCell: UITableViewCell) -> CGFloat {
        
        sizingCell.bounds = CGRectMake(0, 0, CGRectGetWidth(self.projectTable.frame), CGRectGetHeight(sizingCell.bounds))
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

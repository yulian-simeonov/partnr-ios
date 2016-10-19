//
//  ApplicantListViewController.swift
//  Partnr
//
//  Created by Yulian Simeonov on 2/20/16.
//  Copyright © 2016 YulianMobile. All rights reserved.
//

import UIKit

import ParseUI
import MessageUI

class ApplicantListViewController: CustomBaseViewController, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate {
    
    private let cellIdentifier = "ApplicantCell"
    
    var projectData: ProjectData? = nil

    @IBOutlet weak var applicantTable: UITableView!
    
    var applicants = [ApplicantData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if (projectData != nil) {
            SVProgressHUD.show()
            PNAPIClient.sharedInstance.getApplicants((self.projectData?.id)!) { (applicants, error) -> Void in
                SVProgressHUD.dismiss()
                
                self.applicants = applicants
                
                self.applicantTable.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return applicants.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ApplicantTableCell
        
        let applicantData = applicants[indexPath.row]
        
        cell.priceLabel.text = NSString.init(format: "$%.02f", applicantData.price) as String
        if applicantData.userData == nil {
            applicantData.updateUserData({ (userData, error) -> Void in
                applicantData.userData = userData
                cell.proceedContent(applicantData.userData!)
            })
        } else {
            cell.proceedContent(applicantData.userData!)
        }
        
        cell.hiremeButton.addTarget(self, action: Selector("onClickHireMe:"), forControlEvents: .TouchUpInside)
        cell.hiremeButton.tag = indexPath.row
        
        cell.messageButton.addTarget(self, action: Selector("onClickMessage:"), forControlEvents: .TouchUpInside)
        cell.messageButton.tag = indexPath.row
        
        if applicantData.status == .Requested {
            cell.hiremeButton.setImage(UIImage.init(named: "btn-applicant-pending"), forState: .Normal)
        } else {
            cell.hiremeButton.setImage(UIImage.init(named: "btn-applicant-hireme"), forState: .Normal)
        }
        
        return cell
    }
    
    // MAR: - UIButton Action
    func onClickHireMe(sender: UIButton) {
        let index = sender.tag
        let applicantData = applicants[index]
        
        SVProgressHUD.show()
        PNAPIClient.sharedInstance.sendHireToApplicant(applicantData, projectObj: (self.projectData?.parseObj)!) { (finished, error) -> Void in
            
            SVProgressHUD.dismiss()
            if finished && error == nil {
                applicantData.status = EApplicantStatus.Requested
                self.applicantTable.reloadRowsAtIndexPaths([NSIndexPath.init(forRow: index, inSection: 0)], withRowAnimation: .None)
            }
        }
        
    }
    
    func onClickMessage(sender: UIButton) {
        
        let index = sender.tag
        let applicantData = applicants[index]
        
        if applicantData.projectData == nil {
            applicantData.updateProjectData({ (projectData, error) -> Void in
                self.showMessage(applicantData)
            })
        } else {
            self.showMessage(applicantData)
        }
        
    }
    
    func showMessage(applicantData: ApplicantData) {
        
        let emailTitle = "\(applicantData.projectData!.name) + Intro"
        let messageBody = ""
        let toRecipents = [applicantData.userData!.email]
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

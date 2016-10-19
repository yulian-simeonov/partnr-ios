//
//  RateViewController.swift
//  Partnr
//
//  Created by Yulian Simeonov on 3/18/16.
//  Copyright © 2016 YulianMobile. All rights reserved.
//

import UIKit

import ParseUI

protocol RateViewControllerDelegate {
    func projectStatusDidChange(status: EProjectStatus)
}

class RateViewController: UIViewController, UITextViewDelegate {
    
    var projectId: String = ""
    var isPartnr: Bool = true
    var userData: UserData?
    var delegate: RateViewControllerDelegate? = nil

    @IBOutlet weak var avatarImage: PFImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var reviewTextView: NSPlaceholderTextView!
    @IBOutlet weak var starRatingView: FloatRatingView!
    
    @IBOutlet weak var textViewTopConstraint: NSLayoutConstraint!
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        avatarImage.file = userData?.avatarImg
        avatarImage.loadInBackground()
        usernameLabel.text = userData?.userName
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func onClickSubmit(sender: AnyObject) {
        if starRatingView.rating == 0 {
            Utilities.showMsg("You must rate your Partnr for this project. It's how we keep things honest around here.", delegate: self)
            return
        }
        if !Utilities.isValidData(reviewTextView.text) {
            Utilities.showMsg("Please review your Partnr. You can use Emojis if it makes it easier.", delegate: self)
            return
        }
        
        SVProgressHUD.show()
        PNAPIClient.sharedInstance.rateToUserId((userData?.id)!, isToPartnr: isPartnr, reviewStr: reviewTextView.text, projectId: projectId, rateStar: starRatingView.rating) { (finished, error) -> Void in
            SVProgressHUD.dismiss()
            if finished && error == nil {
//                PNAPIClient.sharedInstance.updateRateOfUserId(self.userData!.id)
                
                PNAPIClient.sharedInstance.setProjectStatusTo(self.projectId, status: self.isPartnr ? .PartnrCompleted : .Completed, callback: { (finished, error) -> Void in
                    if finished && error == nil {
                        if self.delegate != nil {
                            NSNotificationCenter.defaultCenter().postNotificationName(kNotiRefreshProjectsFeed, object: nil)
                        }
                        self.dismissViewControllerAnimated(true, completion: nil)
                    } else {
                        Utilities.showMsg("Failed! Please try again.", delegate: self)
                    }
                })
            } else {
                Utilities.showMsg("Failed! Please try again.", delegate: self)
            }
        }
    }
    
    // MARK: - UITextViewDelegate
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        let offset = SCRN_HEIGHT - reviewTextView.frame.size.height - reviewTextView.frame.origin.y
        if offset < 230 {
            textViewTopConstraint.constant = offset - 210
        }
        reviewTextView.layoutIfNeeded()
        return true
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textViewTopConstraint.constant != 29 {
            textViewTopConstraint.constant = 29
            reviewTextView.layoutIfNeeded()
        }
    }
    
    // MARK: -
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        reviewTextView.resignFirstResponder()
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

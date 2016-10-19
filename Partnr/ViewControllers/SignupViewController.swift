//
//  SignupViewController.swift
//  Partnr
//
//  Created by Yulian Simeonov on 1/23/16.
//  Copyright © 2016 YulianMobile. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController, UITextFieldDelegate {
    
    var cellIdentifiers = ["NameCell", "EmailCell", "PasswordCell", "CFPasswordCell", "PhoneCell", "SwitchCell"]
    
    @IBOutlet weak var signupTable: UITableView!
    
    @IBOutlet weak var tableBtmConstraint: NSLayoutConstraint!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBarHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UIButtonAction
    
    @IBAction func onClickBack(sender: AnyObject) {
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func onClickSignUp(sender: AnyObject) {
        
        self.performSegueWithIdentifier(kShowSignupStepVC, sender: self)
    }
    
    @IBAction func onClickTermsOfUse(sender: AnyObject) {
        
        
    }
    
    
    @IBAction func onClickPrivacyPolicy(sender: AnyObject) {
        
        
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        tableBtmConstraint.constant = 8
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        tableBtmConstraint.constant = 100
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

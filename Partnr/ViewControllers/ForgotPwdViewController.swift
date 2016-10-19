//
//  ForgotPwdViewController.swift
//  Partnr
//
//  Created by Yulian Simeonov on 2/21/16.
//  Copyright © 2016 YulianMobile. All rights reserved.
//

import UIKit
import ParseUI

class ForgotPwdViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: NSCustomTextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBarHidden = false
    }
    
    @IBAction func onClickNext(sender: AnyObject) {
        
        if Utilities.isValidEmail(emailTextField.text!) == false {
            Utilities.showMsg("Please input valid email address!", delegate: self)
            return
        }
        SVProgressHUD.show()
        PFUser.requestPasswordResetForEmailInBackground(emailTextField.text!) { (finished, error) -> Void in
            SVProgressHUD.dismiss()
            
            if finished {
                Utilities.showMsg("Request is sent to your email!", delegate: self)
            } else {
                print(error)
            }
        }
    }

    @IBAction func onClickBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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

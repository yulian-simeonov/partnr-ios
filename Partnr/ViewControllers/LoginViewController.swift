//
//  LoginViewController.swift
//  Partnr
//
//  Created by Yulian Simeonov on 1/22/16.
//  Copyright © 2016 YulianMobile. All rights reserved.
//

import UIKit

import Parse

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var loginTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var usernameTextField: NSCustomTextField!
    @IBOutlet weak var passwordTextField: NSCustomTextField!
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        self.navigationController?.navigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SharedDataManager.sharedInstance.isFBLogin = false
        // Do any additional setup after loading the view.
        if IS_IPHONE4 == true {
            loginTopConstraint.constant = 30
        } else {
            loginTopConstraint.constant = 80
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClickFacebookLogin(sender: AnyObject) {
        
        SharedDataManager.sharedInstance.isFBLogin = true
        
        SVProgressHUD.show()
        PNAPIClient.sharedInstance.linkToFacebook { (nsData, error) -> Void in
            SVProgressHUD.dismiss()
            let dict = nsData as? NSDictionary
            if error == nil && dict != nil {
                let query = PFUser.query()
                query!.whereKey("facebookID", equalTo: dict!["id"] as! String)
                query?.getFirstObjectInBackgroundWithBlock({ (object, error) -> Void in
                    SVProgressHUD.show()
                    
                    if object != nil {
                        
                        PNAPIClient.sharedInstance.loginToFacebook({ (nsData, error, succeed) -> Void in
                            SVProgressHUD.dismiss()
                            if succeed {
                                self .dismissViewControllerAnimated(true, completion: { () -> Void in
//                                    SharedDataManager.sharedInstance.rootVC.didLogIn()
                                })
                            } else {
                                Utilities.showMsg("Login Failed!", delegate: self)
                            }
                        })
                        
                    } else {
                        SVProgressHUD.dismiss()
                        
                        SharedDataManager.sharedInstance.facebookInfo = nsData as! NSDictionary
                        SharedDataManager.sharedInstance.isFBLogin = true
                        
                        print("Facebook User Data:\(nsData)")
                        self .performSegueWithIdentifier("ShowSignUpVC", sender: self)
                    }
                })
            } else {
                Utilities.showMsg("Facebook login failed!", delegate: self)
            }
        }
    }
    @IBAction func onClickSignUp(sender: AnyObject) {
        
        SharedDataManager.sharedInstance.isFBLogin = false
    }
    
    @IBAction func onClickLogin(sender: AnyObject) {
        
        if usernameTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            Utilities.showMsg("Please input all fields!", delegate: self)
            return
        }
        
        SVProgressHUD.show()
        PNAPIClient.sharedInstance.loginToGeneralUser(usernameTextField.text!, password: passwordTextField.text!) { (nsData, error) -> Void in
            
            SVProgressHUD.dismiss()
            
            if error == nil && nsData != nil {
                self .dismissViewControllerAnimated(true, completion: { () -> Void in
                    SharedDataManager.sharedInstance.rootVC.didLogIn()
                })
            } else {
                Utilities.showMsg("Login failed! \(error?.userInfo["error"]!)", delegate: self)
            }
        }
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField .resignFirstResponder()
        self.onClickLogin(UIButton())
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
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

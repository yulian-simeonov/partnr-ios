//
//  SignStepViewController.swift
//  Partnr
//
//  Created by Yosemite on 1/23/16.
//  Copyright © 2016 YulianMobile. All rights reserved.
//

import UIKit

import MapKit

class SignUpEditTableCell: UITableViewCell {
    
    @IBOutlet weak var textField: NSCustomTextField!
}

class SignupStepViewController: UIViewController, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, OtherProffViewControllerDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, GooglePlacesDelegate, UIPickerViewDataSource, UIPickerViewDelegate, NIDropDownDelegate {
    
    var secretCode = "PARTNR7867"
    
    var professionDropDown: NIDropDown!
    @IBOutlet weak var profDropDownButton: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet var step1View: UIView!
    @IBOutlet var step2View: UIView!
    @IBOutlet var step3View: UIView!
    @IBOutlet var step4View: UIView!
    @IBOutlet var step5View: UIView!
    
    @IBOutlet weak var step1Table: UITableView!
    @IBOutlet weak var step2Table: UITableView!
    
    @IBOutlet weak var tableBtmConstraint: NSLayoutConstraint!
    
    @IBOutlet var professionButtons: [UIButton]!
    
    @IBOutlet weak var avatarImage: UIImageView!
    
    @IBOutlet weak var locationPickerView: UIPickerView!
    @IBOutlet weak var pickerContainer: UIView!
    
    // Step4
    @IBOutlet weak var introContainerView: PNRoundedShadowView!
    @IBOutlet weak var step4ContentView: UIView!
    @IBOutlet weak var locationTextField: NSCustomTextField!
    @IBOutlet weak var websiteTextField: NSCustomTextField!
    @IBOutlet weak var introTextView: NSPlaceholderTextView!
    
    // Step2
    @IBOutlet weak var phoneTextField: NSCustomTextField!
    @IBOutlet weak var verifyCodeTextField: NSCustomTextField!
    
    // Step3
    let profArray = PROF_LIST
    
    
    var fNameTextField: UITextField!
    var lNameTextField: UITextField!
    var usernameTextField: UITextField!
    var emailTextField: UITextField!
    var pwdTextField: UITextField!
    var cfrmPwdTextField: UITextField!
    var fullnameTextField: UITextField!
    
    var compNameTextField: UITextField!
    var descTextView: UITextView!
    
    var isFacebook = false
    var isComp = false
    var profession = ""
    var locationItem: MKMapItem? = nil
    
    var curStep = 0
    var step1Identifiers = ["FirstNameCell", "LastNameCell", "UsernameCell", "EmailCell", "PasswordCell", "CFPasswordCell"]
    var step3Identifiers = ["UsernameCell", "PasswordCell", "CFPasswordCell"]
    
    var compCellIdentifiers = ["CompanyNameCell", "UsernameCell", "EmailCell", "PasswordCell", "WebsiteCell", "DescCell"]
    var professions = ["Designer", "Videographer", "Writer", "Photographer", "FineArt", "Other"]
    
    var googlePlace: GooglePlaces!
    var locationArray = [MKMapItem]()
    
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var locationYesButton: UIButton!
    @IBOutlet weak var locationLaterButton: UIButton!
    var isLocationAdded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("textFieldDidChange:"), name: UITextFieldTextDidChangeNotification, object: nil)
        
        googlePlace = GooglePlaces.init()
        googlePlace.delegate = self
        
        introContainerView.layer.borderWidth = 0.8
        introContainerView.layer.borderColor = UIColor.whiteColor().CGColor

        if SharedDataManager.sharedInstance.isFBLogin == true {
            let urlStr = "http://graph.facebook.com/\(SharedDataManager.sharedInstance.facebookInfo["id"] as! String)/picture?width=160&height=160"
            avatarImage.sd_setImageWithURL(NSURL.init(string: urlStr)!)
        }
        
        //        secretCode = self.randomStringWithLength(5) as String
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.navigationBarHidden = false
        
        self.buildScrollView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func randomStringWithLength (len : Int) -> NSString {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        let randomString : NSMutableString = NSMutableString(capacity: len)
        
        for (var i=0; i < len; i++){
            let length = UInt32 (letters.length)
            let rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.characterAtIndex(Int(rand)))
        }
        
        return randomString
    }
    // MARK: - UI Functions
    func buildScrollView() {
        
        let height = SCRN_HEIGHT-49-64
        
        scrollView.contentSize = CGSizeMake(SCRN_WIDTH*4, height)
        
        step1View.frame = CGRectMake(0, 0, SCRN_WIDTH, height)
        step2View.frame = CGRectMake(SCRN_WIDTH, 0, SCRN_WIDTH, height)
        step3View.frame = CGRectMake(SCRN_WIDTH*2, 0, SCRN_WIDTH, height)
        step4View.frame = CGRectMake(SCRN_WIDTH*3, 0, SCRN_WIDTH, height)
        //        step5View.frame = CGRectMake(SCRN_WIDTH*4, 0, SCRN_WIDTH, height)
        
        scrollView.addSubview(step1View)
        scrollView.addSubview(step2View)
        scrollView.addSubview(step3View)
        scrollView.addSubview(step4View)
        //        scrollView.addSubview(step5View)
    }
    
    // MARK: - UIButtonAction
    
    @IBAction func onClickProfessionDropDown(sender: AnyObject) {
        if professionDropDown == nil {
            professionDropDown = NIDropDown().showDropDown(profDropDownButton,  150, profArray, [], "down") as! NIDropDown
            professionDropDown.delegate = self
        } else {
            professionDropDown.hideDropDown(profDropDownButton)
            professionDropDown = nil
        }
    }
    
    @IBAction func onClickLocationYes(sender: AnyObject) {
        // Get updated location information
        if CLLocationManager.locationServicesEnabled() {
            APPDELGATE.startLocationTracking()
            
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
                    
                    //                    Utilities.showMsgWithTitle("Location Added!", message: "\(placeMark.locality!) \(placeMark.country!)", delegate: self)
                    
                    self.step4View.subviews.forEach { subview in
                        subview.hidden = true
                    }
                    self.step4ContentView.hidden = false
                    
                    self.locationTextField.text = "\(placeMark.locality!), \(placeMark.administrativeArea!)"
                    self.locationYesButton.hidden = true
                    self.locationLaterButton.hidden = true
                    
                    self.isLocationAdded = true
                }
            })
        } else {
            Utilities.showMsg("Locatin is not enabled! Please go to Settings and enable it!", delegate: self)
            return
        }
    }
    
    @IBAction func onClickLocationLater(sender: AnyObject) {
        step4View.subviews.forEach { subview in
            subview.hidden = true
        }
        isLocationAdded = false
        step4ContentView.hidden = false
    }
    
    
    @IBAction func onClickBack(sender: AnyObject) {
        
        if curStep == 0 {
            self.navigationController?.popViewControllerAnimated(true)
        } else if curStep > 0 {
            curStep--
            self.updateContent()
        }
    }
    
    @IBAction func onClickSendCode(sender: AnyObject) {
        let phoneNum = NSString.init(string: phoneTextField.text!).convertFormatedPhoneNumberToSimpleNumber()
        if phoneNum.isEmpty {
            Utilities.showMsg("Please input the correct phone number!", delegate: self)
            return
        }
        
        SVProgressHUD.show()
        let url : String = "http://partnaappserv.us/apihandler.php?action=sendMessage&message=\(secretCode)&phone_number=\(phoneNum)"
        let request : NSMutableURLRequest = NSMutableURLRequest()
        request.URL = NSURL(string: url)
        request.HTTPMethod = "GET"
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue()) { (response, data, error) -> Void in
            SVProgressHUD.dismiss()
            
            let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding) as! String
            if dataString == "success" {
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    Utilities.showMsg("Successfully sent!", delegate: self)
                })
            } else {
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    Utilities.showMsg(dataString, delegate: self)
                })
                
            }
        }
    }
    
    @IBAction func onClickNext(sender: AnyObject) {
        
        //        if !isComp && curStep == 0 && profession.isEmpty {
        //            Utilities.showMsg("Select profession!", delegate: self)
        //            return
        //        }
        if (curStep == 0) {
            if (fNameTextField.text!.isEmpty || emailTextField.text!.isEmpty || usernameTextField.text!.isEmpty || lNameTextField.text!.isEmpty || pwdTextField.text!.isEmpty || cfrmPwdTextField.text!.isEmpty
                ) {
                    Utilities.showMsg("Please fill up all input fields!", delegate: self)
                    return
            }
            
            if Utilities.isValidEmail(emailTextField.text!) == false {
                Utilities.showMsg("Please input valid email address!", delegate: self)
                return
            }
            
            if pwdTextField.text != cfrmPwdTextField.text {
                Utilities.showMsg("Password is not correct!", delegate: self)
                return
            }
            
            SVProgressHUD.show()
            PNAPIClient.sharedInstance.checkIfUsernameExists(usernameTextField.text!, callback: { (isExist, error) -> Void in
                SVProgressHUD.dismiss()
                if isExist {
                    Utilities.showMsg("Someone already has that username.  :( Let’s try another one.", delegate: self)
                    return
                } else {
                    PNAPIClient.sharedInstance.checkIfEmailExists(self.emailTextField.text!, callback: { (isExist, error) -> Void in
                        SVProgressHUD.dismiss()
                        if isExist {
                            Utilities.showMsg("This e-mail is already in our system. Sure you don't have an account?", delegate: self)
                            return
                        } else {
                            self.curStep++
                            self.updateContent()
                        }
                        self.view.endEditing(true)
                    })
                }
                self.view.endEditing(true)
            })
            
            return
        }
        
        if curStep == 1 {
            //            if phoneTextField.text!.isEmpty {
            //                Utilities.showMsg("Please input phone number!", delegate: self)
            //                return
            //            }
            
            if verifyCodeTextField.text!.isEmpty {
                Utilities.showMsg("Please input verification code!", delegate: self)
                return
            }
            
            if verifyCodeTextField.text != secretCode {
                Utilities.showMsg("Uh oh, that doesn't match the verification code sent to you. Try again.", delegate: self)
                return
            }
            self.view.endEditing(true)
        }
        
        if curStep == 2 {
            if profDropDownButton.titleForState(.Normal) == nil {
                Utilities.showMsg("Please choose your profession!", delegate: self)
                return
            }
            if avatarImage.image == nil {
                Utilities.showMsg("Please upload a profile picture, so creators can see who you are.", delegate: self)
                return
            }
        }
        
        if curStep == 3 {
            if introTextView.text.isEmpty {
                Utilities.showMsg("Tell us a little something about yourself and what you do.", delegate: self)
                return
            }
            if websiteTextField!.text!.isEmpty {
                Utilities.showMsg("Connect your website so that you can show off what you do.", delegate: self)
                return
            }
            //            self.performSegueWithIdentifier("ShowKickAssView", sender: self)
            self.onClickIamDone(UIButton())
        } else {
            curStep++
            self.updateContent()
        }
        //        if (curStep == 3) {
        //            pageControl.hidden = true
        //        } else {
        //            pageControl.hidden = false
        //        }
    }
    
    func updateContent() {
        let titleArray = ["ACCOUNT SETUP", "VERIFY PHONE", "PROFILE SETUP", "ABOUT YOU"]
        self.title = titleArray[curStep]
        
        scrollView.setContentOffset(CGPointMake(SCRN_WIDTH * CGFloat(curStep), 0), animated: true)
        
        if curStep == 0 {
            step1Table.reloadData()
        }
        pageControl.currentPage = curStep
    }
    
    @IBAction func onClickIamDone(sender: AnyObject) {
        
        //        if locationItem == nil {
        //            Utilities.showMsg("Location is not added!", delegate: self)
        //            return
        //        }
        
        SVProgressHUD.show()
        //        if isComp {
        //
        //            if SharedDataManager.sharedInstance.isFBLogin == true {
        //                let imageData = UIImagePNGRepresentation(avatarImage.image!)
        //
        //                PNAPIClient.sharedInstance.signupCompanyToFacebook(compNameTextField!.text!, username: self.usernameTextField.text!, email: self.emailTextField.text!, website: self.websiteTextField.text!, password: self.pwdTextField.text!, description: self.descTextView.text, avatarImg: imageData, locationName: self.locationItem!.name!, coordinate: locationItem!.placemark.coordinate, callback: { (nsData, error, succeed) -> Void in
        //
        //                    SVProgressHUD.dismiss()
        //
        //                    if error == nil && succeed == true {
        //                        SharedDataManager.sharedInstance.userName = self.usernameTextField.text!
        //                        SharedDataManager.sharedInstance.password = self.pwdTextField.text!
        //
        //                        self.performSegueWithIdentifier("ShowOnBoardingVC", sender: self)
        //                    } else {
        //                        Utilities.showMsg(error?.userInfo["error"] as! String, delegate: self)
        //                    }
        //                })
        //            } else {
        //                let imageData = UIImagePNGRepresentation(avatarImage.image!)
        //
        //                PNAPIClient.sharedInstance.signUpCompany(compNameTextField!.text!, username: self.usernameTextField.text!, email: self.emailTextField.text!, website: self.websiteTextField.text!, password: self.pwdTextField.text!, description: self.descTextView.text, avatarImg: imageData, locationName: self.locationItem!.name!, coordinate: locationItem!.placemark.coordinate, callback: { (nsData, error) -> Void in
        //
        //                    SVProgressHUD.dismiss()
        //
        //                    if error == nil {
        //                        SharedDataManager.sharedInstance.userName = self.usernameTextField.text!
        //                        SharedDataManager.sharedInstance.password = self.pwdTextField.text!
        //
        //                        self.performSegueWithIdentifier("ShowOnBoardingVC", sender: self)
        //                    } else {
        //                        Utilities.showMsg(error?.userInfo["error"] as! String, delegate: self)
        //                    }
        //                })
        //            }
        //        } else {
        
        let fullName = "\(fNameTextField.text!) \(lNameTextField.text!)"
        
        let phoneNum = NSString.init(string: phoneTextField.text!).convertFormatedPhoneNumberToSimpleNumber()
        
        if SharedDataManager.sharedInstance.isFBLogin == true {
            let imageData = UIImagePNGRepresentation(avatarImage.image!)
            let facebookID = SharedDataManager.sharedInstance.facebookInfo["id"] as! String
            
            PNAPIClient.sharedInstance.signupUserToFacebook(fullName, username: usernameTextField.text!, email: emailTextField.text!, profession: profDropDownButton.titleForState(.Normal)!, password: pwdTextField.text!, avatarImg: imageData, locationName: locationTextField.text!, facebookID: facebookID, phoneNumber: phoneNum, website: websiteTextField.text!, bio: introTextView.text, coordinate: APPDELGATE.locationTracker.myLocation, callback: { (nsData, error, succeed) -> Void in
                
                SVProgressHUD.dismiss()
                if error == nil && succeed == true {
                    SharedDataManager.sharedInstance.userName = self.usernameTextField.text!
                    SharedDataManager.sharedInstance.password = self.pwdTextField.text!
                    
                    self.performSegueWithIdentifier("ShowKickAssView", sender: self)
                } else {
                    Utilities.showMsg(error?.userInfo["error"] as! String, delegate: self)
                }
            })
        } else {
            let imageData = UIImagePNGRepresentation(avatarImage.image!)
            
            PNAPIClient.sharedInstance.signUpUser(fullName, username: usernameTextField.text!, email: emailTextField.text!, profession: profDropDownButton.titleForState(.Normal)!, password: pwdTextField.text!, avatarImg: imageData, locationName: locationTextField.text!, phoneNumber: phoneNum, website: websiteTextField.text!, bio: introTextView.text, coordinate: APPDELGATE.locationTracker.myLocation, callback: { (nsData, error) -> Void in
                
                SVProgressHUD.dismiss()
                
                if error == nil {
                    SharedDataManager.sharedInstance.userName = self.usernameTextField.text!
                    SharedDataManager.sharedInstance.password = self.pwdTextField.text!
                    
                    self.performSegueWithIdentifier("ShowKickAssView", sender: self)
                } else {
                    Utilities.showMsg(error?.userInfo["error"] as! String, delegate: self)
                }
            })
        }
        //        }
    }
    
    @IBAction func onClickPhoto(sender: AnyObject) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        // 1
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .ActionSheet)
        
        // 2
        let photoLibAction = UIAlertAction(title: "Photo Library", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .PhotoLibrary
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
        })
        
        let cameraAction = UIAlertAction(title: "Camera", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .Camera
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
        })
        
        //
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        // 4
        optionMenu.addAction(photoLibAction)
        optionMenu.addAction(cameraAction)
        optionMenu.addAction(cancelAction)
        
        // 5
        self.presentViewController(optionMenu, animated: true, completion: nil)
        
    }
    
    @IBAction func onClickIamcompany(sender: AnyObject) {
        
        isComp = true
        self.onClickNext(UIButton())
    }
    
    @IBAction func onClickLocationDone(sender: AnyObject) {
        
        pickerContainer.hidden = true
    }
    
    @IBAction func onClickProfession(sender: AnyObject) {
        
        for button in professionButtons {
            button.selected = false
        }
        (sender as! UIButton).selected = !(sender as! UIButton).selected
        
        if sender.tag != 6 {
            profession = professions[sender.tag - 1]
        } else {
            profession = ""
        }
    }
    
    // MARK: - UITextViewDelegate
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        
        tableBtmConstraint.constant = 100
        //        self.performSelector(Selector("moveTableOffset"), withObject: nil, afterDelay: 0.5)
        return true
    }
    
    func moveTableOffset() {
        
        //        signupTable.scrollToRowAtIndexPath(NSIndexPath.init(forRow: 5, inSection: 0), atScrollPosition: .Top, animated: true)
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if textField == locationTextField {
            if textField.text!.isEmpty {
                Utilities.showMsg("Input location field!", delegate: self)
                return false
            }
            googlePlace.searchLocationNameWithDelegate(locationTextField.text!)
        }
        textField.resignFirstResponder()
        tableBtmConstraint.constant = 8
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if tableBtmConstraint != nil {
            tableBtmConstraint.constant = 100
        }
    }
    
    // MARK: - UITextViewDelegate
    func textViewDidEndEditing(textView: UITextView) {
        
        
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldDidChange(noti: NSNotification) {
        let textField = noti.object as! UITextField
        if textField == phoneTextField {
            phoneTextField.text = NSString.init(string: phoneTextField.text!).formatPhoneNumber(phoneTextField.text, deleteLastChar: false)
        }
    }
    
    // MARK: - NIDropDownDelegate
    func niDropDownDelegateMethod(sender: NIDropDown!, atIndex index: Int) {
        professionDropDown = nil
        if profArray[index] == "Other" {
            Utilities.showMsg("Aw man, we don't have your profession yet. Shoot us an e-mail and let us know so that we can get it in the system: support@partnrinc.com", delegate: self)
        }
    }
    
    // MARK: - UITableViewDataSource
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if isComp && indexPath.row == 5 {
            return 100
        }
        return IS_IPHONE4 || IS_IPHONE5 ? 60 : 70
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tableView == step1Table ? step1Identifiers.count : step3Identifiers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = tableView == step1Table ? step1Identifiers[indexPath.row] : step3Identifiers[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        
        if cell.isKindOfClass(SignUpEditTableCell) {
            //            if cellIdentifier == "DescCell" {
            //                let textView = cell.viewWithTag(1) as! UITextView
            //                textView.delegate = self
            //                textView.layer.borderColor = UIColor.whiteColor().CGColor
            //                textView.layer.borderWidth = 1.0
            //                textView.layer.cornerRadius = 3
            //            } else {
            (cell as! SignUpEditTableCell).textField.delegate = self
            if tableView == step1Table {
                if indexPath.row == 0 {
                    fNameTextField = (cell as! SignUpEditTableCell).textField
                    if SharedDataManager.sharedInstance.isFBLogin == true {
                        fNameTextField.text = SharedDataManager.sharedInstance.facebookInfo["first_name"]! as? String
                    }
                } else if indexPath.row == 1 {
                    lNameTextField = (cell as! SignUpEditTableCell).textField
                    if SharedDataManager.sharedInstance.isFBLogin == true {
                        lNameTextField.text = SharedDataManager.sharedInstance.facebookInfo["last_name"]! as? String
                    }
                } else if indexPath.row == 2 {
                    usernameTextField = (cell as! SignUpEditTableCell).textField
                    if SharedDataManager.sharedInstance.isFBLogin == true {
                        usernameTextField.text = SharedDataManager.sharedInstance.facebookInfo["name"]! as? String
                    }
                } else if indexPath.row == 3 {
                    emailTextField = (cell as! SignUpEditTableCell).textField
                    if SharedDataManager.sharedInstance.isFBLogin == true {
                        emailTextField.text = SharedDataManager.sharedInstance.facebookInfo["email"]! as? String
                    }
                } else if indexPath.row == 4 {
                    pwdTextField = (cell as! SignUpEditTableCell).textField
                } else if indexPath.row == 5 {
                    cfrmPwdTextField = (cell as! SignUpEditTableCell).textField
                }
            } else if tableView == step2Table {
                if indexPath.row == 0 {
                    usernameTextField = (cell as! SignUpEditTableCell).textField
                } else if indexPath.row == 1 {
                    pwdTextField = (cell as! SignUpEditTableCell).textField
                } else if indexPath.row == 2 {
                    cfrmPwdTextField = (cell as! SignUpEditTableCell).textField
                }
            }
            //                if isComp {
            //                    if indexPath.row == 0 {
            //                        compNameTextField = (cell as! SignUpEditTableCell).textField
            //                        if SharedDataManager.sharedInstance.isFBLogin == true {
            //                            compNameTextField.userInteractionEnabled = false
            //                            compNameTextField.text = SharedDataManager.sharedInstance.facebookInfo["name"] as? String
            //                        }
            //                    } else if indexPath.row == 1 {
            //                        usernameTextField = (cell as! SignUpEditTableCell).textField
            //                    } else if indexPath.row == 2 {
            //                        emailTextField = (cell as! SignUpEditTableCell).textField
            //                        if SharedDataManager.sharedInstance.isFBLogin == true {
            //                            emailTextField.userInteractionEnabled = false
            //                            emailTextField.text = SharedDataManager.sharedInstance.facebookInfo["email"] as? String
            //                        }
            //                    } else if indexPath.row == 3 {
            //                        pwdTextField = (cell as! SignUpEditTableCell).textField
            //                        cfrmPwdTextField = (cell as! SignUpEditTableCell).textField
            //                    } else if indexPath.row == 4 {
            //                        websiteTextField = (cell as! SignUpEditTableCell).textField
            //                    } else if indexPath.row == 5 {
            //                        descTextView = (cell as! SignUpEditTableCell).viewWithTag(1) as! UITextView
            //                        descTextView.delegate = self
            //                    }
            //                } else {
            //                    if indexPath.row == 0 {
            //                        nameTextField = (cell as! SignUpEditTableCell).textField
            //                        if SharedDataManager.sharedInstance.isFBLogin == true {
            //                            nameTextField.userInteractionEnabled = false
            //                            nameTextField.text = SharedDataManager.sharedInstance.facebookInfo["name"] as? String
            //                        }
            //                    } else if indexPath.row == 1 {
            //                        usernameTextField = (cell as! SignUpEditTableCell).textField
            //                    } else if indexPath.row == 2 {
            //                        emailTextField = (cell as! SignUpEditTableCell).textField
            //                        if SharedDataManager.sharedInstance.isFBLogin == true {
            //                            emailTextField.userInteractionEnabled = false
            //                            emailTextField.text = SharedDataManager.sharedInstance.facebookInfo["email"] as? String
            //                        }
            //                    } else if indexPath.row == 3 {
            //                        pwdTextField = (cell as! SignUpEditTableCell).textField
            //                    } else if indexPath.row == 4 {
            //                        cfrmPwdTextField = (cell as! SignUpEditTableCell).textField
            //                    }
            //                }
            //            }
        }
        
        return cell
    }
    
    
    // MARK: - GooglePlacesDelegate
    func googlePlacesSearchResult(locationArray: [MKMapItem]) {
        
        print(locationArray)
        print(locationArray[0].placemark.coordinate)
        self.locationArray = locationArray
        pickerContainer.hidden = false
        locationPickerView.reloadAllComponents()
    }
    
    // MARK: - UIPickerViewDataSource
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return locationArray.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return locationArray[row].name
    }
    
    // MARK: - UIPickerViewDelegate
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        locationItem = locationArray[row]
        locationTextField.text = locationArray[row].name
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        let resizedImage = image .imageByScalingAndCroppingForSize(CGSizeMake(200, 200))
        avatarImage.image = resizedImage
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - OtherProffViewControllerDelegate
    func professionDidSelect(professionStr: String) {
        
        profession = professionStr
        self.onClickNext(UIButton())
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.destinationViewController.isKindOfClass(OtherProffViewController) {
            (segue.destinationViewController as! OtherProffViewController).delegate = self
        }
    }
    
}

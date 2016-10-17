//
//  CreatePostViewController.swift
//  Partnr
//
//  Created by Yosemite on 2/18/16.
//  Copyright © 2016 YulianMobile. All rights reserved.
//

import UIKit
import ParseUI

class PostProjectViewController: CustomBaseViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, SBPickerSelectorDelegate, NIDropDownDelegate{
    
    @IBOutlet weak var projectTable: UITableView!
    @IBOutlet weak var tableBtmConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableTopConstraint: NSLayoutConstraint!
    
    var briefUserData: UserData? = nil
    
    let imagePicker = UIImagePickerController()
    var datePicker: SBPickerSelector!
    var professionPicker: SBPickerSelector!

    var photoButton: UIButton?
    var nameTextField: NSCustomTextField?
    var briefTextView: UITextView?
    var deliverablesTextField: NSCustomTextField?
    var priceTextField: NSCustomTextField?
    var duedateTextField: NSCustomTextField?
    var dueDate: NSDate? = nil
    var clientTextField: NSCustomTextField?
    var profDropDown: NIDropDown!
    var professionDropDown: UIButton!
    var postButton: UIButton!

    var isPhotoAdded: Bool = false

    var identifiers = ["NameCell", "ProfessionCell", "ClientCell", "BriefCell", "DeliverablesCell", "PriceCell", "PostButtonCell"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.imagePicker.delegate = self
        imagePicker.navigationBar.translucent = false
        imagePicker.navigationBar.barTintColor = NAV_COLOR
        imagePicker.navigationBar.tintColor = UIColor.whiteColor()
        imagePicker.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName : UIColor.whiteColor()
        ]
        self.configureUI()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillChangeFrame:"), name: UIKeyboardWillChangeFrameNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - NotificationHandler
    func keyboardWillChangeFrame(notification: NSNotification) {
        let keyInfo = notification.userInfo
        let frameBegin = keyInfo![UIKeyboardFrameEndUserInfoKey]
        let keyboardBeginRect = frameBegin?.CGRectValue
        tableBtmConstraint.constant = (keyboardBeginRect?.size.height)!
    }
    
    // MARK: - UI Configure
    func configureUI() {
        self.tableTopConstraint.constant = 8
        
        self.datePicker = SBPickerSelector.picker()
        self.datePicker.pickerType = SBPickerSelectorType.Date
        self.datePicker.onlyDayPicker = true
        self.datePicker.datePickerType = SBPickerSelectorDateType.Default
        self.datePicker.doneButton?.title = "Done"
        self.datePicker.cancelButton?.title = "Cancel"
        self.datePicker.delegate=self
        
        self.professionPicker = SBPickerSelector.picker()
        self.professionPicker.pickerType = SBPickerSelectorType.Text
        self.professionPicker.pickerData = PROF_LIST
        self.professionPicker.doneButton?.title = "Done"
        self.professionPicker.cancelButton?.title = "Cancel"
        self.professionPicker.delegate=self
    }
    
    // MARK: - UIButton Action
    
    func onClickPost(sender: AnyObject) {
        if !Utilities.isValidData(nameTextField?.text) ||
         !Utilities.isValidData(clientTextField?.text) ||
         !Utilities.isValidData(briefTextView?.text) ||
         !Utilities.isValidData(deliverablesTextField?.text) ||
         !Utilities.isValidData(priceTextField?.text) ||
         !Utilities.isValidData(duedateTextField?.text) {
            
            Utilities.showMsg("Please input all field!", delegate: self)
            return
        }
        
        if Int(priceTextField!.text!)! < 50 {
            Utilities.showMsg("Sorry! There is a $50.00 minimum for projects posted in Partnr.", delegate: self)
            return
        }
        
        if isPhotoAdded == false {
            Utilities.showMsg("One sec! Before you can post this project, please upload a photo", delegate: self)
            return
        }
            
            // create the alert
        let alert = UIAlertController(title: kTitle_APP, message: "You are about to send this brief to the selected user. Are you sure you want to do that?", preferredStyle: UIAlertControllerStyle.Alert)
            
            // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            NSLog("OK Pressed")
            SVProgressHUD.show()
            PNAPIClient.sharedInstance.postProject(self.nameTextField!.text!, profession: self.professionDropDown!.titleLabel!.text!, client: self.clientTextField!.text!, brief: self.briefTextView!.text!, deliverables: self.deliverablesTextField!.text!, price: Double(self.priceTextField!.text!)!, dueDate: self.dueDate!, image: self.photoButton!.imageForState(.Normal)!) { (finished, error) -> Void in
                SVProgressHUD.dismiss()
                    
                self.navigationController?.popViewControllerAnimated(true)
                self.performSelector(Selector("showProjectView"), withObject: nil, afterDelay: 0.3)
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel){
            UIAlertAction in
            NSLog("Cancel Pressed")
        })
            
        // show the alert
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func onClickImage(sender: AnyObject) {
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
    func showProjectView() {
        SharedDataManager.sharedInstance.rootVC.showProjectView()
    }
    
    // MARK: - SBPickerSelectorDelegate
    func pickerSelector(selector: SBPickerSelector!, selectedValue value: String!, index idx: Int) {
        
    }
    
    func pickerSelector(selector: SBPickerSelector!, dateSelected date: NSDate!) {
        dueDate = date
        duedateTextField?.text = Utilities.stringFromDate(dueDate, formatStr: "MMM dd, yyyy")
        tableBtmConstraint.constant = 0
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        picker .dismissViewControllerAnimated(true) { () -> Void in
            
            let wid = SCRN_WIDTH * 1.5
            let hei = image.size.height * (wid / image.size.width)
            
            let resizedImage = image.imageByScalingAndCroppingForSize(CGSizeMake(wid, hei))
            if resizedImage != nil {
                self.isPhotoAdded = true
                self.photoButton!.setImage(resizedImage, forState: .Normal)
            } else {
                Utilities.showMsg("Invalid photo, please try again", delegate: self)
            }
            //            self.performSelector(Selector("addPhotoToDialog:"), withObject: image, afterDelay: 2)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - UITableviewControllerDataSource
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int
    {
        return identifiers.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return indexPath.row == 3 ? 100 : 50
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier(identifiers[indexPath.row], forIndexPath: indexPath)
        
        if indexPath.row == 0 {
            nameTextField = cell.viewWithTag(1) as? NSCustomTextField
            nameTextField?.delegate = self
            photoButton = cell.viewWithTag(2) as? UIButton
        } else if indexPath.row == 1 {
            professionDropDown = cell.viewWithTag(1002) as? UIButton
            professionDropDown.addTarget(self, action: Selector("onClickFindPartnrProfession:"), forControlEvents: .TouchUpInside)
        } else if indexPath.row == 2 {
            clientTextField = cell.viewWithTag(3) as? NSCustomTextField
            clientTextField?.delegate = self
        } else if indexPath.row == 3 {
            briefTextView = cell.viewWithTag(4) as? UITextView
            briefTextView?.delegate = self
        } else if indexPath.row == 4 {
            deliverablesTextField = cell.viewWithTag(5) as? NSCustomTextField
            deliverablesTextField?.delegate = self
        } else if indexPath.row == 5 {
            priceTextField = cell.viewWithTag(6) as? NSCustomTextField
            duedateTextField = cell.viewWithTag(7) as? NSCustomTextField
            priceTextField?.delegate = self
            duedateTextField?.delegate = self
        } else if indexPath.row == 6 {
            postButton = cell.viewWithTag(8) as? UIButton
            postButton.layer.cornerRadius = postButton.frame.size.height / 2
            postButton.backgroundColor = UIColor(red: 255/255, green: 181/255, blue: 9/255, alpha: 1.0)
            postButton.titleLabel?.textColor = UIColor.whiteColor()
            postButton.titleLabel?.text = "POST BRIEF"
            postButton.addTarget(self, action: Selector("onClickPost:"), forControlEvents: .TouchUpInside)
        }
        
        return cell
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
//        self.view.endEditing(true)
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        tableBtmConstraint.constant = 260.0
        
        if textField == duedateTextField {
            self.view.endEditing(true)
            self.datePicker.showPickerOver(self)
            self.performSelector(Selector("scrollToBottom"), withObject: nil, afterDelay: 0.5)
            return false
        }
        
        return true
    }
    
    func scrollToBottom() {
        projectTable.scrollToRowAtIndexPath(NSIndexPath.init(forRow: 5, inSection: 0), atScrollPosition: .Bottom, animated: true)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        tableBtmConstraint.constant = 0
//        if textField == nameTextField {
//            nameLabel.text = nameTextField?.text
//        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        tableBtmConstraint.constant = 0
        
//        nameLabel.text = nameTextField?.text
        
        return true
    }
    
    // MARK: - UITextViewDelegate
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        tableBtmConstraint.constant = 260.0
        return true
    }
    
    // MARK: - NIDropDownDelegate
    func niDropDownDelegateMethod(sender: NIDropDown!, atIndex index: Int) {
        
    }
    
    func onClickFindPartnrProfession(sender: AnyObject) {
        let labelArray = PROF_LIST
        
        if profDropDown == nil {
            profDropDown = NIDropDown().showDropDown(professionDropDown, 300, labelArray, [], "down") as! NIDropDown
            profDropDown.delegate = self
            profDropDown.frame.origin.y = 90
            self.view.addSubview(profDropDown)
        } else {
            profDropDown.hideDropDown(professionDropDown)
            profDropDown = nil
        }
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

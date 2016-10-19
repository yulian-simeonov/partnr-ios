//
//  ModalDialogViewController.swift
//  Partnr
//
//  Created by Yulian Simeonov on 2/3/16.
//  Copyright © 2016 YulianMobile. All rights reserved.
//

import UIKit

import ParseUI

class ModalDialogViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate, TLTagsControlDelegate, NIDropDownDelegate {

    var dialogType: EDialogType!
    var respondBlock: ((nsData:AnyObject?, error: NSError?) -> (Void))?
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var captionTextView: NSPlaceholderTextView!
    @IBOutlet weak var tagControl: TLTagsControl!
    @IBOutlet weak var labelButton: UIButton!
    @IBOutlet weak var partnrButton: UIButton!
    
    var photoLabel: EPhotoLabel?
    var noteLabel: ENoteLabel?
    // Project Type UI Components
    @IBOutlet weak var projectTypePopup: UIView!
    @IBOutlet weak var otherTypeTextField: UITextField!
    
    // Contratulation Modal
    @IBOutlet weak var avatarImage: PFImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    var projectData: ProjectData? = nil
    
    // Confirm Popup
    var partnrName = ""
    @IBOutlet weak var confirmDescLabel: UILabel!
    
    // Share Note Modal
    @IBOutlet weak var shareNoteTextView: NSPlaceholderTextView!
    
    var projectSelectionDict: NSMutableDictionary!
    
    var labelDropDown: NIDropDown!
    var profDropDown: NIDropDown!

    // FIND PARTNR Modal
    @IBOutlet weak var professionDropDown: UIButton!
    
    
    class func showDialogWithType(dialogType: EDialogType, delegate: AnyObject, callback:((nsData:AnyObject?, error: NSError?) -> Void)) -> ModalDialogViewController {
        
        var nibName: String = ""
        if dialogType == EDialogType.SharePhoto {
            nibName = "ModalDialogViewController"
        } else if dialogType == .ChooseProjectType {
            nibName = "ProjectTypeModalView"
        } else if dialogType == .Congratulation {
            nibName = "CongratulationModalView"
        } else if dialogType == .ConfirmAlert {
            nibName = "ConfirmModalView"
        } else if dialogType == .ShareNote {
            nibName = "ShareNoteModalView"
        } else if dialogType == .FindPartnr {
            nibName = "FindPartnrModalView"
        }
        
        let modalDialog = ModalDialogViewController.init(nibName: nibName, bundle: NSBundle.mainBundle())
        modalDialog.providesPresentationContextTransitionStyle = true
        modalDialog.definesPresentationContext = true
        modalDialog.modalPresentationStyle = UIModalPresentationStyle.Custom
        modalDialog.modalTransitionStyle = .CrossDissolve
        modalDialog.respondBlock = callback
        modalDialog.dialogType = dialogType

        
        delegate.presentViewController(modalDialog, animated: true, completion: nil)
        
        return modalDialog
    }
    
    // Open Congratulations
    class func showCongratulationPopUp(projectData: ProjectData, delegate: AnyObject, callback:((nsData:AnyObject?, error: NSError?) -> Void)) {
        let dialog = ModalDialogViewController.showDialogWithType(.Congratulation, delegate: delegate) { (nsData, error) -> Void in
            
            callback(nsData: nsData, error: error)
        }
        dialog.projectData = projectData
        dialog.updateContent()
    }
    
    // Open Confirm Dialog
    class func showConfirmPopUp(partnrName: String, delegate: AnyObject, callback:((nsData:AnyObject?, error: NSError?) -> Void)) {
        let dialog = ModalDialogViewController.showDialogWithType(.ConfirmAlert, delegate: delegate) { (nsData, error) -> Void in
            
            callback(nsData: nsData, error: error)
        }
        dialog.partnrName = partnrName
        dialog.updateContent()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if dialogType == EDialogType.SharePhoto {
            self.tagControl.tagPlaceholder = "Add tags"
            tagControl.mode = .Edit
            tagControl.tags = []
            tagControl.reloadTagSubviews()
            
        } else if dialogType == EDialogType.ChooseProjectType {
            projectTypePopup.layer.cornerRadius = 5
            projectSelectionDict = NSMutableDictionary()
        } else if dialogType == EDialogType.Congratulation {
//            if self.projectData != nil {
//                self.updateContent()
//            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func updateContent() {
        if self.dialogType == .Congratulation {
            let pointer = PFUser.init(withoutDataWithClassName: "_User", objectId: projectData?.userId)
            PNAPIClient.sharedInstance.fetchUser(pointer) { (userData, error) -> Void in
                if userData != nil && error == nil {
                    self.avatarImage.file = userData?.avatarImg
                    self.avatarImage.loadInBackground()
                    
                    self.usernameLabel.text = userData?.name
                    
                    let myAttributes = [ NSFontAttributeName: UIFont.boldSystemFontOfSize(15.0)]
                    
                    // Initialize with a string only
                    let attrString1 = NSAttributedString(string: "Partnr'd with ")
                    // Initialize with a string and inline attribute(s)
                    let attrString2 = NSAttributedString(string: (userData?.name)!, attributes: myAttributes)
                    let attrString3 = NSAttributedString(string: " on ")
                    // Initialize with a string and separately declared attribute(s)
                    let attrString4 = NSAttributedString(string: (self.projectData?.name)!, attributes: myAttributes)
                    
                    let mutableStr = NSMutableAttributedString.init()
                    mutableStr.appendAttributedString(attrString1)
                    mutableStr.appendAttributedString(attrString2)
                    mutableStr.appendAttributedString(attrString3)
                    mutableStr.appendAttributedString(attrString4)
                    
                    self.descLabel.attributedText = mutableStr
                }
            }
        } else if self.dialogType == .ConfirmAlert {
            self.confirmDescLabel.text = "Are you sure you want to Partnr with \(self.partnrName)?"
        }
    }
    
    // MARK: - PhotoShare Dialog
    func addPhoto(photo: UIImage) {
        
        photoImageView.image = photo
    }
    
    // MARK: - UIButton Action
    
    @IBAction func onClickShare(sender: AnyObject) {
        
        if photoLabel == nil {
            Utilities.showMsg("Oops! Please label your image. :)", delegate: self)
            return
        }
        
        if photoImageView.image != nil {
            SVProgressHUD.show()
            PNAPIClient.sharedInstance.sharePhotoToNews(photoImageView.image!, captionStr: captionTextView.text, label: photoLabel!, tagArray: tagControl.tags, projectId: "", callback: { (nsData, error) -> Void in
                SVProgressHUD.dismiss()
                
                self.dismissViewControllerAnimated(true) { () -> Void in
                    if self.respondBlock != nil {
                        self.respondBlock!(nsData: nsData, error: nil)
                    }
                }
            })
        } else {
            Utilities.showMsg("Empty image", delegate: self)
        }
    }
    
    @IBAction func onClickBack(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true) { () -> Void in
            if self.respondBlock != nil {
                self.respondBlock!(nsData: nil, error: nil)
            }
        }
    }

    @IBAction func onClickClose(sender: AnyObject) {
        self.dismissViewControllerAnimated(true) { () -> Void in
         
        }
    }
    
    // MARK: - Project Type Button Action
    
    @IBAction func onClickLabel(sender: AnyObject) {
        let labelArray = dialogType == .ShareNote ? NOTE_LABELS : PHOTO_LABELS
        
        if labelDropDown == nil {
            labelDropDown = NIDropDown().showDropDown(labelButton, dialogType == .ShareNote ? 80: 120, labelArray, [], "down") as! NIDropDown
            labelDropDown.delegate = self
        } else {
            labelDropDown.hideDropDown(labelButton)
            labelDropDown = nil
        }
    }
    
    @IBAction func onClickPartnr(sender: AnyObject) {
        
    }
    
    @IBAction func onClickProjectType(sender: UIButton) {
        if sender.tag == 6 { // Tap SomethingElse
            projectTypePopup.hidden = false
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.projectTypePopup.alpha = 1.0
            })
        } else {
            if sender.selected == false {
                if projectSelectionDict.allKeys.count > 2 {
                    return
                }
                sender.selected = true
                projectSelectionDict.setObject(1, forKey: sender.tag)
            } else {
                sender.selected = false
                projectSelectionDict.removeObjectForKey(sender.tag)
            }
        }
    }
    @IBAction func onClickTick(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true) { () -> Void in
            if self.respondBlock != nil {
                self.respondBlock!(nsData: ["Types":self.projectSelectionDict.allKeys], error: nil)
            }
        }
    }
    
    @IBAction func onClickCancel(sender: AnyObject) {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.projectTypePopup.alpha = 0.0
        }) { (finished) -> Void in
            self.projectTypePopup.hidden = true
        }
    }
    
    @IBAction func onClickSubmit(sender: AnyObject) {
        if !Utilities.isValidData(otherTypeTextField.text) {
            Utilities.showMsg("Please input type name first!", delegate: self)
            return
        }
        self.dismissViewControllerAnimated(true) { () -> Void in
            
        }
    }
    
    // MARK: - Contratulation Modal
    @IBAction func onClickContinue(sender: AnyObject) {
        self.dismissViewControllerAnimated(true) { () -> Void in
            if self.respondBlock != nil {
                self.respondBlock!(nsData: ["PartnrName": self.usernameLabel.text!], error: nil)
            }
        }
    }
    
    // MARK: - ConfirmAlert UIButton Action
    
    @IBAction func onClickNo(sender: AnyObject) {
        self.dismissViewControllerAnimated(true) { () -> Void in
            if self.respondBlock != nil {
                self.respondBlock!(nsData: ["IsYes": false], error: nil)
            }
        }
    }
    
    @IBAction func onClickYes(sender: AnyObject) {
        self.dismissViewControllerAnimated(true) { () -> Void in
            if self.respondBlock != nil {
                self.respondBlock!(nsData: ["IsYes": true], error: nil)
            }
        }
    }
    
    // MARK: - ShareNote Button Action
    
    @IBAction func onClickShareNote(sender: AnyObject) {
        if shareNoteTextView.text.isEmpty {
            Utilities.showMsg("Please input your Note first!", delegate: self)
            return
        }
        
        if noteLabel == nil {
            Utilities.showMsg("Oops! Please label your note. :)", delegate: self)
            return
        }
        
        SVProgressHUD.show()
        PNAPIClient.sharedInstance.shareNoteToNews(shareNoteTextView.text, label: noteLabel!, tagArray: tagControl.tags, callback: { (nsData, error) -> Void in
            SVProgressHUD.dismiss()
            
            self.dismissViewControllerAnimated(true) { () -> Void in
                if self.respondBlock != nil {
                    self.respondBlock!(nsData: nsData, error: nil)
                }
            }
        })
    }
    
    // MARK: - FindPartnr Button Action
    
    @IBAction func onClickFindPartnrProfession(sender: AnyObject) {
        let labelArray = PROF_LIST
        
        if profDropDown == nil {
            profDropDown = NIDropDown().showDropDown(professionDropDown, 300, labelArray, [], "down") as! NIDropDown
            profDropDown.delegate = self
        } else {
            profDropDown.hideDropDown(professionDropDown)
            profDropDown = nil
        }
    }
    
    @IBAction func onClickFindPartnrViewAll(sender: AnyObject) {
    }
    
    @IBAction func onClickFindPartnrSearch(sender: AnyObject) {
        let profession = professionDropDown.titleForState(.Normal)

        if profession == nil || profession?.isEmpty == true || profession == "Other" {
            
            Utilities.showMsg("Select profession first!", delegate: self)
            return
        }
        
        self.dismissViewControllerAnimated(true) { () -> Void in
            if self.respondBlock != nil {
                self.respondBlock!(nsData: ["response": 1, "profession": NSString.init(string: profession!)], error: nil)
            }
        }
    }
    
    @IBAction func onClickFindPartnrCreateProject(sender: AnyObject) {
        self.dismissViewControllerAnimated(true) { () -> Void in
            if self.respondBlock != nil {
                self.respondBlock!(nsData: ["response": 2], error: nil)
            }
        }
    }
    
    @IBAction func onClickFindPartnrViewCommunity(sender: AnyObject) {
        self.dismissViewControllerAnimated(true) { () -> Void in
            if self.respondBlock != nil {
                self.respondBlock!(nsData: ["response": 3], error: nil)
            }
        }
    }
    
    // MARK: - NIDropDownDelegate
    func niDropDownDelegateMethod(sender: NIDropDown!, atIndex index: Int) {
        labelDropDown = nil
        if dialogType == .FindPartnr {
        
        } else if dialogType == .ShareNote {
            noteLabel = ENoteLabel(rawValue: index)
        } else {
            photoLabel = EPhotoLabel(rawValue: index)
        }
    }
    
    // MARK: - UITextViewDelegate
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n" {
            textView.resignFirstResponder()
        }
        return true
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - TLTagsControlDelegate
    func tagsControl(tagsControl: TLTagsControl!, tappedAtIndex index: Int) {
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

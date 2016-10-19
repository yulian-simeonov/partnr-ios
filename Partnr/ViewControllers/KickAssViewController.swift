//
//  KickAssViewController.swift
//  Partnr
//
//  Created by Yulian Simeonov on 5/20/16.
//  Copyright © 2016 YulianMobile. All rights reserved.
//

import UIKit
import Contacts
import MessageUI
import Parse

class ContactData {
    var emailArray = [String]()
    var phoneArray = [String]()
    var avatarImage: UIImage? = nil
    var name = ""
    var isInvited = false
}

class KickAssTableCell: UITableViewCell {

    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var inviteButton: UIButton!
}

class KickAssViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var kickAssTable: UITableView!
    
    let cellIdentifier = "KickAssCell"
    let contactStore = CNContactStore()
    
    var curIndex = 0
    
    lazy var contacts: [ContactData] = {
        let contactStore = CNContactStore()
        let keysToFetch = [
            CNContactFormatter.descriptorForRequiredKeysForStyle(.FullName),
            CNContactEmailAddressesKey,
            CNContactPhoneNumbersKey,
            CNContactImageDataAvailableKey,
            CNContactThumbnailImageDataKey,
            CNContactImageDataKey
        ]
        
        // Get all the containers
        var allContainers: [CNContainer] = []
        do {
            allContainers = try contactStore.containersMatchingPredicate(nil)
        } catch {
            print("Error fetching containers")
        }
        
        var results: [ContactData] = []
        
        // Iterate all containers and append their contacts to our results array
        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainerWithIdentifier(container.identifier)
            
            do {
                let containerResults = try contactStore.unifiedContactsMatchingPredicate(fetchPredicate, keysToFetch: keysToFetch)
                
                for contact in containerResults {
                    
                    
                    var emailArray = [String]()
                    for email in contact.emailAddresses {
                        if let address = email.value as? String {
                            if address.isEmpty == false {
                                emailArray.append(address)
                            }
                        }
                    }
                    
                    var phoneArray = [String]()
                    for phone in contact.phoneNumbers {
                        if let phone = phone.value as? CNPhoneNumber {
                            if phone.stringValue.isEmpty == false {
                                phoneArray.append(phone.stringValue)
                            }
                        }
                    }
                    
                    if emailArray.count > 0 || phoneArray.count > 0 {
                        var contactData = ContactData()
                        contactData.emailArray = emailArray
                        contactData.phoneArray = phoneArray
                        contactData.name = "\(contact.givenName) \(contact.familyName)"
                        if let imageData = contact.imageData {
                            contactData.avatarImage = UIImage.init(data: imageData)
                        }
                        
                        results.append(contactData)
                    }
                }
                
            } catch {
                print("Error fetching results for container")
            }
        }
        
        return results
    }()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func askForContactAccess() {
        let authorizationStatus = CNContactStore.authorizationStatusForEntityType(CNEntityType.Contacts)
        switch authorizationStatus {
        case .Denied, .NotDetermined:
            self.contactStore.requestAccessForEntityType(CNEntityType.Contacts, completionHandler: { (access, accessError) -> Void in
                if !access {
                    if authorizationStatus == CNAuthorizationStatus.Denied {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            let message = "\(accessError!.localizedDescription)\n\nPlease allow the app to access your contacts through the Settings."
                            let alertController = UIAlertController(title: "Contacts", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                            let dismissAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action) -> Void in
                            }
                            alertController.addAction(dismissAction)
                            self.presentViewController(alertController, animated: true, completion: nil)
                        })
                    }
                } else {
                    self.kickAssTable.reloadData()
                }
            })
            break
        default:
            break
        }
    }
    
    // MARK: - UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contacts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! KickAssTableCell
        
        let contact = self.contacts[indexPath.row]
        
        cell.nameLabel.text = contact.name
        if let image = contact.avatarImage {
            cell.avatarImage.image = image
        } else {
            cell.avatarImage.image = UIImage.init(named: "avatar-empty")
        }
        
        cell.inviteButton.tag = indexPath.row
        cell.inviteButton.addTarget(self, action: Selector("onClickInvite:"), forControlEvents: .TouchUpInside)
        cell.inviteButton.selected = contact.isInvited
        
        return cell
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients(["nurdin@gmail.com"])
        mailComposerVC.setSubject("Sending you an in-app e-mail...")
        mailComposerVC.setMessageBody("Sending e-mail in-app is not so bad!", isHTML: false)
        
        return mailComposerVC
    }
    
    func onClickInvite(sender: UIButton) {
        curIndex = sender.tag
        
        let contact = self.contacts[curIndex]
        if contact.phoneArray.count > 0 {
            if !MFMessageComposeViewController.canSendText() {
                print("SMS services are not available")
            } else {
                let messageVC = MFMessageComposeViewController()
                
                messageVC.body = "Join me on Partnr. A place for kick ass creators to transact gigs and collaborate with other kick-ass creators through your own personal network.";
                messageVC.recipients = contact.phoneArray
                messageVC.messageComposeDelegate = self;
                
                self.presentViewController(messageVC, animated: false, completion: nil)
            }
        } else if contact.emailArray.count > 0 {
            if MFMailComposeViewController.canSendMail() {
                let mailComposerVC = MFMailComposeViewController()
                mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
                
                mailComposerVC.setToRecipients(contact.emailArray)
                mailComposerVC.setSubject("Partnr")
                mailComposerVC.setMessageBody("Join me on Partnr. A place for kick ass creators to transact gigs and collaborate with other kick-ass creators through your own personal network.", isHTML: false)
                
                self.presentViewController(mailComposerVC, animated: true, completion: nil)
            } else {
                let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
                sendMailErrorAlert.show()
            }
        }
    }
    
    // MARK: MFMailComposeViewControllerDelegate
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        
        if result == MFMailComposeResultSent {
            self.contacts[curIndex].isInvited = true
            self.kickAssTable.reloadData()
        }
    }
    
    // MARK: MFMessageComposeDelegate
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        switch (result) {
        case MessageComposeResultCancelled:
            print("Message was cancelled")
            self.dismissViewControllerAnimated(true, completion: nil)
        case MessageComposeResultFailed:
            print("Message failed")
            self.dismissViewControllerAnimated(true, completion: nil)
        case MessageComposeResultSent:
            print("Message was sent")
            self.contacts[curIndex].isInvited = true
            self.kickAssTable.reloadData()
            self.dismissViewControllerAnimated(true, completion: nil)
        default:
            break;
        }
    }
    
    // MARK: - UIButtonAction
    @IBAction func onClickBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func onClickLater(sender: AnyObject) {
        self .dismissViewControllerAnimated(true) { () -> Void in
            SharedDataManager.sharedInstance.rootVC.didsignup()
            
            
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

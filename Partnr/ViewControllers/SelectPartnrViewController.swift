//
//  SelectPartnrViewController.swift
//  Partnr
//
//  Created by Yosemite on 5/31/16.
//  Copyright © 2016 YulianMobile. All rights reserved.
//

import UIKit
import ParseUI
import Contacts
import MessageUI
import FBSDKCoreKit

class FriendTableCell: UITableViewCell {
    
    @IBOutlet weak var actionButton: NSLoadingButton!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
}

class PartnrTableCell: UITableViewCell {
    
    @IBOutlet weak var backImage: PFImageView!
    @IBOutlet weak var avatarButton: UIButton!
    @IBOutlet weak var rateButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var professionLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var sharedFriendsLabel: UILabel!
    @IBOutlet weak var availableButton: UIButton!
    @IBOutlet weak var selectPartnrButton: UIButton!
    @IBOutlet weak var avatarImage: UIImageView!
}

class SelectPartnrViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MFMessageComposeViewControllerDelegate {
    
    @IBOutlet weak var partnrTable: UITableView!
    @IBOutlet weak var descLabel: UILabel!
    
    var userArray = [UserData]()
    var profession = ""
    var selIndex = 0
    
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
                                let result = String(phone.stringValue.characters.filter { String($0).rangeOfCharacterFromSet(NSCharacterSet(charactersInString: "0123456789.")) != nil })
                                
                                phoneArray.append(result)
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
    
    
    func findMutualFriends(phoneNumber: String) -> [ContactData] {
        let result = String(phoneNumber.stringValue().characters.filter { String($0).rangeOfCharacterFromSet(NSCharacterSet(charactersInString: "0123456789.")) != nil }) //partnr's phone number
        let myNumber = String(SharedDataManager.sharedInstance.userData.phoneNumber.stringValue().characters.filter { String($0).rangeOfCharacterFromSet(NSCharacterSet(charactersInString: "0123456789.")) != nil }) // user's phone number
        var friends = [ContactData]()
        for contact in self.contacts {
            if contact.phoneArray.contains(result) && contact.phoneArray.contains(myNumber) {
                friends.append(contact)
            }
        }
        return friends
    }
    
    func makeMutualFriendsList(resultDic: JSON) -> [ContactData] {
        var friends = [ContactData]()
        let friendsData = resultDic["data"]
        
        for friendData in friendsData.array! {
            let friend = ContactData()
            friend.name = friendData["name"].stringValue
            friend.avatarImage = UIImage(data: NSData(contentsOfURL:NSURL(string: friendData["picture"]["data"]["url"].stringValue)!)!)
            
            friends.append(friend)
        }
        return friends
    }
    
    func getFBMutualFriends()
    {
        SVProgressHUD.dismiss()

        if FBSDKAccessToken.currentAccessToken() == nil{
            PNAPIClient.sharedInstance.linkToFacebook { (nsData, error) -> Void in
                if nsData != nil{
                    print("success: \(nsData)")
                    
                    PNAPIClient.sharedInstance.searchUsers(self.profession) { (userArray, error) -> Void in
                        if error == nil {
                            self.userArray = userArray
                            
                            for userData in self.userArray {
                                if userData.facebookID.isEmpty == false {
                                    //                        userData.mutualFriends = self.findMutualFriends(userData.phoneNumber)
                                    self.getFBMutualFriendsForUser(userData)
                                }
                            }
                        }
                    }
                }
                else{
                    print("Error: \(error)")
                }
            }
        }
        else{
            PNAPIClient.sharedInstance.searchUsers(self.profession) { (userArray, error) -> Void in
                if error == nil {
                    self.userArray = userArray
                    
                    for userData in self.userArray {
                        if userData.facebookID.isEmpty == false {
                            //                        userData.mutualFriends = self.findMutualFriends(userData.phoneNumber)
                            self.getFBMutualFriendsForUser(userData)
                        }
                    }
                }
            }
        }
    }
    
    func getFBMutualFriendsForUser(data: UserData){
        if (FBSDKAccessToken.currentAccessToken() != nil)
        {
            print("AccessToken: \(FBSDKAccessToken.currentAccessToken().tokenString)")
            var params: Dictionary<String, AnyObject> = Dictionary()
            params = ["fields": "context.fields(all_mutual_friends.limit(100))"]
            let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: data.facebookID, parameters: params, HTTPMethod:"GET")
            graphRequest.startWithCompletionHandler { (connection: FBSDKGraphRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
                if error != nil
                {
                    print("Error: \(error)")
                }
                else
                {
                    print("Context: \(result)")
                    
                    var params: Dictionary<String, AnyObject> = Dictionary()
                    params = ["fields": "name,picture.height(100)"]
                    
                    print("\(result["context"]["id"])")
                    
                    SVProgressHUD.show()
                    let graphRequest: FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "\(result["context"]["id"])/all_mutual_friends", parameters: params, HTTPMethod: "GET")
                    graphRequest.startWithCompletionHandler({ (connection: FBSDKGraphRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
                        if error != nil{
                            print("Error: \(error)")
                        }
                        else{
                            print("Mutual: \(result)")
                            let jsonString = JSON(result)
                            
                            data.mutualFriends = self.makeMutualFriendsList(jsonString)
                            self.partnrTable.reloadData()
                            SVProgressHUD.dismiss()
                        }
                    })
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.navigationController!.navigationBar.tintColor = .whiteColor()
        self.navigationController!.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName : UIColor.whiteColor()
        ]
        
        self.title = "\(profession)s".uppercaseString
        
        descLabel.text = "\(self.profession)s within your network"
        
        SVProgressHUD.show()
        self.getFBMutualFriends()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableViewDataSource
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return indexPath.row == 0 ? 240.0 : 51.0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let userData = self.userArray[section]
        return userData.mutualFriends.count + 1
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.userArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = indexPath.row == 0 ? "PartnrCell" : "FriendCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath)
        
        let userData = self.userArray[indexPath.section]
        if identifier == "PartnrCell" {
            let partnrCell = cell as! PartnrTableCell
            partnrCell.backImage.file = userData.avatarImg
            partnrCell.backImage.loadInBackground({ (image, error) -> Void in
                partnrCell.avatarImage.image = image
                //                partnrCell.avatarButton.setImage(image, forState: .Normal)
            })
            partnrCell.nameLabel.text = userData.name
            partnrCell.sharedFriendsLabel.text = "\(userData.mutualFriends.count)"
            partnrCell.professionLabel.text = userData.profession
            partnrCell.locationLabel.text = userData.locationName
            partnrCell.availableButton.setTitle(userData.isAvailable ? "AVAILABLE" : "UNAVAILABLE", forState: .Normal)
            
            partnrCell.availableButton.backgroundColor = userData.isAvailable ? UIColor.init(red: 51/255.0, green: 181/255.0, blue: 67/255.0, alpha: 1.0) : UIColor.init(red: 108/255.0, green: 12/255.0, blue: 17/255.0, alpha: 1.0)
            
            partnrCell.selectPartnrButton.tag = 9999*indexPath.section + indexPath.row
            partnrCell.selectPartnrButton.addTarget(self, action: Selector("onClickSelectPartnr:"), forControlEvents: .TouchUpInside)
            
            partnrCell.avatarButton.tag = indexPath.section
            partnrCell.avatarButton.addTarget(self, action: Selector("onClickAvatarButton:"), forControlEvents: .TouchUpInside)
            
            if userData.rate == -1 {
                PNAPIClient.sharedInstance.getLatestRateFromUserId(userData.id, callback: { (rate, error) -> Void in
                    userData.rate = rate
                    partnrCell.rateButton.setTitle(NSString(format: "%.01f", rate) as String, forState: .Normal)
                })
            } else {
                partnrCell.rateButton.setTitle(NSString(format: "%.01f", userData.rate) as String, forState: .Normal)
            }
        } else if identifier == "FriendCell" {
            let friendData = userData.mutualFriends[indexPath.row - 1]
            let friendCell = cell as! FriendTableCell
            if let image = friendData.avatarImage {
                friendCell.avatarImage.image = image
            } else {
                friendCell.avatarImage.image = UIImage.init(named: "avatar-empty")
            }
            friendCell.nameLabel.text = friendData.name
            
            friendCell.actionButton.selected = friendData.isInvited
            friendCell.actionButton.tag = 9999*indexPath.section + indexPath.row
            friendCell.actionButton.addTarget(self, action: Selector("onClickAsk:"), forControlEvents: .TouchUpInside)
        }
        
        return cell
    }
    
    func onClickAsk(sender: UIButton) {
        
        let section = sender.tag / 9999
        let row = sender.tag % 9999
        
        selIndex = sender.tag
        
        if MFMessageComposeViewController.canSendText() == false {
            Utilities.showMsg("Your device doesn't support SMS!", delegate: self)
            return
        }
        
        let userData = self.userArray[section]
        let friendData = userData.mutualFriends[row - 1]
        let recipients = friendData.phoneArray
        let message = "I found \(userData.name) to work with, do you vouch for us to work together?"
        
        let messageController = MFMessageComposeViewController.init()
        messageController.messageComposeDelegate = self
        messageController.recipients = recipients
        messageController.body = message
        
        self.presentViewController(messageController, animated: true) { () -> Void in
            
        }
    }
    
    func onClickSelectPartnr(sender: UIButton) {
        let section = sender.tag / 9999
        let userData = self.userArray[section]
        
        let postProjectVC = self.storyboard?.instantiateViewControllerWithIdentifier("SendBriefVC") as! SendBriefViewController
        postProjectVC.briefUserData = userData
        self.navigationController?.pushViewController(postProjectVC, animated: true)
    }
    
    func onClickAvatarButton (sender: UIButton) {
        
        let userData = userArray[sender.tag]
        let userId = userData.id
        
        SVProgressHUD.show()
        PNAPIClient.sharedInstance.fetchUser(PFUser.init(withoutDataWithClassName: "_User", objectId: userId), callback: { (userData, error) -> Void in
            SVProgressHUD.dismiss()
            if error == nil && userData != nil {
                let profileVC = self.storyboard?.instantiateViewControllerWithIdentifier("ProfileVC") as! ProfileViewController
                profileVC.userData = userData
                self.navigationController?.pushViewController(profileVC, animated: true)
            }
        })
    }
    
    // MARk: - MFMessageComposeViewControllerDelegate
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        
        switch result {
        case MessageComposeResultCancelled:
            
            break
        case MessageComposeResultFailed:
            Utilities.showMsg("Failed!", delegate: self)
            break
        case MessageComposeResultSent:
            let section = selIndex / 9999
            let row = selIndex % 9999
            let userData = self.userArray[section]
            let friendData = userData.mutualFriends[row - 1]
            friendData.isInvited = true
            
            self.partnrTable.reloadData()
            break
        default:
            break
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

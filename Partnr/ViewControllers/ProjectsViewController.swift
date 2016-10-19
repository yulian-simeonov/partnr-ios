//
//  ProjectsViewController.swift
//  Partnr
//
//  Created by Yulian Simeonov on 2/18/16.
//  Copyright © 2016 YulianMobile. All rights reserved.
//

import UIKit
import ParseUI
import Contacts
import MessageUI
import FBSDKCoreKit


class ProjectsViewController: CustomBaseViewController, UITableViewDataSource, UITableViewDelegate, NIDropDownDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate{
    
    var curSegment: EProjectTab = .AllProjects // All projects Tab
    
    @IBOutlet weak var seg1CenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var seg2CenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var segmentBarCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var segmentView: UIView!
    @IBOutlet weak var projectTable: UITableView!
    
//    @IBOutlet weak var searchTextField: NSCustomTextField!
    @IBOutlet weak var allprojectButton: UIButton!
    @IBOutlet weak var myprojectButton: UIButton!
    @IBOutlet weak var professionDropDown: UIButton!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var emptyImageView: UIImageView!
    @IBOutlet weak var sendInviteButton: UIButton!


    // Project Status
    enum EProjectTab: Int {
        case AllProjects = 1
        case MyProjects = 2
    }
    
    var projectArray = []
    var userArray = [UserData]()
    
    var isSearched = false
    var selIndex = 0
    
    var selIndexPath = NSIndexPath(forRow: 0, inSection: 0)
    var requestPartnrName = ""
    var isKeyboardShown = false
    var profession = ""
    
    var labelDropDown: NIDropDown!
    var profDropDown: NIDropDown!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Segment Bar removed upon UI requirements
/*        self.moveSegmentBar() */
        
        
        curSegment = .MyProjects
        
        if SharedDataManager.sharedInstance.isFirstToProjectFeed {
//            ModalDialogViewController.showDialogWithType(EDialogType.ChooseProjectType, delegate: self) { (nsData, error) -> Void in
//                
//                SharedDataManager.sharedInstance.isFirstToProjectFeed = false
//                
//                SharedDataManager.sharedInstance.projectTypes = nsData!["Types"] as! [NSInteger]
//                
                self.feedProjects()
//                self.checkRequest()
//            }
            
            self.performSelector(Selector("showFindPartnrDialog"), withObject: nil, afterDelay: 2)
        }
        else{
            self.feedProjects()
        }
        

        NSNotificationCenter.defaultCenter().addObserverForName(kNotiRefreshProjectsFeed, object: nil, queue: nil) { (noti) -> Void in
            self.feedProjects()
        }
        NSNotificationCenter.defaultCenter().addObserverForName(kNotiSearchUser, object: nil, queue: nil) { (noti) -> Void in
            self.receivedNotification()
        }
        
        self.projectTable.registerNib(UINib.init(nibName: "PartnrCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "PartnrCell")
        self.projectTable.registerNib(UINib.init(nibName: "FriendCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "FriendCell")
    }
    
    func showFindPartnrDialog() {
        ModalDialogViewController.showDialogWithType(EDialogType.FindPartnr, delegate: self) { (nsData, error) -> Void in
            
            SharedDataManager.sharedInstance.isFirstToProjectFeed = false
            
            let response = nsData!["response"].intValue
            if response == 1 { // Search partnr
                let profession = nsData!["profession"].stringValue
                let searchPartnrVC = self.storyboard?.instantiateViewControllerWithIdentifier("SelectPartnrVC") as! SelectPartnrViewController
                searchPartnrVC.profession = profession
                self.navigationController?.pushViewController(searchPartnrVC, animated: true)
            } else if response == 2 { // Create new project
                let postProjectVC = self.storyboard?.instantiateViewControllerWithIdentifier("PostProjectVC") as! PostProjectViewController
                self.navigationController?.pushViewController(postProjectVC, animated: true)
            } else if response == 3 { // View the community
                SharedDataManager.sharedInstance.rootVC.showCommunityView()
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
//        searchTextField.resignFirstResponder()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if !SharedDataManager.sharedInstance.isFirstToProjectFeed {
            self.performSelector(Selector("checkRequest"), withObject: nil, afterDelay: 1)
        }
    }
    
    // Check if any hire Request for my Applicants
    func checkRequest() {
        PNAPIClient.sharedInstance.getHireRequests { (applicants, error) -> Void in
            if applicants.count > 0 {
                let applicantData = applicants[0]
                PNAPIClient.sharedInstance.fetchProject(applicantData.projectId, callback: { (projectData, error) -> Void in
                    if projectData != nil {
                        ModalDialogViewController.showCongratulationPopUp(projectData!, delegate: self, callback: { (nsData, error) -> Void in
                            
                            self.requestPartnrName = nsData!["PartnrName"] as! String
                            
                            ProjectAcceptModalView.showPopup(projectData!, applicantData: applicantData, delegate: self, callback: { (isAccept, error) -> Void in
                                
                                if isAccept! == true {
                                    ModalDialogViewController.showConfirmPopUp(self.requestPartnrName, delegate: self, callback: { (nsData, error) -> Void in
                                        
                                        let isYes = nsData!["IsYes"] as! Bool
                                        
                                        if isYes {
                                            PNAPIClient.sharedInstance.acceptRequestAndHired(applicantData.id, projectId: (projectData?.id)!, callback: { (finished, error) -> Void in
                                                
                                                if finished {
                                                    Utilities.showMsg("Successfully done!", delegate: self)
                                                } else {
                                                    Utilities.showMsg("Failed!", delegate: self)
                                                }
                                            })
                                        }
                                    })
                                } else {
                                    
                                }
                            })
                        })
                    }
                })
            } else { // Check funding request
                
                PNAPIClient.sharedInstance.getFundingRequests({ (projects, error) -> Void in
                    if projects.count > 0 {
                        for projectData in projects {
                            if projectData.isPendingExpired() {
                                projectData.setStatusToOpen()
                            } else {
                                FundingRequestModalView.showDialogWithDelegate(self, projectData: projects[0], callback: { (isPaid, error) -> Void in
                                    
                                    if isPaid {
                                        Utilities.showMsg("Congratulation! Your project has been started.", delegate: self)
                                        PNAPIClient.sharedInstance.sharePaymentToNews(projectData.name, callback: { (finished, error) -> Void in
                                        })
                                        NSNotificationCenter.defaultCenter().postNotificationName(kNotiRefreshProjectsFeed, object: nil)
                                    }
                                })
                            }
                        }
                    }
                })
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
    
    // MARK: - API Call
    func feedProjects() {
        SVProgressHUD.show()
        if curSegment == .AllProjects {
            PNAPIClient.sharedInstance.feedOpenProject(SharedDataManager.sharedInstance.projectTypes) { (projects, error) -> Void in
                SVProgressHUD.dismiss()
                if error == nil {
                    self.projectArray = projects!
                    self.projectTable.reloadData()
                }
            }
        } else {
            print("FirstLaunchParameter: \(SharedDataManager.sharedInstance.projectTypes)")
            print("Access Token:\(SharedDataManager.sharedInstance.accessToken)")
            PNAPIClient.sharedInstance.feedMyProject(SharedDataManager.sharedInstance.projectTypes) { (projects, error) -> Void in
                SVProgressHUD.dismiss()
                if error == nil {
                    self.projectArray = projects
                    if self.projectArray.count == 0 {
                        self.projectTable.hidden = true
                        self.emptyView.hidden = false
                        self.emptyImageView.hidden = false
                        self.sendInviteButton.hidden = false
                        self.sendInviteButton.enabled = true
                    }
                    self.projectTable.reloadData()
                }
                else{
                    self.projectTable.hidden = true
                    self.emptyView.hidden = false
                    self.emptyImageView.hidden = false
                    self.sendInviteButton.hidden = false
                    self.sendInviteButton.enabled = true
                }
            }
        }
    }
    
    func searchUsers() {
        SVProgressHUD.show()
        self.profession = (self.professionDropDown.titleLabel?.text)!
        self.getFBMutualFriends()
    }
    
    func findMutualFriends(phoneNumber: String) -> [ContactData] {
        let result = String(phoneNumber.stringValue().characters.filter { String($0).rangeOfCharacterFromSet(NSCharacterSet(charactersInString: "0123456789.")) != nil })
        let myNumber = String(SharedDataManager.sharedInstance.userData.phoneNumber.stringValue().characters.filter { String($0).rangeOfCharacterFromSet(NSCharacterSet(charactersInString: "0123456789.")) != nil })
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
                            self.projectTable.reloadData()
                            SVProgressHUD.dismiss()
                        }
                    })
                }
            }
        }
    }

    
    // MARK: - UI Functions
    func moveSegmentBar() {
        
        segmentBarCenterConstraint.constant = curSegment == .AllProjects ? seg1CenterConstraint.constant : seg2CenterConstraint.constant
        UIView.animateWithDuration(0.5) { () -> Void in
            self.segmentView.layoutIfNeeded()
        }
    }
    
    @IBAction func onClickSegment(sender: AnyObject) {
        
        curSegment = EProjectTab.init(rawValue: sender.tag)!
        self.moveSegmentBar()
        
        if curSegment == .AllProjects {
            allprojectButton.selected = true
            myprojectButton.selected = false
        } else {
            allprojectButton.selected = false
            myprojectButton.selected = true
        }
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.projectTable.transform = CGAffineTransformMakeTranslation(-1*SCRN_WIDTH, 0)
            }) { (finished) -> Void in
                self.projectTable.transform = CGAffineTransformMakeTranslation(SCRN_WIDTH, 0)
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.projectTable.transform = CGAffineTransformMakeTranslation(0, 0)
                    self.projectTable.reloadData()
                    
                    }) { (finished) -> Void in
                        
                }
        }
        self.feedProjects()
    }
    
    // MARK: - NIDropDownDelegate
    func niDropDownDelegateMethod(sender: NIDropDown!, atIndex index: Int) {
        
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
    
    @IBAction func onClickSendInvites(sender: AnyObject) {
        
        if !MFMailComposeViewController.canSendMail() {
            print("Mail services are not available")
            return
        }
        
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        
        // Configure the fields of the interface.
        composeVC.setSubject("Join me on Partnr!")
        composeVC.setMessageBody("Join me on Partnr to gain exposure to other creators and brands.", isHTML: false)
        
        // Present the view controller modally.
        self.presentViewController(composeVC, animated: true, completion: nil)
    }
    
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
    
    @IBAction func onClickFindPartnr(sender: AnyObject) {
        ModalDialogViewController.showDialogWithType(EDialogType.FindPartnr, delegate: self) { (nsData, error) -> Void in
            
            SharedDataManager.sharedInstance.isFirstToProjectFeed = false
            
            let response = nsData!["response"].intValue
            if response == 1 { // Search partnr
                let profession = nsData!["profession"].stringValue
                let searchPartnrVC = self.storyboard?.instantiateViewControllerWithIdentifier("SelectPartnrVC") as! SelectPartnrViewController
                searchPartnrVC.profession = profession
                self.navigationController?.pushViewController(searchPartnrVC, animated: true)
            } else if response == 2 { // Create new project
                let postProjectVC = self.storyboard?.instantiateViewControllerWithIdentifier("PostProjectVC") as! PostProjectViewController
                self.navigationController?.pushViewController(postProjectVC, animated: true)
            } else if response == 3 { // View the community
                SharedDataManager.sharedInstance.rootVC.showCommunityView()
            }
        }
    }
    
    
    
    // MARK - UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if self.isSearched == true{
            return self.userArray.count
        }
        else{
            return 1
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isSearched == true{
            let userData = self.userArray[section]
            return userData.mutualFriends.count + 1
        }
        else{
            return self.projectArray.count
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if self.isSearched == true{
            return indexPath.row == 0 ? 240.0 : 51.0
        }
        else{
            return 95.0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.isSearched == true{
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
        else{
            let cell = tableView.dequeueReusableCellWithIdentifier(curSegment == .AllProjects ? "AllProjectCell" : "MyProjectCell", forIndexPath: indexPath) as! ProjectTableCell
            
            let projectData = projectArray[indexPath.row] as! ProjectData
            
            cell.processContent(projectData)
            
            if projectData.userData == nil {
                projectData.updateUserData({ (userData, error) -> Void in
                    if error == nil {
                        cell.creatorLabel.text = "Posted by \(userData!.name)"
                    }
                })
            } else {
                cell.creatorLabel.text = "Posted by \(projectData.userData!.name)"
            }
            
            return cell
        }
    }
    
    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if self.isSearched == true{
            
        }
        else{
            tableView .deselectRowAtIndexPath(indexPath, animated: true)
            selIndexPath = indexPath
            self.performSegueWithIdentifier("ShowProjectDetailVC", sender: self)
        }
    }
    
//    // MARK: - UITextFieldDelegate
//    func textFieldDidBeginEditing(textField: UITextField) {
//        textField.resignFirstResponder()
//
//    }
//    
//    func textFieldShouldReturn(textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//        isKeyboardShown = false
//        return true
//    }
//    
//    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        searchTextField.resignFirstResponder()
//    }
    
    // MARK: -KVO
    func receivedNotification(){
        if self.projectArray.count == 0 {
            self.projectTable.hidden = false
            self.emptyView.hidden = true
            self.emptyImageView.hidden = true
            self.sendInviteButton.hidden = true
            self.sendInviteButton.enabled = false
        }
        
        self.isSearched = true
        self.searchUsers()
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if isKeyboardShown {
//            searchTextField.resignFirstResponder()
        }
    }
    
    // MARK: - ProjectDetailViewControllerDelegate
    func projectStatusDidChange(status: EProjectStatus) {
        curSegment = .MyProjects
        self.feedProjects()
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
            
            self.projectTable.reloadData()
            break
        default:
            break
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController,
        didFinishWithResult result: MFMailComposeResult, error: NSError?) {
            // Check the result or perform other tasks.
            
            // Dismiss the mail compose view controller.
            controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "ShowProjectDetailVC") {
            if (curSegment == .MyProjects) { // My Project Tab
                let destVC = segue.destinationViewController as! ProjectDetailViewController
                destVC.projectData = projectArray[selIndexPath.row] as? ProjectData
//                destVC.isAdmin = true
            } else if curSegment == .AllProjects { // All Project Tab
                let destVC = segue.destinationViewController as! ProjectDetailViewController
                destVC.projectData = projectArray[selIndexPath.row] as? ProjectData
            }
        }
    }
}

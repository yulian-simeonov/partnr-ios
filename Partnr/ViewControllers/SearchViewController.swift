//
//  UserListViewController.swift
//  Partnr
//
//  Created by Yosemite on 2/16/16.
//  Copyright © 2016 YulianMobile. All rights reserved.
//

import UIKit

import ParseUI


class SearchViewController: CustomBaseViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    private let userCellIdentifier = "UserCell"
    private let projectCellIdentifier = "ProjectCell"
    private let emptyCellIdentifier = "EmptyFeedCell"

    
    @IBOutlet weak var searchTable: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchBtnWidConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchButton: UIButton!
    
    var searchArray = NSArray()
    var isSearched = false
    var selIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        searchTable.registerNib(UINib.init(nibName: "FeedEmptyTableCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: emptyCellIdentifier)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Call API
    func doSearch(searchKey: String) {
        if Utilities.isValidData(searchKey) == false {
            Utilities.showMsg("Please input search field!", delegate: self)
            return
        }
        SVProgressHUD.show()
        PNAPIClient.sharedInstance.doSearch(searchKey) { (searchResult, error) -> Void in
            SVProgressHUD.dismiss()
            self.searchArray = searchResult!
            self.searchTable.reloadData()
        }
    }
    
    // MARK: - UIButton Action
    @IBAction func onClickSearch(sender: AnyObject) {
        isSearched = true
        searchTextField.resignFirstResponder()
        
        self.doSearch(searchTextField.text!)
    }
    
    // MARK: - UITableViewDataSource
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if searchArray.count == 0 {
            return 392.0
        } else {
            return 81.0
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchArray.count == 0 {
            return 1
        }
        return searchArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if searchArray.count == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(emptyCellIdentifier, forIndexPath: indexPath) as! FeedEmptyTableCell
            cell.putEmptyImage(UIImage.init(named: isSearched ? "img-emptySearch" : "img-desc-search")!)
            return cell
        } else {
            let searchItem = searchArray[indexPath.row]
            if searchItem.isKindOfClass(UserData) {
                let cell = tableView.dequeueReusableCellWithIdentifier(userCellIdentifier, forIndexPath: indexPath) as! UserTableCell
                cell.proceedContent(searchItem as! UserData)
                return cell
            } else if searchItem.isKindOfClass(ProjectData) {
                let cell = tableView.dequeueReusableCellWithIdentifier(projectCellIdentifier, forIndexPath: indexPath) as! ProjectTableCell
                return cell
            }
        }
        return UITableViewCell.init()
    }
    
    // MAR: - UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        selIndex = indexPath.row
        let selData = searchArray[selIndex]
        
        if selData.isKindOfClass(UserData) {
            self.performSegueWithIdentifier("ShowUserDetailVC", sender: self)
        } else if selData.isKindOfClass(ProjectData) {
            self.performSegueWithIdentifier("ShowProjectDetailVC", sender: self)
        }
    }
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.searchBtnWidConstraint.constant = 66.0

        UIView.animateWithDuration(0.3) { () -> Void in
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "ShowUserDetailVC" {
            let selData = searchArray[selIndex]
            let destVC = segue.destinationViewController as! ProfileViewController
            destVC.userData = selData as? UserData
        } else if segue.identifier == "ShowProjectDetailVC" {
            let selData = searchArray[selIndex]
            let destVC = segue.destinationViewController as! ProjectDetailViewController

        }
    }

}

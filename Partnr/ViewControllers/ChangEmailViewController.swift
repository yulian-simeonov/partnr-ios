//
//  SettingsViewController.swift
//  Partnr
//
//  Created by Yosemite on 2/25/16.
//  Copyright © 2016 YulianMobile. All rights reserved.
//

import UIKit

import ParseUI

class ChangEmailViewController: CustomBaseViewController, UITableViewDataSource, UITableViewDelegate {

    let cellIdentifiers = ["DescCell", "NewCell", "SubmitCell"]
    
    var emailTextField: UITextField!
    
    @IBOutlet weak var emailTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        emailTable.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableViewDataSource
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return indexPath.row == 0 ? 35.0 : 45.0
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellIdentifiers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifiers[indexPath.row], forIndexPath: indexPath)
        
        if cellIdentifiers[indexPath.row] == "NewCell" {
            emailTextField = cell.viewWithTag(1) as! UITextField
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.row == 2 { // Change Email
            if Utilities.isValidEmail(emailTextField.text!) == false {
                Utilities.showMsg("Please input valid email address!", delegate: self)
                return
            }
            
            PFUser.currentUser()?.email = emailTextField.text
            PFUser.currentUser()?.saveInBackgroundWithBlock({ (finished, error) -> Void in
                if finished {
                    self.navigationController?.popViewControllerAnimated(true)
                } else {
                    Utilities.showMsg("Failed, Please try again!", delegate: self)
                }
            })
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

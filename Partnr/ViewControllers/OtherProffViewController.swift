//
//  OtherProffViewController.swift
//  Partnr
//
//  Created by Yosemite on 1/26/16.
//  Copyright © 2016 YulianMobile. All rights reserved.
//

import UIKit

protocol OtherProffViewControllerDelegate {
    
    func professionDidSelect(professionStr: String)
}

class OtherProffViewController: UIViewController {

    var delegate: OtherProffViewControllerDelegate? = nil
    
    @IBOutlet weak var textField: NSCustomTextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClickNext(sender: AnyObject) {
        
        if textField.text!.isEmpty {
            Utilities.showMsg("Input profession!", delegate: self)
            return
        }
        
        self.navigationController?.popViewControllerAnimated(true)
        if self.delegate != nil {
            self.delegate?.professionDidSelect(textField.text!)
        }
    }

    @IBAction func onClickBack(sender: AnyObject) {
        
        self.navigationController?.popViewControllerAnimated(true)
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

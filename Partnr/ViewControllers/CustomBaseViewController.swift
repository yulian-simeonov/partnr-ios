//
//  CustomBaseViewController.swift
//  Partnr
//
//  Created by Yosemite on 1/30/16.
//  Copyright © 2016 YulianMobile. All rights reserved.
//

import UIKit

class CustomBaseViewController: UIViewController {

    @IBInspectable var leftButtonType: NSInteger = 0 {
        didSet {
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let titleImage = UIImageView.init(image: UIImage.init(named: "img-partnr-logo"))
        titleImage.frame = CGRectMake(0, 0, 71, 21)
        if self.isKindOfClass(ProfileViewController) || self.isKindOfClass(ProjectsViewController) {
            titleImage.image = UIImage.init(named: "img-logo-white")
            titleImage.frame = CGRectMake(0, 0, 21.6, 21)
        }
        self.navigationItem.titleView = titleImage
        
        if leftButtonType == 2 { // Two buttons (Back, Burger)
            let backButton = UIBarButtonItem.init(image: UIImage.init(named: "btn-navi-back1"), style: .Plain, target: self, action: Selector("onClickBack:"))
            let menuButton = UIBarButtonItem.init(image: UIImage.init(named: "btn-burger"), style: .Plain, target: self, action: Selector("onClickBurger:"))
            self.navigationItem.setLeftBarButtonItems([backButton, menuButton], animated: true)
        } else if leftButtonType == 1 { // Back button
            let backButton = UIBarButtonItem.init(image: UIImage.init(named: "btn-navi-back1"), style: .Plain, target: self, action: Selector("onClickBack:"))
            self.navigationItem.setLeftBarButtonItems([backButton], animated: true)
        }
    }

    // MARK: - UIButtonAction
    func onClickBack(button: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func onClickBurger(button: UIButton) {
        NSNotificationCenter.defaultCenter().postNotificationName(kNotiRefreshSideMenu, object: nil)
        
        self.sidePanelController?.showLeftPanelAnimated(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

//
//  OnboardingViewController.swift
//  Partnr
//
//  Created by Yulian Simeonov on 1/23/16.
//  Copyright © 2016 YulianMobile. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController, iCarouselDataSource, iCarouselDelegate {
    
    let onboardingImages = [
        "img-onboarding-1",
        "img-onboarding-2",
        "img-onboarding-3",
        "img-onboarding-4",
        "img-onboarding-5",
        "btn-imready"
    ]
    
    @IBOutlet weak var carousel: iCarousel!
    @IBOutlet weak var downarrowButton: UIButton!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        carousel.vertical = false
        carousel.type = .Linear
        carousel.scrollSpeed = 1.1
        carousel.decelerationRate = 0.1
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UIButtonAction
    @IBAction func onClickDown(sender: AnyObject) {
        
        if carousel.currentItemIndex+1 == onboardingImages.count-1 {
            downarrowButton.hidden = true
        }
        carousel.scrollToItemAtIndex(carousel.currentItemIndex+1, animated: true)
        self.performSelector(Selector("reloadCarousel"), withObject: nil, afterDelay: 0.3)
    }
    
    func onClickImReady(sender: UIButton) {
        self .dismissViewControllerAnimated(true) { () -> Void in
            SharedDataManager.sharedInstance.rootVC.performSegueWithIdentifier(kShowWelcome, sender: nil)
        }
    }
    
    func reloadCarousel() {
        
        carousel.reloadData()
    }
    
    //MARK: - iCarouselDataSource
    func numberOfItemsInCarousel(carousel: iCarousel) -> Int
    {
        return onboardingImages.count
    }
    
    func carousel(carousel: iCarousel, viewForItemAtIndex index: Int, reusingView view: UIView?) -> UIView
    {
        var itemView: UIView
        var imageView: UIImageView? = nil
        //        if (view == nil)
        //        {
        itemView = UIView(frame: CGRect(x:0, y:0, width: SCRN_WIDTH, height: SCRN_HEIGHT))
        
        if index == onboardingImages.count - 1 {
            let readyButton = UIButton.init(frame: CGRect(x: 0, y: 0, width: 176, height: 45))
            readyButton.center = itemView.center
            readyButton.setImage(UIImage.init(named: onboardingImages[index]) , forState: .Normal)
            readyButton.tag = 1
            readyButton.addTarget(self, action: Selector("onClickImReady:"), forControlEvents: .TouchUpInside)
            
            itemView.addSubview(readyButton)
        } else {
            imageView = UIImageView(frame:CGRect(x:0, y:0, width:SCRN_WIDTH, height:SCRN_WIDTH))
            imageView!.tag = 1
            imageView!.center = itemView.center
            imageView!.contentMode = .ScaleAspectFill
            
            itemView.addSubview(imageView!)
        }
        //        }
        //        else
        //        {
        //            itemView = view!
        //            if index != onboardingImages.count - 1 {
        //                imageView = itemView.viewWithTag(1) as? UIImageView
        //            }
        //        }
        
        if imageView != nil {
            imageView!.image = UIImage(named: "\(onboardingImages[index])")
        }
        
        if index == carousel.currentItemIndex {
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                itemView.alpha = 1.0
            })
        } else {
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                itemView.alpha = 0.3
            })
        }
        
        return itemView
    }
    
    func carouselCurrentItemIndexDidChange(carousel: iCarousel) {
        
        carousel.reloadData()
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
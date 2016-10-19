//
//  FundingRequestModalView.swift
//  Partnr
//
//  Created by Yulian Simeonov on 3/17/16.
//  Copyright © 2016 YulianMobile. All rights reserved.
//

import UIKit
import Braintree
import ParseUI

class FundingRequestModalView: UIViewController, BTDropInViewControllerDelegate {
    
    var respondBlock: ((isPaid: Bool, error: NSError?) -> (Void))?

    @IBOutlet weak var avatarImage: PFImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var projectPriceLabel: UILabel!
    @IBOutlet weak var feeLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    
    @IBOutlet weak var payNowView: UIView!
    @IBOutlet weak var payLaterView: UIView!
    var fundAmount = 0.0
    
    var projectData: ProjectData?
    
    class func showDialogWithDelegate(delegate: AnyObject, projectData: ProjectData, callback:((isPaid: Bool, error: NSError?) -> Void)) -> FundingRequestModalView {
        
        let modalDialog = FundingRequestModalView.init(nibName: "FundingRequestModalView", bundle: NSBundle.mainBundle())
        modalDialog.providesPresentationContextTransitionStyle = true
        modalDialog.definesPresentationContext = true
        modalDialog.modalPresentationStyle = UIModalPresentationStyle.Custom
        modalDialog.modalTransitionStyle = .CrossDissolve
        modalDialog.respondBlock = callback
        modalDialog.projectData = projectData
        
        delegate.presentViewController(modalDialog, animated: true, completion: nil)
        
//        modalDialog.performSelector(Selector("updateContent"), withObject: nil, afterDelay: 0.5)
        
        return modalDialog
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        if self.projectData != nil {
            self.updateContent()
        }
    }
    
    func updateContent() {
        self.avatarImage.layer.cornerRadius = 5
        self.projectData?.updatePartnrData({ (userData, error) -> Void in
            self.avatarImage.file = userData?.avatarImg
            self.avatarImage.loadInBackground()
            
            self.usernameLabel.text = userData?.userName
        })
        
        projectPriceLabel.text = NSString.init(format: "$%.02f", (self.projectData?.price)!) as String
        
        let fee = (projectData?.price)! / 10
        feeLabel.text = NSString.init(format: "$%.02f", fee) as String
        
        fundAmount = (self.projectData?.price)! + fee
        totalPriceLabel.text = NSString.init(format: "$%.02f", fundAmount) as String
    }

    @IBAction func onClickPayNow(sender: AnyObject) {
        
//        self.verifyVenmoWhitelist()
//        return
        
        if PNPaymentHelper.sharedInstance.braintreeClient == nil {
            SVProgressHUD.show()
            PNPaymentHelper.sharedInstance.getToken({ (token, isSucceed, error) -> Void in
                SVProgressHUD.dismiss()
                if isSucceed {
                    self.processPayment()
                } else {
                    Utilities.showMsg("Braintree server is unavailable", delegate: self)
                }
            })
        } else {
            self.processPayment()
        }
    }
    
    @IBAction func onClickPayLater(sender: AnyObject) {
        payNowView.hidden = true
        payLaterView.hidden = false
        
        Utilities.sendPayLaterNotification(self.projectData!)
    }
    
    @IBAction func onClickContinue(sender: AnyObject) {
        self.dismissViewControllerAnimated(true) { () -> Void in
            if self.respondBlock != nil {
                self.respondBlock!(isPaid: false, error: nil)
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Braintree
    func verifyVenmoWhitelist() {
        PNPaymentHelper.sharedInstance.verifyVenmoWhitelist("", phone: "") { (error, isSucceed) -> Void in
            if isSucceed == false {
                BTConfiguration.enableVenmo(true)
                
                if PNPaymentHelper.sharedInstance.braintreeClient == nil {
                    SVProgressHUD.show()
                    PNPaymentHelper.sharedInstance.getToken({ (token, isSucceed, error) -> Void in
                        SVProgressHUD.dismiss()
                        if isSucceed {
                            
                            let dropInViewController = BTDropInViewController(APIClient: PNPaymentHelper.sharedInstance.braintreeClient!)

                            dropInViewController.delegate = self
                            
                            let navigationController = UINavigationController(rootViewController: dropInViewController)
                            navigationController.view.tag = 100
                            self.presentViewController(navigationController, animated: true, completion: nil)
                            
                        } else {
                            Utilities.showMsg("Braintree server is unavailable", delegate: self)
                        }
                    })
                } else {
                    let dropInViewController = BTDropInViewController(APIClient: PNPaymentHelper.sharedInstance.braintreeClient!)
                    dropInViewController.delegate = self
                    
                    let navigationController = UINavigationController(rootViewController: dropInViewController)
                    self.presentViewController(navigationController, animated: true, completion: nil)
                }
            }
        }
    }
    
    func processPayment() {
        let amount = self.fundAmount
        
        // If you haven't already, create and retain a `BTAPIClient` instance with a
        // tokenization key OR a client token from your server.
        // Typically, you only need to do this once per session.
        // braintreeClient = BTAPIClient(authorization: aClientToken)
        
        BTConfiguration.enableVenmo(true)
        
        // Create a BTDropInViewController
        let dropInViewController = BTDropInViewController(APIClient: PNPaymentHelper.sharedInstance.braintreeClient!)
        dropInViewController.delegate = self
        
        let paymentRequest = BTPaymentRequest()
        paymentRequest.displayAmount = "$\(amount)"
        paymentRequest.amount =  "\(amount)"
        paymentRequest.summaryTitle = "Deposit 20% of project price"
        paymentRequest.summaryDescription = "Will be released when project completed"
        dropInViewController.paymentRequest = paymentRequest
        
        // This is where you might want to customize your view controller (see below)
        
        // The way you present your BTDropInViewController instance is up to you.
        // In this example, we wrap it in a new, modally-presented navigation controller:
        dropInViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonSystemItem.Cancel,
            target: self, action: "userDidCancelPayment")
        let navigationController = UINavigationController(rootViewController: dropInViewController)
        presentViewController(navigationController, animated: true, completion: nil)
    }
    
    func userDidCancelPayment() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    // MARK: - BTDropInViewControllerDelegate
    func dropInViewController(viewController: BTDropInViewController,
        didSucceedWithTokenization paymentMethodNonce: BTPaymentMethodNonce)
    {
//        if viewController.view.tag != 100 {
//            let nonce = paymentMethodNonce.nonce
//            let venmoAccountNonce = paymentMethodNonce as? BTVenmoAccountNonce
////            if (venmoAccountNonce != nil) {
////                let username = venmoAccountNonce!.username
//            
//                let deviceData = BTDataCollector(environment: .Production).collectPayPalClientMetadataId()
//                
//                PNPaymentHelper.sharedInstance.postPaymentRequestToServer(paymentMethodNonce, amount: "100", deviceData: deviceData, callback: { (nsData, error, isSucceed) -> Void in
//                    print(nsData)
//                })
////            }
//        } else {
        // Send payment method nonce to your server for processing
            SVProgressHUD.show()
            
            PNAPIClient.sharedInstance.setInprogressToProject((self.projectData?.id)!, callback: { (finished, error) -> Void in
                if finished {
                    PNPaymentHelper.sharedInstance.postNonceToServer(paymentMethodNonce, amount: "\(self.fundAmount)") { (nsData, error, isSucceed) -> Void in
                        if isSucceed == true {
                            PNAPIClient.sharedInstance.setProjectStatusTo((self.projectData?.id)!, status: EProjectStatus.InProgress, callback: { (finished, error) -> Void in
                                SVProgressHUD.dismiss()
                                NSNotificationCenter.defaultCenter().postNotificationName(kNotiRefreshProjectsFeed, object: nil)
                            })
                            
                            self.dismissViewControllerAnimated(true) { () -> Void in
                                if self.respondBlock != nil {
                                    self.respondBlock!(isPaid: true, error: nil)
                                }
                            }
                        } else {
                            Utilities.showMsg("Failed! Please try again later.", delegate: self)
                            
                            PNAPIClient.sharedInstance.setProjectStatusTo((self.projectData?.id)!, status: EProjectStatus.WaitingForFunding, callback: { (finished, error) -> Void in
                                SVProgressHUD.dismiss()
                            })
                        }
                    }
                }
            })
//        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func dropInViewControllerDidCancel(viewController: BTDropInViewController) {
        dismissViewControllerAnimated(true, completion: nil)
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

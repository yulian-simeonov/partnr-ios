//
//  APIController.swift
//  NimbleSchedule
//
//  Created by Yosemite on 10/15/15.
//  Copyright © 2015 YulianMobile. All rights reserved.
//

import Foundation
import Braintree

class PNPaymentHelper: AFHTTPRequestOperationManager {
    
    var braintreeClient: BTAPIClient?

    class var sharedInstance: PNPaymentHelper {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: PNPaymentHelper? = nil
        }
        
        dispatch_once(&Static.onceToken) {
            Static.instance = PNPaymentHelper()
            //            Static.instance?.securityPolicy.allowInvalidCertificates = true
            Static.instance?.requestSerializer = AFHTTPRequestSerializer()
            Static.instance?.responseSerializer = AFHTTPResponseSerializer()
        }
        
        return Static.instance!
    }
    
//    internal init () {
//        if braintreeClient == nil {
//            let clientTokenURL = NSURL(string: "\(BRAINTREE_SERVER_URL)/users/client_token")!
//            let clientTokenRequest = NSMutableURLRequest(URL: clientTokenURL)
//            clientTokenRequest.setValue("text/plain", forHTTPHeaderField: "Accept")
//            
//            NSURLSession.sharedSession().dataTaskWithRequest(clientTokenRequest) { (data, response, error) -> Void in
//                // TODO: Handle errors
//                if error == nil && data != nil {
//                    let clientToken = String(data: data!, encoding: NSUTF8StringEncoding)
//                    
//                    self.braintreeClient = BTAPIClient(authorization: clientToken!)
//                    // As an example, you may wish to present our Drop-in UI at this point.
//                    // Continue to the next section to learn more...
//                }
//            }.resume()
//        }
//    }
    
    // POST api call
    private func postTo(resource:String?, parameter:NSDictionary?, callback:((nsData:AnyObject?, error: NSError?) -> Void)) {
        print(parameter)
        let url = "\(BRAINTREE_SERVER_URL)/\(resource!)"
        print("request url=\(url)")
        self.POST(url, parameters: parameter, success: { (operation, object) -> Void in
            
            do {
                let parseData = try NSJSONSerialization.JSONObjectWithData(operation.responseData!, options: []) as! [String:AnyObject]
                // use anyObj here
                callback(nsData: parseData, error:nil)
                
            } catch {
                print(operation.response?.statusCode)
                if (operation.response?.statusCode == 200) {
                    callback(nsData: nil, error:nil)
                }
                print("json error: \(error)")
            }
            
            }) { (operation, error) -> Void in
                callback(nsData: nil, error:error)
        }
    }
    
    func getToken(callback:((token: String, isSucceed: Bool, error: NSError?) -> Void)) {
        if braintreeClient == nil {
            let clientTokenURL = NSURL(string: "\(BRAINTREE_SERVER_URL)/users/client_token")!
            let clientTokenRequest = NSMutableURLRequest(URL: clientTokenURL)
            clientTokenRequest.setValue("text/plain", forHTTPHeaderField: "Accept")
            
            NSURLSession.sharedSession().dataTaskWithRequest(clientTokenRequest) { (data, response, error) -> Void in
                // TODO: Handle errors
                if error == nil && data != nil {
                    let clientToken = String(data: data!, encoding: NSUTF8StringEncoding)
                    
                    self.braintreeClient = BTAPIClient(authorization: clientToken!)
                    // As an example, you may wish to present our Drop-in UI at this point.
                    // Continue to the next section to learn more...
                    
                    callback(token: clientToken!, isSucceed: true, error: nil)
                } else {
                    callback(token: "", isSucceed: false, error: error)
                }
            }.resume()
        }
    }
 
    func postNonceToServer(paymentMethodNonce: BTPaymentMethodNonce, amount: String, callback:((nsData:AnyObject?, error: NSError?, isSucceed: Bool) -> Void)) {
        
        let param = ["payment_method_nonce": paymentMethodNonce.nonce, "payment_cost_amount": amount]
        self.postTo("users/checkout", parameter: param) { (nsData, error) -> Void in
            print(nsData)
            if nsData!["success"].boolValue == true {
                callback(nsData: nsData, error: error, isSucceed: true)
            }
            else {
                callback(nsData: nsData, error: error, isSucceed: false)
            }
        }
        
//        let paymentURL = NSURL(string: "\(BRAINTREE_SERVER_URL)/users/checkout")!
//        let request = NSMutableURLRequest(URL: paymentURL)
//        request.HTTPBody = "payment_method_nonce=\(paymentMethodNonce)&payment_cost_amount=\(amount)".dataUsingEncoding(NSUTF8StringEncoding)
//        request.HTTPMethod = "POST"
//        
//        NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
//            // TODO: Handle success or failure
//            let clientToken = String(data: data!, encoding: NSUTF8StringEncoding)
//
//            print(response)
//            callback(nsData: response, error: error)
//        }.resume()
    }
    
    func verifyVenmoWhitelist(email: String, phone: String, callback:((error: NSError?, isSucceed: Bool) -> Void)) {
        let phone = "4049130069"
        let email = "amanda@partnrinc.com"
        
        let venmoWhitelistRequest = NSMutableURLRequest(URL: NSURL(string: "https://api.venmo.com/pwv-whitelist")!)
        venmoWhitelistRequest.HTTPMethod = "POST"
        let postData = try! NSJSONSerialization.dataWithJSONObject(["email": email, "phone": phone], options: .PrettyPrinted)
        venmoWhitelistRequest.HTTPBody = postData
        venmoWhitelistRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        NSURLSession.sharedSession().dataTaskWithRequest(venmoWhitelistRequest) { ( _, response, _) -> Void in
            guard let httpResponse : NSHTTPURLResponse = response as? NSHTTPURLResponse else { return }
            if (httpResponse.statusCode == 200) {
                callback(error: nil, isSucceed: true)
            } else {
                callback(error: nil, isSucceed: false)
            }
        }.resume()
    }
    
    func postPaymentRequestToServer(paymentMethodNonce: BTPaymentMethodNonce, amount: String, deviceData: String, callback:((nsData:AnyObject?, error: NSError?, isSucceed: Bool) -> Void)) {
        
        let param = ["payment_method_nonce": paymentMethodNonce.nonce, "payment_cost_amount": amount, "device_data": deviceData]
        self.postTo("users/create_transaction", parameter: param) { (nsData, error) -> Void in
            print(nsData)
            if nsData!["success"].boolValue == true {
                callback(nsData: nsData, error: error, isSucceed: true)
            }
            else {
                callback(nsData: nsData, error: error, isSucceed: false)
            }
        }
    }
}
//
//  APIController.swift
//  NimbleSchedule
//
//  Created by Yosemite on 10/15/15.
//  Copyright © 2015 YulianMobile. All rights reserved.
//

import Foundation
import FBSDKLoginKit
import Parse
import ParseFacebookUtilsV4

class PNAPIClient {
    
    class var sharedInstance: PNAPIClient {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: PNAPIClient? = nil
        }
        
        dispatch_once(&Static.onceToken) {
            print("Parse Session Token: \(Static.onceToken)")
            Static.instance = PNAPIClient()
        }
        
        return Static.instance!
    }
    
    // Login through Facebook
    func loginToFacebook(callback:((nsData:AnyObject?, error: NSError?, succeed: Bool) -> Void)) {
        
        if FBSDKAccessToken.currentAccessToken() == nil {
            callback(nsData: nil, error: nil, succeed: false)
        } else {
            PFFacebookUtils.logInInBackgroundWithAccessToken(FBSDKAccessToken.currentAccessToken(), block: { (curUser, error) -> Void in
                print(curUser?.isNew)
                if curUser == nil {
                    callback(nsData: nil, error: error, succeed: false)
                } else {
                
                    SharedDataManager.sharedInstance.userName = curUser!.username
                    SharedDataManager.sharedInstance.password = curUser!.password
                    SharedDataManager.sharedInstance.isLoggedIn = true
                    
                    SharedDataManager.sharedInstance.saveUserInfo()
                    
                    PFACL.setDefaultACL(PFACL.init(user: curUser!), withAccessForCurrentUser: true)

                    callback(nsData: curUser, error: error, succeed: true)
                }
            })
        }
    }
    
    func signupUserToFacebook(name: String, username: String, email: String, profession: String, password: String, avatarImg: NSData!, locationName: String, facebookID: String, phoneNumber: String? = nil, website: String? = nil, bio: String? = nil, coordinate: CLLocationCoordinate2D, callback:((nsData:AnyObject?, error: NSError?, succeed: Bool) -> Void)) {
        
        if FBSDKAccessToken.currentAccessToken() == nil {
            callback(nsData: nil, error: nil, succeed: false)
        } else {
            PFFacebookUtils.logInInBackgroundWithAccessToken(FBSDKAccessToken.currentAccessToken(), block: { (curUser, error) -> Void in
                print(curUser?.isNew)
                if curUser == nil {
                    callback(nsData: nil, error: error, succeed: false)
                } else {
                    
                    curUser!.setObject(name, forKey: "name")
                    curUser!.setObject(username, forKey: "username")
                    curUser!.setObject(password, forKey: "password")
                    curUser!.setObject(email, forKey: "email")
                    curUser!.setObject(profession, forKey: "profession")
                    curUser!.setObject(false, forKey: "isCompany")
                    curUser!.setObject(facebookID, forKey: "facebookID")
                    
                    if let phoneNumber = phoneNumber {
                        curUser!.setObject(phoneNumber, forKey: "phoneNumber")
                    }
                    if let website = website {
                        curUser!.setObject(website, forKey: "website")
                    }
                    if let bio = bio {
                        curUser!.setObject(bio, forKey: "bio")
                    }
                    
                    let avatarFile = PFFile.init(name: "avatar.png", data: avatarImg)
                    
                    curUser!.setObject(avatarFile!, forKey: "avatarImg")
                    
                    let geoPoint = PFGeoPoint.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
                    curUser!.setObject(geoPoint, forKey: "locationCoordinate")
                    curUser!.setObject(locationName, forKey: "locationName")
                    
                    curUser?.saveInBackgroundWithBlock({ (finished, error) -> Void in
                        if finished && error == nil {
                            callback(nsData: curUser, error: error, succeed: true)
                        } else {
                            callback(nsData: curUser, error: error, succeed: false)
                        }
                    })
                    

                }
            })
        }
    }
    
    func signupCompanyToFacebook(compName: String, username: String, email: String, website: String, password: String, description: String, avatarImg: NSData!, locationName: String, coordinate: CLLocationCoordinate2D, callback:((nsData:AnyObject?, error: NSError?, succeed: Bool) -> Void)) {
        
        if FBSDKAccessToken.currentAccessToken() == nil {
            callback(nsData: nil, error: nil, succeed: false)
        } else {
            PFFacebookUtils.logInInBackgroundWithAccessToken(FBSDKAccessToken.currentAccessToken(), block: { (curUser, error) -> Void in
                print(curUser?.isNew)
                if curUser == nil {
                    callback(nsData: nil, error: error, succeed: false)
                } else {
                    
                    curUser!.setObject(username, forKey: "username")
                    curUser!.setObject(password, forKey: "password")
                    curUser!.setObject(email, forKey: "email")
                    curUser!.setObject(description, forKey: "compDescription")
                    curUser!.setObject(compName, forKey: "name")
                    curUser!.setObject(website, forKey: "compWebsite")
                    curUser!.setObject(true, forKey: "isCompany")
                    
                    let avatarFile = PFFile.init(name: "avatar.png", data: avatarImg)
                    
                    curUser!.setObject(avatarFile!, forKey: "avatarImg")
                    
                    let geoPoint = PFGeoPoint.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
                    curUser!.setObject(geoPoint, forKey: "locationCoordinate")
                    curUser!.setObject(locationName, forKey: "locationName")
                    
                    curUser?.saveInBackgroundWithBlock({ (finished, error) -> Void in
                        if finished && error == nil {
                            callback(nsData: curUser, error: error, succeed: true)
                        } else {
                            callback(nsData: curUser, error: error, succeed: false)
                        }
                    })
                }
            })
        }
    }
    
    func linkToFacebook(callback:((nsData:AnyObject?, error: NSError?) -> Void)) {
        
        let login = FBSDKLoginManager.init()
        login.logOut()
        login.logInWithReadPermissions(["email", "public_profile", "user_friends"]) { (result, error) -> Void in
            if error != nil {
                callback(nsData: result, error: error)
            } else if result.isCancelled {
                callback(nsData: result, error: error)
            } else {
                FBSDKGraphRequest.init(graphPath: "me?fields=id,name,email,first_name,last_name,link,gender", parameters: nil).startWithCompletionHandler({ (connection, result, error) -> Void in

                    if error == nil {
                        callback(nsData: result, error: error)
                    } else {
                        callback(nsData: result, error: error)
                    }
                })
            }
        }
    }
    
    // Login to general user
    func loginToGeneralUser(username: String, password: String, callback:((nsData:AnyObject?, error: NSError?) -> Void)) {
        
        PFUser.logInWithUsernameInBackground(username, password: password) { (user, error) -> Void in
            
            if error == nil {
                SharedDataManager.sharedInstance.isLoggedIn = true
                SharedDataManager.sharedInstance.userName = username
                SharedDataManager.sharedInstance.password = password
                
                SharedDataManager.sharedInstance.saveUserInfo()
                
//                let acl = PFACL.init(user: PFUser.currentUser()!)
//                acl.publicWriteAccess = true
//                acl.setWriteAccess(true, forUser: PFUser.currentUser()!)
                
//                PFACL.setDefaultACL(PFACL.init(user: user!), withAccessForCurrentUser: true)
                
                callback(nsData: user, error: error)
            } else {
                SharedDataManager.sharedInstance.removeUserInfo()
                callback(nsData: user, error: error)
            }
        }
    }
    
    // Sign Up
    func signUpUser(name: String, username: String, email: String, profession: String, password: String, avatarImg: NSData!, locationName: String, phoneNumber: String? = nil, website: String? = nil, bio: String? = nil, coordinate: CLLocationCoordinate2D, callback:((nsData:AnyObject?, error: NSError?) -> Void))
    {
        let newUser = PFUser()
        newUser.setObject(name, forKey: "name")
        newUser.setObject(username, forKey: "username")
        newUser.setObject(password, forKey: "password")
        newUser.setObject(email, forKey: "email")
        newUser.setObject(profession, forKey: "profession")
        newUser.setObject(false, forKey: "isCompany")
        
        if let phoneNumber = phoneNumber {
            newUser.setObject(phoneNumber, forKey: "phoneNumber")
        }
        if let website = website {
            newUser.setObject(website, forKey: "website")
        }
        if let bio = bio {
            newUser.setObject(bio, forKey: "bio")
        }
        let avatarFile = PFFile.init(name: "avatar.png", data: avatarImg)
        
        newUser.setObject(avatarFile!, forKey: "avatarImg")
        
        let geoPoint = PFGeoPoint.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
        newUser.setObject(geoPoint, forKey: "locationCoordinate")
        newUser.setObject(locationName, forKey: "locationName")
        
        newUser.signUpInBackgroundWithBlock { (finished, error) -> Void in
            if finished && error == nil {
                callback(nsData: nil, error: error)
            } else {
                callback(nsData: nil, error: error)
            }
        }
    }
    
    func signUpCompany(compName: String, username: String, email: String, website: String, password: String, description: String, avatarImg: NSData!, locationName: String, coordinate: CLLocationCoordinate2D, callback:((nsData:AnyObject?, error: NSError?) -> Void))
    {
        let newUser = PFUser()
//        newUser.setObject(name, forKey: "name")
        newUser.setObject(username, forKey: "username")
        newUser.setObject(password, forKey: "password")
        newUser.setObject(email, forKey: "email")
        newUser.setObject(description, forKey: "compDescription")
        newUser.setObject(compName, forKey: "name")
        newUser.setObject(website, forKey: "compWebsite")
        newUser.setObject(true, forKey: "isCompany")
        
        let avatarFile = PFFile.init(name: "avatar.png", data: avatarImg)
        
        newUser.setObject(avatarFile!, forKey: "avatarImg")
        
        let geoPoint = PFGeoPoint.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
        newUser.setObject(geoPoint, forKey: "locationCoordinate")
        newUser.setObject(locationName, forKey: "locationName")
        
        newUser.signUpInBackgroundWithBlock { (finished, error) -> Void in
            if finished && error == nil {
                callback(nsData: nil, error: error)
            } else {
                callback(nsData: nil, error: error)
            }
        }
    }
    
    // MARK: - News API Function
    
    // Photo Share
    func sharePhotoToNews(photo: UIImage, captionStr: String, label: EPhotoLabel, tagArray: NSArray, projectId: String, callback:((nsData:AnyObject?, error: NSError?) -> Void)) {
        
        let newPhoto = PFObject.init(className: "News")
        let imageFile = PFFile.init(data: UIImageJPEGRepresentation(photo, 1.0)!)
        
        newPhoto.setObject(imageFile!, forKey: "photoFile")
        newPhoto.setObject(captionStr, forKey: "caption")
        newPhoto.setObject(tagArray.componentsJoinedByString(","), forKey: "tags")
        newPhoto.setObject(projectId, forKey: "projectId")
        newPhoto.setObject(PFUser.currentUser()!.objectId!, forKey: "userId")
        newPhoto.setObject(PFUser.currentUser()!.username!, forKey: "userName")
        newPhoto.setObject(photo.size.width, forKey: "photoWidth")
        newPhoto.setObject(photo.size.height, forKey: "photoHeight")
        newPhoto.setObject(ENewsType.Photo.rawValue, forKey: "type")
        newPhoto.setObject(label.rawValue, forKey: "label")

        let userPointer = PFObject.init(withoutDataWithClassName: "_User", objectId: PFUser.currentUser()?.objectId)
        newPhoto.setObject(userPointer, forKey: "fromUser")
        
        self.assignPublicReadWritePermission(newPhoto)
        
        newPhoto.saveInBackgroundWithBlock { (finished, error) -> Void in
            callback(nsData: newPhoto, error: error)
            
            if error == nil && finished {
                self.checkPhotoPostsAndSharePeopleNews()
            }
        }
    }
    
    func deleteNews(newsId: NSString, callback:((finished: Bool, error: NSError?) -> Void)) {
        let query = PFQuery.init(className: "News")
        query.whereKey("objectId", equalTo: newsId)
        query.findObjectsInBackgroundWithBlock { (resultArray, error) -> Void in
            PFObject.deleteAllInBackground(resultArray, block: { (finished, error) -> Void in
                callback(finished: finished, error: error)
            })
        }
    }
    
    // Share Note
    func shareNoteToNews(noteText: String, label: ENoteLabel, tagArray: NSArray, callback:((finished: Bool, error: NSError?) -> Void)) {
        
        let newNote = PFObject.init(className: "News")
        newNote.setObject((PFUser.currentUser()?.objectId)!, forKey: "userId")
        newNote.setObject((PFUser.currentUser()?.username)!, forKey: "userName")
        newNote.setObject(ENewsType.Note.rawValue, forKey: "type")
        newNote.setObject(noteText, forKey: "caption")
        newNote.setObject(tagArray.componentsJoinedByString(","), forKey: "tags")
        newNote.setObject(label.rawValue, forKey: "label")
        
        newNote.saveInBackgroundWithBlock { (finished, error) -> Void in
            callback(finished: finished, error: error)
        }
//        newNote.
    }
    
    // Share People News
    func sharePeopelToNews(callback:((finished: Bool, error: NSError?) -> Void)) {
        
        let newNote = PFObject.init(className: "News")
        newNote.setObject((PFUser.currentUser()?.objectId)!, forKey: "userId")
        newNote.setObject((PFUser.currentUser()?.username)!, forKey: "userName")
        newNote.setObject(ENewsType.People.rawValue, forKey: "type")
        
        let caption = "Welcome \((PFUser.currentUser()?.username)!) to Partnr! Check out their profile, and what they're up to! Godspeedddddddddd."
        newNote.setObject(caption, forKey: "caption")
        
        newNote.saveInBackgroundWithBlock { (finished, error) -> Void in
            callback(finished: finished, error: error)
        }
    }

    func shareCommunityToNews(callback:((finished: Bool, error: NSError?) -> Void)) {
        
        let newNote = PFObject.init(className: "News")
        newNote.setObject((PFUser.currentUser()?.objectId)!, forKey: "userId")
        newNote.setObject((PFUser.currentUser()?.username)!, forKey: "userName")
        newNote.setObject(ENewsType.Community.rawValue, forKey: "type")
        
        let caption = "Check out our newest Partnr, \(SharedDataManager.sharedInstance.userData.name)! They are a \(SharedDataManager.sharedInstance.userData.profession) from \(SharedDataManager.sharedInstance.userData.locationName)."
        newNote.setObject(caption, forKey: "caption")
        
        newNote.saveInBackgroundWithBlock { (finished, error) -> Void in
            callback(finished: finished, error: error)
        }
    }
    
    func sharePaymentToNews(projectName: String, callback:((finished: Bool, error: NSError?) -> Void)) {
        
        let newNote = PFObject.init(className: "News")
        newNote.setObject((PFUser.currentUser()?.objectId)!, forKey: "userId")
        newNote.setObject((PFUser.currentUser()?.username)!, forKey: "userName")
        newNote.setObject(ENewsType.Payday.rawValue, forKey: "type")
        
        let caption = "\(PFUser.currentUser()?.username) paid for \(projectName). Cha-ching!"
        newNote.setObject(caption, forKey: "caption")
        
        newNote.saveInBackgroundWithBlock { (finished, error) -> Void in
            callback(finished: finished, error: error)
        }
    }
    
    func checkPhotoPostsAndSharePeopleNews() {
        let query = PFQuery.init(className: "News")
        query.whereKey("userId", equalTo: (PFUser.currentUser()?.objectId!)!)
        query.whereKey("type", equalTo: ENewsType.Photo.rawValue)
        
        query.findObjectsInBackgroundWithBlock { (result, error) -> Void in
            
            if error == nil && result != nil {
//                if (result?.count)! % 5 == 0 && result?.count > 0 {
                    self.sharePeopelToNews({ (finished, error) -> Void in
                        NSNotificationCenter.defaultCenter().postNotificationName(kNotiRefreshNewsFeed, object: nil)
                    })
//                }
            }
        }

    }
    
    // Share Partnr News
    func sharePartnrNews(projectId: String, callback:((finished: Bool, error: NSError?) -> Void)) {
        
        let newPartnr = PFObject.init(className: "News")
        newPartnr.setObject((PFUser.currentUser()?.objectId)!, forKey: "userId")
        newPartnr.setObject((PFUser.currentUser()?.username)!, forKey: "userName")
        newPartnr.setObject(ENewsType.Partnr.rawValue, forKey: "type")
        
        newPartnr.setObject(projectId, forKey: "projectId")
        
        newPartnr.saveInBackgroundWithBlock { (finished, error) -> Void in
            callback(finished: finished, error: error)
        }
    }
    
    // Community
    func feedCommunity(userId: String?, callback:((nsData:AnyObject?, error: NSError?) -> Void)) {
        let query = PFQuery.init(className: "News")
        
        query.whereKey("type", notContainedIn: [ENewsType.Note.rawValue, ENewsType.Photo.rawValue, ENewsType.People.rawValue])
        
        if userId != nil && userId?.isEmpty == false {
            query.whereKey("userId", equalTo: userId!)
        }
        
        query.orderByDescending("createdAt")
        query.findObjectsInBackgroundWithBlock { (result, error) -> Void in
            
            if error == nil && result != nil {
                let resultArray = NSMutableArray()
                for newsObj in result! {
                    print(newsObj)
                    resultArray.addObject(NewsData.initWithParseObject(newsObj)!)
                }
                callback(nsData: resultArray, error: error);
            } else {
                callback(nsData: nil, error: error)
            }
        }
    }
    
    // Feed news
    func feedNews(userId: String?, callback:((nsData:[NewsData]?, error: NSError?) -> Void)) {
        let query = PFQuery.init(className: "News")
        
        query.whereKey("type", notContainedIn: [ENewsType.Note.rawValue, ENewsType.Photo.rawValue, ENewsType.People.rawValue])
        
        if userId != nil && userId?.isEmpty == false {
            query.whereKey("userId", equalTo: userId!)
        }
        
        query.orderByDescending("createdAt")
        query.findObjectsInBackgroundWithBlock { (result, error) -> Void in
            
            if error == nil && result != nil {
                var resultArray = [NewsData]()
                for newsObj in result! {
                    print(newsObj)
                    resultArray.append(NewsData.initWithParseObject(newsObj)!)
                }
                callback(nsData: resultArray, error: error);
            } else {
                callback(nsData: nil, error: error)
            }
        }
    }
    
    func feedNews(userId: String?, newsType: ENewsType?, callback:((nsData:AnyObject?, error: NSError?) -> Void)) {
        let query = PFQuery.init(className: "News")
        if userId != nil && userId?.isEmpty == false {
            query.whereKey("userId", equalTo: userId!)
        }
        query.whereKey("type", equalTo: (newsType?.rawValue)!)
        query.orderByDescending("createdAt")
        query.findObjectsInBackgroundWithBlock { (result, error) -> Void in
            
            if error == nil && result != nil {
                let resultArray = NSMutableArray()
                for newsObj in result! {
                    print(newsObj)
                    resultArray.addObject(NewsData.initWithParseObject(newsObj)!)
                }
                callback(nsData: resultArray, error: error);
            } else {
                callback(nsData: nil, error: error)
            }
        }
    }
    
    // Chekc if Email exists
    func checkIfEmailExists(email: String, callback:((isExist:Bool, error: NSError?) -> Void)) {
        let query = PFUser.query()
        query?.whereKey("email", equalTo: email)
        query?.findObjectsInBackgroundWithBlock({ (result, error) -> Void in
            if result?.count > 0 {
                callback(isExist: true, error: error)
            } else {
                callback(isExist: false, error: error)
            }
        })
    }
    
    // Chekc if Username exists
    func checkIfUsernameExists(username: String, callback:((isExist:Bool, error: NSError?) -> Void)) {
        let query = PFUser.query()
        query?.whereKey("username", equalTo: username)
        query?.findObjectsInBackgroundWithBlock({ (result, error) -> Void in
            if result?.count > 0 {
                callback(isExist: true, error: error)
            } else {
                callback(isExist: false, error: error)
            }
        })
    }
    
    // Get User Info
    func getUserInfo(userId: String, callback:((nsData:PFUser?, error: NSError?) -> Void)) {
        let query = PFUser.query()
        query?.whereKey("objectId", equalTo: userId)
        query?.findObjectsInBackgroundWithBlock({ (result, error) -> Void in
            if result?.count > 0 {
                callback(nsData: result![0] as? PFUser, error: error)
            } else {
                callback(nsData: nil, error: error)
            }
        })
    }
    
    // Fetch Comment Info
    func fetchCommentInfo(newsId: String, callback:((succeed: Bool, nsData:AnyObject?, error: NSError?) -> Void)) {
        let query = PFQuery.init(className: "Comment")
        query.whereKey("newsId", equalTo: newsId)
        query.findObjectsInBackgroundWithBlock({ (result, error) -> Void in
            if error == nil && result != nil {
                let resultArray = NSMutableArray()
                for newsObj in result! {
                    resultArray.addObject(CommentData.initWithParseObject(newsObj)!)
                }
                callback(succeed: true, nsData: resultArray, error: error);
            } else {
                callback(succeed: false, nsData: nil, error: error)
            }
        })
    }
    
    func postComment(commentStr: String, newsId: String, callback:((succeed: Bool, commentData: CommentData?, error: NSError?) -> Void)) {
        
        let commentObj = PFObject.init(className: "Comment")
        commentObj.setObject(PFUser.currentUser()!.objectId!, forKey: "userId")
        commentObj.setObject(PFUser.currentUser()!.username!, forKey: "userName")
        commentObj.setObject(newsId, forKey: "newsId")
        commentObj.setObject(commentStr, forKey: "commentStr")
        
        let userPointer = PFObject.init(withoutDataWithClassName: "_User", objectId: PFUser.currentUser()?.objectId)
        commentObj.setObject(userPointer, forKey: "fromUser")
        let newsPointer = PFObject.init(withoutDataWithClassName: "News", objectId: newsId)
        commentObj.setObject(newsPointer, forKey: "toNews")

        commentObj.saveInBackgroundWithBlock { (succeed, error) -> Void in
            if succeed && error == nil {
                callback(succeed: true, commentData: CommentData.initWithParseObject(commentObj)!, error: error)
            } else {
                callback(succeed: false, commentData: nil, error: error)
            }
        }
    }

    // Fetch Like Info
    func fetchLikeInfo(newsId: String, callback:((succeed: Bool, nsData:AnyObject?, isLiked: Bool, error: NSError?) -> Void)) {
        let query = PFQuery.init(className: "Like")
        query.whereKey("newsId", equalTo: newsId)
        query.findObjectsInBackgroundWithBlock({ (result, error) -> Void in
            if result != nil && error == nil {
                var isLiked = false
                for likeObj in result! {
                    if PFUser.currentUser()?.objectId == likeObj["userId"] as? String {
                        isLiked = true
                        break
                    }
                }
                callback(succeed: true, nsData: result, isLiked: isLiked, error: error)
            } else {
                callback(succeed: false, nsData: nil, isLiked: false,  error: error)
            }
        })
    }
    
    func postLike(newsId: String, callback:((succeed: Bool, likeData: LikeData?, error: NSError?) -> Void)) {
        
        let likeObj = PFObject.init(className: "Like")
        likeObj.setObject(newsId, forKey: "newsId")
        likeObj.setObject(PFUser.currentUser()!.objectId!, forKey: "userId")
        likeObj.setObject(PFUser.currentUser()!.username!, forKey: "userName")
        
        let userPointer = PFObject.init(withoutDataWithClassName: "_User", objectId: PFUser.currentUser()?.objectId)
        likeObj.setObject(userPointer, forKey: "fromUser")
        let newsPointer = PFObject.init(withoutDataWithClassName: "News", objectId: newsId)
        likeObj.setObject(newsPointer, forKey: "toNews")
        
        likeObj.saveInBackgroundWithBlock { (succeed, error) -> Void in
            if succeed && error == nil {
                callback(succeed: true, likeData: LikeData.initWithParseObject(likeObj)!, error: error)
            } else {
                callback(succeed: false, likeData: nil, error: error)
            }
        }
    }
    
    func postUnLike(newsId: String, callback:((succeed: Bool, error: NSError?) -> Void)) {
        
        let query = PFQuery.init(className: "Like")
        query.whereKey("newsId", equalTo: newsId)
        query.whereKey("userId", equalTo: PFUser.currentUser()!.objectId!)
        query.findObjectsInBackgroundWithBlock { (resultArray, error) -> Void in
            PFObject.deleteAllInBackground(resultArray, block: { (finished, error) -> Void in
                callback(succeed: finished, error: error)
            })
        }
    }
    
    // Follow
    func followToUserId(userId: String, callback:((succeed: Bool, error: NSError?) -> Void)) {

        let fromUserPointer = PFObject.init(withoutDataWithClassName: "_User", objectId: PFUser.currentUser()?.objectId)
        let toUserPointer = PFObject.init(withoutDataWithClassName: "_User", objectId: userId)
        
        let query = PFQuery.init(className: "Follow")
        query.whereKey("toUser", equalTo: toUserPointer)
        query.whereKey("fromUser", equalTo: fromUserPointer)
        
        query.findObjectsInBackgroundWithBlock { (result, error) -> Void in
            if error == nil && result?.count == 0 {
                let followObj = PFObject.init(className: "Follow")
                
                followObj.setObject(fromUserPointer, forKey: "fromUser")
                followObj.setObject(toUserPointer, forKey: "toUser")
                
                followObj.saveInBackgroundWithBlock({ (finished, error) -> Void in
                    callback(succeed: finished, error: error)
                })
            } else {
                callback(succeed: false, error: error)
            }
        }
    }
    
    func unfollowToUserId(userId: String, callback:((succeed: Bool, error: NSError?) -> Void)) {
        
        let query = PFQuery.init(className: "Follow")
        let userPointer = PFObject.init(withoutDataWithClassName: "_User", objectId: userId)
        query.whereKey("toUser", equalTo: userPointer)
        query.whereKey("fromUser", equalTo: PFObject.init(withoutDataWithClassName: "_User", objectId: PFUser.currentUser()?.objectId))
        query.findObjectsInBackgroundWithBlock { (result, error) -> Void in
            if result?.count > 0 {
                PFObject.deleteAllInBackground(result, block: { (finished, error) -> Void in
                    callback(succeed: finished, error: error)
                })
            } else {
                callback(succeed: false, error: error)
            }
        }
    }
    
    func fetchFollowers(userId: String, callback:((succeed: Bool, followArray: [FollowData]?, error: NSError?) -> Void)) {
        let query = PFQuery.init(className: "Follow")
        let userPointer = PFObject.init(withoutDataWithClassName: "_User", objectId: userId)
        query.whereKey("toUser", equalTo: userPointer)
        query.findObjectsInBackgroundWithBlock { (result, error) -> Void in
            if error == nil && result != nil {
                var resultArray = [FollowData]()
                for newsObj in result! {
                    resultArray.append(FollowData.initWithParseObject(newsObj)!)
                }
                callback(succeed: true, followArray: resultArray, error: error);
            } else {
                callback(succeed: false, followArray: nil, error: error)
            }
        }
    }

    func fetchFollowing(userId: String, callback:((succeed: Bool, followArray: [FollowData]?, error: NSError?) -> Void)) {
        let query = PFQuery.init(className: "Follow")
        let userPointer = PFObject.init(withoutDataWithClassName: "_User", objectId: userId)
        query.whereKey("fromUser", equalTo: userPointer)
        query.findObjectsInBackgroundWithBlock { (result, error) -> Void in
            if error == nil && result != nil {
                var resultArray = [FollowData]()
                for newsObj in result! {
                    resultArray.append(FollowData.initWithParseObject(newsObj)!)
                }
                callback(succeed: true, followArray: resultArray, error: error);
            } else {
                callback(succeed: false, followArray: nil, error: error)
            }
        }
    }

    func fetchPartnr(userId: String, callback:((succeed: Bool, partnrArray: [String]?, error: NSError?) -> Void)) {
        let query = PFQuery.init(className: "Project")
        query.whereKey("userId", equalTo: userId)
        query.whereKey("partnrId", notEqualTo: NSNull())
        query.orderByDescending("updatedAt")
        query.findObjectsInBackgroundWithBlock { (result, error) -> Void in
            if error == nil && result != nil {
                var resultArray = [String]()
                for parseObj in result! {
                    resultArray.append(parseObj["partnrId"] as! String)
                }
                callback(succeed: true, partnrArray: resultArray, error: error);
            } else {
                callback(succeed: false, partnrArray: nil, error: error)
            }
        }
    }
    
    func fetchPartnrProject(userId: String, callback:((succeed: Bool, projectArray: [ProjectData]?, error: NSError?) -> Void)) {
        let partnrQuery = PFQuery.init(className: "Project")
        partnrQuery.whereKey("userId", equalTo: userId)
        partnrQuery.whereKey("partnrId", notEqualTo: NSNull())
        partnrQuery.whereKey("status", equalTo: EProjectStatus.Completed.rawValue)

        let adminQuery = PFQuery.init(className: "Project")
        adminQuery.whereKey("partnrId", equalTo: userId)
        adminQuery.whereKey("userId", notEqualTo: NSNull())
        adminQuery.whereKey("status", equalTo: EProjectStatus.Completed.rawValue)

        let query = PFQuery.orQueryWithSubqueries([partnrQuery, adminQuery])
        
        query.orderByDescending("updatedAt")
        query.findObjectsInBackgroundWithBlock { (result, error) -> Void in
            if error == nil && result != nil {
                var resultArray = [ProjectData]()
                for parseObj in result! {
                    resultArray.append(ProjectData.initWithParseObject(parseObj)!)
                }
                callback(succeed: true, projectArray: resultArray, error: error);
            } else {
                callback(succeed: false, projectArray: nil, error: error)
            }
        }
    }
    
    func checkIfFollow(fromUserId: String, toUserId: String, callback:((isFollowed: Bool, error: NSError?) -> Void)) {
        let query = PFQuery.init(className: "Follow")
        let userPointer = PFObject.init(withoutDataWithClassName: "_User", objectId: fromUserId)
        query.whereKey("fromUser", equalTo: userPointer)
        query.whereKey("toUser", equalTo: PFObject.init(withoutDataWithClassName: "_User", objectId: toUserId))
        query.findObjectsInBackgroundWithBlock { (result, error) -> Void in
            if error == nil && result?.count > 0 {
                callback(isFollowed: true, error: error)
            } else {
                callback(isFollowed: false, error: error)
            }
        }
    }
    
    
    // MARK: -  Fetch
    
    func fetchUser(userPointer: PFObject, callback:((userData: UserData?, error: NSError?) -> Void)) {
        userPointer.fetchIfNeededInBackgroundWithBlock { (userObject, error) -> Void in
            if userObject as? PFUser == nil {
                callback(userData: nil, error: error)
            } else {
                let userData = UserData.initWithParseObject(userObject as? PFUser)
                callback(userData: userData, error: error)
            }
        }
    }
    
    func fetchNews(newsPointer: PFObject, callback:((newsData: NewsData?, error: NSError?) -> Void)) {
        newsPointer.fetchIfNeededInBackgroundWithBlock { (newsObject, error) -> Void in
            if newsObject == nil {
                callback(newsData: nil, error: error)
            } else {
                let newsData = NewsData.initWithParseObject(newsObject)
                callback(newsData: newsData, error: error)
            }
        }
    }
    
    func fetchProject(projectId: String, callback:((projectData: ProjectData?, error: NSError?) -> Void)) {
        let pointer = PFObject.init(withoutDataWithClassName: "Project", objectId: projectId)
        pointer.fetchIfNeededInBackgroundWithBlock { (projectObj, error) -> Void in
            if projectObj == nil {
                callback(projectData: nil, error: error)
            } else {
                let projectData = ProjectData.initWithParseObject(projectObj)
                callback(projectData: projectData, error: error)
            }
        }
    }
    
    func fetchApplicant(applicantId: String, callback:((applicantData: ApplicantData?, error: NSError?) -> Void)) {
        let pointer = PFObject.init(withoutDataWithClassName: "Applicant", objectId: applicantId)
        pointer.fetchIfNeededInBackgroundWithBlock { (applicantObj, error) -> Void in
            if applicantObj == nil {
                callback(applicantData: nil, error: error)
            } else {
                let applicantData = ApplicantData.initWithParseObject(applicantObj)
                callback(applicantData: applicantData, error: error)
            }
        }
    }
    
    // MARK: - Search
    func doSearch(searchKey: String, callback:((searchResult: NSArray?, error: NSError?) -> Void)) {
        let resultArray = NSMutableArray.init(array: [])
    
        let query  = PFUser.query()
        query!.whereKeyExists("name")
        query!.whereKey("name", matchesRegex:searchKey, modifiers:"i")
        query?.findObjectsInBackgroundWithBlock({ (users, error) -> Void in
            if error == nil {
                for userObj in users! {
                    resultArray.addObject(UserData.initWithParseObject(userObj as? PFUser)!)
                }
            }
            
            let projectQuery = PFQuery.init(className: "Project")
            projectQuery.whereKeyExists("title")
            projectQuery.whereKey("title", matchesRegex:searchKey, modifiers:"i")
            
            projectQuery.findObjectsInBackgroundWithBlock({ (projects, error) -> Void in
                if error == nil {
                    for projectObj in projects! {
                        resultArray.addObject(ProjectData.initWithParseObject(projectObj)!)
                    }
                }
                
                callback(searchResult: resultArray, error: error)
            })
        })
    }
    
    func searchUsers(profession: String, callback:((userArray: [UserData], error: NSError?) -> Void)) {
        var resultArray = [UserData]()
        
        let query  = PFUser.query()
        query!.whereKeyExists("profession")
        query?.whereKey("profession", equalTo: profession)
        query?.findObjectsInBackgroundWithBlock({ (users, error) -> Void in
            if error == nil {
                for userObj in users! {
                    resultArray.append(UserData.initWithParseObject(userObj as? PFUser)!)
                }
                callback(userArray: resultArray, error: error)
            } else {
                callback(userArray: resultArray, error: error)
            }
        })
    }
    
    // Post Project
    func removeBrief(projectId: String, callback:((finished: Bool, error: NSError?) -> Void)) {
        let query = PFQuery.init(className: "Project")
        query.whereKey("briefUserId", equalTo: (PFUser.currentUser()?.objectId)!)
        query.whereKey("objectId", equalTo: projectId)
        query.findObjectsInBackgroundWithBlock { (projects, error) -> Void in
            if error == nil && projects?.count > 0 {
                projects![0].setValue("NotInterested", forKey: "briefUserId")
                projects![0].saveInBackgroundWithBlock({ (finished, error) -> Void in
                    callback(finished: finished, error: error)
                })
            }
        }
    }
    
    func postBriefProject(briefUserId: String, name: String, client: String, brief: String, deliverables: String, price: Double, dueDate: NSDate, image: UIImage, callback:((finished: Bool, error: NSError?) -> Void)) {
        let project = PFObject.init(className: "Project")
        
        project.setObject(briefUserId, forKey: "briefUserId")
        
        project.setObject(name, forKey: "name")
        project.setObject(client, forKey: "client")
        project.setObject(brief, forKey: "brief")
        project.setObject(deliverables, forKey: "deliverables")
        project.setObject(price, forKey: "price")
        project.setObject(dueDate, forKey: "dueDate")
        project.setObject((PFUser.currentUser()?.objectId!)!, forKey: "userId")
        project.setObject(EProjectStatus.Open.rawValue, forKey: "status")
        
        let userPointer = PFObject.init(withoutDataWithClassName: "_User", objectId: PFUser.currentUser()?.objectId)
        
        project.setObject(userPointer, forKey: "user")
        
        let imageFile = PFFile.init(data: UIImageJPEGRepresentation(image, 1.0)!)
        project.setObject(imageFile!, forKey: "image")
        
        self.assignPublicReadWritePermission(project)
        
        project.saveInBackgroundWithBlock { (finished, error) -> Void in
            callback(finished: finished, error: error)
        }
    }
    
    func postProject(name: String, profession: String, client: String, brief: String, deliverables: String, price: Double, dueDate: NSDate, image: UIImage, callback:((finished: Bool, error: NSError?) -> Void)) {
        let project = PFObject.init(className: "Project")
        project.setObject(name, forKey: "name")
        project.setObject(profession, forKey: "profession")
        project.setObject(client, forKey: "client")
        project.setObject(brief, forKey: "brief")
        project.setObject(deliverables, forKey: "deliverables")
        project.setObject(price, forKey: "price")
        project.setObject(dueDate, forKey: "dueDate")
        project.setObject((PFUser.currentUser()?.objectId!)!, forKey: "userId")
        project.setObject(EProjectStatus.Open.rawValue, forKey: "status")
        
        let userPointer = PFObject.init(withoutDataWithClassName: "_User", objectId: PFUser.currentUser()?.objectId)
        
        project.setObject(userPointer, forKey: "user")
        
        let imageFile = PFFile.init(data: UIImageJPEGRepresentation(image, 1.0)!)
        project.setObject(imageFile!, forKey: "image")
        
        self.assignPublicReadWritePermission(project)
        
        project.saveInBackgroundWithBlock { (finished, error) -> Void in
            callback(finished: finished, error: error)
        }
    }
    
    func feedOpenProject(profession: [NSInteger], callback:((projects: [ProjectData]?, error: NSError?) -> Void)) {
        let query = PFQuery.init(className: "Project")
        if profession.count > 0 {
            var array = [String]()
            for typeIndex in profession {
                array.append(PROJECT_TYPES[typeIndex-1])
            }
            query.whereKey("profession", containedIn: array)
        }
        
        query.whereKey("briefUserId", equalTo: NSNull())
        query.whereKey("status", equalTo: EProjectStatus.Open.rawValue)
        query.orderByDescending("updatedAt")

        query.findObjectsInBackgroundWithBlock { (projects, error) -> Void in
            if error == nil {
                var resultArray = [ProjectData]()
                for project in projects! {
                    resultArray.append(ProjectData.initWithParseObject(project)!)
                }
                callback(projects: resultArray, error: error)
            } else {
                callback(projects: nil, error: error)
            }
        }
    }
    
    func feedAllProject(profession: [NSInteger], callback:((projects: NSArray, error: NSError?) -> Void)) {
        let query = PFQuery.init(className: "Project")
        if profession.count > 0 {
            var array = [String]()
            for typeIndex in profession {
                array.append(PROJECT_TYPES[typeIndex-1])
            }
            query.whereKey("profession", containedIn: array)
        }
        
        query.findObjectsInBackgroundWithBlock { (projects, error) -> Void in
            if error == nil {
                let resultArray = NSMutableArray()
                for project in projects! {
                    resultArray.addObject(ProjectData.initWithParseObject(project)!)
                }
                callback(projects: resultArray, error: error)
            } else {
                callback(projects: projects!, error: error)
            }
        }
    }
    
    func feedMyProject(profession: [NSInteger], callback:((projects: NSArray, error: NSError?) -> Void)) {
        let newBriefQuery = PFQuery.init(className: "Project")
        newBriefQuery.whereKey("briefUserId", equalTo: (PFUser.currentUser()?.objectId)!)
        
        let userIdQuery = PFQuery.init(className: "Project")
//        if profession.count > 0 {
//            var array = [String]()
//            for typeIndex in profession {
//                array.append(PROJECT_TYPES[typeIndex-1])
//            }
//            query.whereKey("profession", containedIn: array)
//        }
        
        userIdQuery.whereKey("userId", equalTo: (PFUser.currentUser()?.objectId)!)
        
        let partnrIdQuery = PFQuery.init(className: "Project")
        partnrIdQuery.whereKey("partnrId", equalTo: (PFUser.currentUser()?.objectId)!)
        
        let query = PFQuery.orQueryWithSubqueries([userIdQuery, partnrIdQuery, newBriefQuery])
        query.orderByDescending("updatedAt")
        
        query.findObjectsInBackgroundWithBlock { (projects, error) -> Void in
            if error == nil {
                let resultArray = NSMutableArray()
                for project in projects! {
                    resultArray.addObject(ProjectData.initWithParseObject(project)!)
                }
                callback(projects: resultArray, error: error)
            } else {
                let resultArray = NSMutableArray()
                callback(projects: resultArray, error: error)
            }
        }
    }
    
    func getApplicants(projectId: String, callback:((applicants: [ApplicantData], error: NSError?) -> Void)) {
        let query = PFQuery.init(className: "Applicant")
        query.whereKey("projectId", equalTo: projectId)
        
        query.findObjectsInBackgroundWithBlock { (result, error) -> Void in
            if result?.count > 0 && error == nil {
                var userIds = [ApplicantData]()
                for item in result! {
                    userIds.append(ApplicantData.initWithParseObject(item)!)
                }
                callback(applicants: userIds, error: nil)
            } else {
                callback(applicants: [], error: error)
            }
        }
    }
    
    func assignPublicReadWritePermission(parseObj: PFObject) {
        let acl = PFACL.init(user: PFUser.currentUser()!)
        acl.publicWriteAccess = true
        acl.publicReadAccess = true
        parseObj.ACL = acl
    }
    
    func acceptToProject(projectId: String, price: NSNumber, callback:((finished: Bool, error: NSError?) -> Void)) {
        
        let applicantObj = PFObject.init(className: "Applicant")
        applicantObj.setObject(projectId, forKey: "projectId")
        applicantObj.setObject((PFUser.currentUser()?.objectId)!, forKey: "userId")
        applicantObj.setObject(EApplicantStatus.None.rawValue, forKey: "status")
        applicantObj.setObject(price, forKey: "price")
        
        self.assignPublicReadWritePermission(applicantObj)
        
        applicantObj.saveInBackgroundWithBlock { (finished, error) -> Void in
            callback(finished: finished, error: error)
        }
    }
    
    func isAcceptedToProject(projectId: String, callback:((isAccepted: Bool, error: NSError?) -> Void)) {
        
        let query = PFQuery.init(className: "Applicant")
        query.whereKey("projectId", equalTo: projectId)
        query.whereKey("userId", equalTo: (PFUser.currentUser()?.objectId)!)
        
        query.findObjectsInBackgroundWithBlock { (result, error) -> Void in
            if result?.count > 0 && error == nil {
                callback(isAccepted: true, error: nil)
            } else {
                callback(isAccepted: false, error: error)
            }
        }
    }
    
    func sendHireToApplicant(applicantData: ApplicantData, projectObj: PFObject, callback:((finished: Bool, error: NSError?) -> Void)) {
        
        let query = PFQuery.init(className: "Applicant")
        query.whereKey("objectId", equalTo: applicantData.id)
        let parseObj = applicantData.parseObj!
        parseObj.setObject(EApplicantStatus.Requested.rawValue, forKey: "status")
        parseObj.saveInBackgroundWithBlock({ (finished, error) -> Void in
            if finished && error == nil {
                projectObj.setObject(EProjectStatus.Pending.rawValue, forKey: "status")
                projectObj.saveInBackgroundWithBlock({ (finished, error) -> Void in
                    callback(finished: finished, error: error)
                })
            } else {
                callback(finished: finished, error: error)
            }
        })
    }
    
    // MARK: - Project Comment
    func postCommentStrToProject(projectId: String, commentStr: String, callback:((succeed: Bool, commentData: ProjectCommentData?, error: NSError?) -> Void)) {
        
        let commentObj = PFObject.init(className: "ProjectComment")
        commentObj.setObject(PFUser.currentUser()!.objectId!, forKey: "userId")
        commentObj.setObject(PFUser.currentUser()!.username!, forKey: "userName")
        commentObj.setObject(projectId, forKey: "projectId")
        commentObj.setObject(commentStr, forKey: "commentStr")
        
        commentObj.saveInBackgroundWithBlock { (succeed, error) -> Void in
            if succeed && error == nil {
                callback(succeed: true, commentData: ProjectCommentData.initWithParseObject(commentObj)!, error: error)
            } else {
                callback(succeed: false, commentData: nil, error: error)
            }
        }
    }
    
    func postCommentImageToProject(projectId: String, commentImage: UIImage, commentStr: String, callback:((succeed: Bool, commentData: ProjectCommentData?, error: NSError?) -> Void)) {
        
        let imageFile = PFFile.init(data: UIImageJPEGRepresentation(commentImage, 0.7)!)
        
        let commentObj = PFObject.init(className: "ProjectComment")
        commentObj.setObject(PFUser.currentUser()!.objectId!, forKey: "userId")
        commentObj.setObject(PFUser.currentUser()!.username!, forKey: "userName")
        commentObj.setObject(projectId, forKey: "projectId")
        commentObj.setObject(imageFile!, forKey: "imageFile")
        commentObj.setObject(commentStr, forKey: "commentStr")
        
        commentObj.saveInBackgroundWithBlock { (succeed, error) -> Void in
            if succeed && error == nil {
                callback(succeed: true, commentData: ProjectCommentData.initWithParseObject(commentObj)!, error: error)
            } else {
                callback(succeed: false, commentData: nil, error: error)
            }
        }
    }
    
    func fetchProjectComments(projectId: String, callback:((comments: [ProjectCommentData], error: NSError?) -> Void)) {
    
        let query = PFQuery.init(className: "ProjectComment")
        query.whereKey("projectId", equalTo: projectId)
        query.orderByDescending("createdAt")
        query.findObjectsInBackgroundWithBlock({ (result, error) -> Void in
            var resultArray = [ProjectCommentData]()
            if error == nil && result != nil {
                for newsObj in result! {
                    resultArray.append(ProjectCommentData.initWithParseObject(newsObj)!)
                }
                callback(comments: resultArray, error: error);
            } else {
                callback(comments: resultArray, error: error)
            }
        })
    }
    
    // MARK: - Notification
    func getHireRequests(callback:((applicants: [ApplicantData], error: NSError?) -> Void)) {
        
        let query = PFQuery.init(className: "Applicant")
        query.whereKey("status", equalTo: EApplicantStatus.Requested.rawValue)
        query.whereKey("userId", equalTo: (PFUser.currentUser()?.objectId)!)
        query.findObjectsInBackgroundWithBlock { (result, error) -> Void in
            if error == nil && result != nil {
                var applicants = [ApplicantData]()
                for item in result! {
                    applicants.append(ApplicantData.initWithParseObject(item)!)
                }
                callback(applicants: applicants, error: error)
            } else {
                callback(applicants: [], error: error)
            }
        }
    }
    
    func getFundingRequests(callback:((projects: [ProjectData], error: NSError?) -> Void)) {
        
        let query = PFQuery.init(className: "Project")
        query.whereKey("status", equalTo: EProjectStatus.WaitingForFunding.rawValue)
        query.whereKey("userId", equalTo: (PFUser.currentUser()?.objectId)!)
        query.findObjectsInBackgroundWithBlock { (result, error) -> Void in
            if error == nil && result != nil {
                var projects = [ProjectData]()
                for item in result! {
                    projects.append(ProjectData.initWithParseObject(item)!)
                }
                callback(projects: projects, error: error)
            } else {
                callback(projects: [], error: error)
            }
        }
    }
    
    func acceptRequestAndHired(applicantId: String, projectId: String, callback:((finished: Bool, error: NSError?) -> Void)) {
        let pointer = PFObject.init(withoutDataWithClassName: "Applicant", objectId: applicantId)
        pointer.fetchIfNeededInBackgroundWithBlock { (applicantObj, error) -> Void in
            if applicantObj == nil {
                callback(finished: false, error: error)
            } else {
                applicantObj?.setObject(EApplicantStatus.Hired.rawValue, forKey: "status")
                applicantObj?.saveInBackgroundWithBlock({ (finished, error) -> Void in
                    self.setProjectStatusTo(projectId, status: EProjectStatus.WaitingForFunding, callback: { (finished, error) -> Void in
                        if error == nil && finished {
                            callback(finished: finished, error: error)
                            
                            
                        } else {
                            // Set Back the status of Applicant (from Hired to Requested) because project status is not updated to InProgress
                            applicantObj?.setObject(EApplicantStatus.Requested.rawValue, forKey: "status")
                            applicantObj?.saveInBackground()
                            
                            callback(finished: finished, error: error)
                        }
                    })
                })
            }
        }
    }
    
    func setInprogressToProject(projectId: String, callback:((finished: Bool, error: NSError?) -> Void)) {
        let pointer = PFObject.init(withoutDataWithClassName: "Project", objectId: projectId)
        pointer.fetchIfNeededInBackgroundWithBlock { (projectObj, error) -> Void in
            if projectObj == nil {
                callback(finished: false, error: error)
            } else {
//                projectObj?.setObject((PFUser.currentUser()?.objectId!)!, forKey: "partnrId")
                projectObj?.setObject(EProjectStatus.InProgress.rawValue, forKey: "status")
                projectObj?.saveInBackgroundWithBlock({ (finished, error) -> Void in
                    // Create News for Partnr
                    self.sharePartnrNews(projectId, callback: { (finished, error) -> Void in
                        if finished && error == nil {
                            NSNotificationCenter.defaultCenter().postNotificationName(kNotiRefreshNewsFeed, object: nil)
                        }
                    })
                    
                    callback(finished: finished, error: error)
                })
            }
        }
    }
    
    func setProjectStatusTo(projectId: String, status: EProjectStatus, callback:((finished: Bool, error: NSError?) -> Void)) {
        let pointer = PFObject.init(withoutDataWithClassName: "Project", objectId: projectId)
        pointer.fetchIfNeededInBackgroundWithBlock { (projectObj, error) -> Void in
            if projectObj == nil {
                callback(finished: false, error: error)
            } else {
                if status == EProjectStatus.WaitingForFunding {
                    projectObj?.setObject((PFUser.currentUser()?.objectId!)!, forKey: "partnrId")
                } else if status == EProjectStatus.Open {
                    projectObj?.setObject("", forKey: "partnrId")
                }
                projectObj?.setObject(status.rawValue, forKey: "status")
                projectObj?.saveInBackgroundWithBlock({ (finished, error) -> Void in
                    callback(finished: finished, error: error)
                })
            }
        }
    }
    
    // MARK: - Rate System
    
    func getLatestRateFromUserId(userId: String, callback:((rate: CGFloat, error: NSError?) -> Void)) {
        let query = PFQuery.init(className: "Rate")
        query.whereKey("toUserId", equalTo: userId)
        query.findObjectsInBackgroundWithBlock { (rateArray, error) -> Void in
            if error == nil && rateArray?.count > 0 {
                var rateSum = Double(0)
                for rate in rateArray! {
                    rateSum += rate["rate"].doubleValue
                }
                callback(rate: CGFloat(rateSum/Double(rateArray!.count)), error: nil)
            } else {
                callback(rate: 0.0, error: error)
            }
        }
    }
    
    func updateRateOfUserId(userId: String) {
        self.getLatestRateFromUserId(userId) { (rate, error) -> Void in
            if error == nil {
                let pointer = PFObject.init(withoutDataWithClassName: "_User", objectId: userId)
                pointer.fetchIfNeededInBackgroundWithBlock({ (userObject, error) -> Void in
                    if userObject as? PFUser == nil {
                        print("Fetch user error!")
                    } else {
                        userObject?.setObject(rate, forKey: "rate")
                        userObject?.saveInBackgroundWithBlock({ (finished, error) -> Void in
                            print("succeed")
                        })
//                        userObject?.saveInBackground()
                    }
                })
            }
        }
    }
    
    
    func rateToUserId(userId: String, isToPartnr: Bool, reviewStr: String, projectId: String, rateStar: NSNumber, callback:((finished: Bool, error: NSError?) -> Void)) {
        
        let rateObject = PFObject.init(className: "Rate")
        rateObject.setObject(userId, forKey: "toUserId")
        rateObject.setObject(PFUser.currentUser()!.objectId!, forKey: "fromUserId")
        rateObject.setObject(projectId, forKey: "projectId")
        rateObject.setObject(reviewStr, forKey: "review")
        rateObject.setObject(rateStar, forKey: "rate")
        rateObject.setObject(isToPartnr, forKey: "isToPartnr")
        
        rateObject.saveInBackgroundWithBlock { (finished, error) -> Void in
            callback(finished: finished, error: error)
        }
    }
    
    func initialRateToUserId(userId: String, rateStar: NSNumber, callback:((finished: Bool, error: NSError?) -> Void)) {
        
        let rateObject = PFObject.init(className: "Rate")
        rateObject.setObject(userId, forKey: "toUserId")
        rateObject.setObject(PFUser.currentUser()!.objectId!, forKey: "fromUserId")
        rateObject.setObject(rateStar, forKey: "rate")
        
        rateObject.saveInBackgroundWithBlock { (finished, error) -> Void in
            callback(finished: finished, error: error)
        }
    }
    
    func getRateDataFromPartnrId(userId: String, projectId: String, callback:((rateObj: PFObject?, error: NSError?) -> Void)) {
        let query = PFQuery.init(className: "Rate")
        query.whereKey("fromUserId", equalTo: userId)
        query.whereKey("projectId", equalTo: projectId)
        
        query.findObjectsInBackgroundWithBlock { (rateArray, error) -> Void in
            if error == nil && rateArray?.count > 0 {
                callback(rateObj: rateArray![0], error: error)
            } else {
                callback(rateObj: nil, error: error)
            }
        }
    }
    
    // Availability
    func updateAvailable(isAvailable: Bool, callback:((success: Bool?, error: NSError?) -> Void)) {
        PFUser.currentUser()?.setObject(isAvailable, forKey: "isAvailable")
        PFUser.currentUser()?.saveInBackgroundWithBlock({ (success, error) -> Void in
            callback(success: success, error: error)
        })
    }
}

extension String {
    

    func stringByAddingPercentEncodingForURLQueryValue() -> String? {
        let characterSet = NSMutableCharacterSet.alphanumericCharacterSet()
        characterSet.addCharactersInString("-._~")
        
        return self.stringByAddingPercentEncodingWithAllowedCharacters(characterSet)
    }
    
}

extension NSMutableDictionary {

    
    func stringFromHttpParameters() -> String {
        let parameterArray = self.map { (key, value) -> String in
            let percentEscapedKey = (key as! String).stringByAddingPercentEncodingForURLQueryValue()!
            let percentEscapedValue = (value as! String).stringByAddingPercentEncodingForURLQueryValue()!
            return "\(percentEscapedKey):\(percentEscapedValue);"
        }
        
        return parameterArray.joinWithSeparator("")
    }
    
}

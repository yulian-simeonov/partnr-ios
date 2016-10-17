//
//  NewsData.swift
//  Partnr
//
//  Created by Yosemite on 2/5/16.
//  Copyright © 2016 YulianMobile. All rights reserved.
//

import UIKit
import Parse

class NewsData: CommunityData {

    var type: ENewsType = .Photo
    
    var id: String = ""
    var userId: String = ""
    var userName: String = ""
    var likeCount = 0
    var commentCount = 0
    var caption: String = ""

//    var createdAt = NSDate()
    
    var userData: UserData? = nil

    // Photo News
    var photoFile: PFFile? = nil
    var photoSize: CGSize = CGSizeMake(0, 0)
    var tags: NSArray = []
    var comments: NSArray = []
    var photoLabel: EPhotoLabel = .WorkInProgress
    
    var noteLabel: ENoteLabel = .Note
    
    // Partnr News
    var projectId: String = ""
    var projectData: ProjectData? = nil
    var partnrUserData: UserData? = nil
    
    var isCommentUpdated: Bool = false
    var isLikeUpdated: Bool = false
    var isLiked: Bool = false

    class func initWithParseObject(parseObj: PFObject?) -> NewsData? {
        
        if (parseObj == nil) {
            return nil
        }
        
        let news = NewsData()
        let newsType = ENewsType(rawValue: parseObj!["type"].integerValue)
        
        news?.communityType = .News
        news!.type = newsType!
        news!.id = parseObj!.objectId!
        news!.userId = Utilities.getValidString(parseObj!["userId"] as? String, defaultString: "")
        news!.userName = Utilities.getValidString(parseObj!["userName"] as? String, defaultString: "")
        news!.createdAt = parseObj!.createdAt!
        
        if newsType == .Photo {
            news!.caption = Utilities.getValidString(parseObj!["caption"] as? String, defaultString: "")
            let tags = Utilities.getValidString(parseObj!["tags"] as? String, defaultString: "")
            news!.tags = tags.isEmpty ? [] : tags.componentsSeparatedByString(",")
            news!.photoFile = parseObj!["photoFile"] as? PFFile
            
            let label = parseObj!["label"] == nil ? 0 : parseObj!["label"] as! NSNumber
            news!.photoLabel = EPhotoLabel(rawValue: label.integerValue)!
            
            news!.photoSize = CGSizeMake(CGFloat(parseObj!["photoWidth"] as! NSNumber), CGFloat(parseObj!["photoHeight"] as! NSNumber))
        } else if newsType == .Partnr {
            news!.projectId = Utilities.getValidString(parseObj!["projectId"] as? String, defaultString: "")
        } else if newsType == .Note {
            news!.caption = Utilities.getValidString(parseObj!["caption"] as? String, defaultString: "")
            
            let label = parseObj!["label"] == nil ? 0  : parseObj!["label"] as! NSNumber
            news!.noteLabel = ENoteLabel(rawValue: label.integerValue)!
        } else if newsType == .People {
            news!.caption = Utilities.getValidString(parseObj!["caption"] as? String, defaultString: "")
        } else if newsType == .Community {
            news!.caption = Utilities.getValidString(parseObj!["caption"] as? String, defaultString: "")
        }
        
        return news
    }
    
    func updateUserDataWithCallback(callback:((userData: UserData?, error: NSError?) -> Void)) {
        
        if userData == nil && !userId.isEmpty {
            
            PNAPIClient.sharedInstance.fetchUser(PFUser.init(withoutDataWithClassName: "_User", objectId: userId), callback: { (userData, error) -> Void in
                if error == nil && userData != nil {
                    self.userData = userData
                    callback(userData: self.userData, error: error)
                }
            })
        }
    }
    
    func updateCommentInfoWithCallback(callback:((commentCount: Int) -> Void)) {
        
        if !isCommentUpdated && !self.id.isEmpty {
            PNAPIClient.sharedInstance.fetchCommentInfo(self.id) { (succeed, nsData, error) -> Void in
                if succeed {
                    if nsData as? NSArray != nil {
                        self.commentCount = nsData!.count
                        self.isCommentUpdated = true
                        self.comments = nsData as! NSArray
                        callback(commentCount: nsData!.count)
                    }
                }
            }
        }
    }

    func updateLikeInfoWithCallback(callback:((likeCount: Int, isLiked: Bool) -> Void)) {
        
        if !isLikeUpdated && !self.id.isEmpty {
            PNAPIClient.sharedInstance.fetchLikeInfo(self.id) { (succeed, nsData, isLiked, error) -> Void in
                if succeed {
                    if nsData as? NSArray != nil {
                        self.likeCount = nsData!.count
                        self.isLikeUpdated = true
                        callback(likeCount: nsData!.count, isLiked: isLiked)
                    }
                } else {
                    self.likeCount = 0
                    self.isLikeUpdated = false
                }
            }
        }
    }
    
//    override init?() {
//        self.id = ""
//        self.photoSize = CGSizeMake(0, 0)
//    }
}

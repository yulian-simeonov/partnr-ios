//
//  Macro.swift
//  flipcast
//
//  Created by Yosemite on 10/9/15.
//  Copyright © 2015 YulianMobile. All rights reserved.
//

import Foundation
import UIKit

let APPDELGATE = UIApplication.sharedApplication().delegate as! AppDelegate

let IS_IPHONE4 = fabs(UIScreen.mainScreen().bounds.size.height-480) < 1
let IS_IPHONE5 = fabs(UIScreen.mainScreen().bounds.size.height-568) < 1
let SCRN_WIDTH = UIScreen.mainScreen().bounds.size.width
let SCRN_HEIGHT = UIScreen.mainScreen().bounds.size.height

let NAV_COLOR = UIColor.init(red: 255/255.0, green: 186/255.0, blue: 0/255.0, alpha: 1.0)
let MAIN_COLOR = UIColor.init(red: 0/255.0, green: 178/255.0, blue: 116/255.0, alpha: 1.0)
let GRAY_COLOR_3 = UIColor.init(red: 88/255.0, green: 88/255.0, blue: 89/255.0, alpha: 1.0)
let GRAY_COLOR_4 = UIColor.init(red: 155/255.0, green: 155/255.0, blue: 155/255.0, alpha: 1.0)
let GRAY_COLOR_5 = UIColor.init(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1.0)
let GRAY_COLOR_6 = UIColor.init(red: 227/255.0, green: 227/255.0, blue: 229/255.0, alpha: 1.0)
let GRAY_COLOR_7 = UIColor.init(red: 250/255.0, green: 250/255.0, blue: 250/255.0, alpha: 1.0)
let RED_COLOR = UIColor.init(red: 251/255.0, green: 114/255.0, blue: 133/255.0, alpha: 1.0)
let GREEN_COLOR = UIColor.init(red: 26/255.0, green: 198/255.0, blue: 93/255.0, alpha: 1.0)
let GRAY_COLOR = UIColor.init(red: 239/255.0, green: 239/255.0, blue: 244/255.0, alpha: 1.0)
let YELLOW_COLOR = UIColor.init(red: 245/255.0, green: 242/255.0, blue: 238/255.0, alpha: 1.0)

let LIGHTBLUE_COLOR = UIColor.init(red: 23/255.0, green: 165/255.0, blue: 179/255.0, alpha: 1.0)
let NAVY_COLOR = UIColor.init(red: 242/255.0, green: 117/255.0, blue: 34/255.0, alpha: 1.0)
let PINK_COLOR = UIColor.init(red: 234/255.0, green: 0/255.0, blue: 141/255.0, alpha: 1.0)

let kTitle_APP = "Partnr"

let parse_app_id = "kXoqZokp9E4JBNwmSqjNK80zECPLEyZDfgbtvvCQ"
let parse_client_key = "kVkhnc6qt4lIRPnE9kmePOuWK3EwQDlOC1ZKSH3R"

let PROJECT_TYPES = ["Design", "Writer", "Fine Artist", "Videographer", "Photography"]
let PHOTO_LABELS = ["Work In Progress", "Final Piece", "Inspiration"]
let NOTE_LABELS = ["Note", "Resource"]
let PROF_LIST = ["Designer", "Writer", "Photographer", "Videographer", "Video Editor", "Illustrator", "Animator/Motion Artist", "UX/UI Designer", "Painter", "Fine Artist", "Full-stack Developer", "Web/Front-end Developer", "Back-end Developer", "Maker", "Interior Designer", "Creative Director", "Content Producer", "Small Business/Organization", "Editorial Website", "Company", "Entrepreneur", "Other"]


// --------------------------- Web service API ---------------------------- //

let FACEBOOK_URL = "http://graph.facebook.com/%@/picture"
let SERVER_AUTH_URL =  ""
let SERVER_API_URL =  ""
let BRAINTREE_SERVER_URL = "http://88.80.131.137:3000"

// Time format
let genericTimeFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss"
let hoursTimeFormat = "hh:mm a"
// --------------------------------------------------------------------------- //

// Feed
let kFeedLimit = 3

// Label 
enum EPhotoLabel: Int {
    case WorkInProgress = 0
    case FinalPiece
    case Inspiration
}

enum ENoteLabel: Int {
    case Note = 0
    case Resource
}

// Community Type
enum ECommunityType: Int {
    case News = 0
    case Project
}

// News Type
enum ENewsType: Int {
    case Photo = 0
    case Partnr
    case People
    case Note
    case Payday
    case Community
}

// Project Status
enum EProjectStatus: Int {
    case Open = 0
    case Pending
    case WaitingForFunding
    case InProgress
    case PartnrCompleted
    case Completed
    case PartnrRequested
    case PartnrAccepted
}

// Applicant Status
enum EApplicantStatus: Int {
    case None = 0
    case Requested
    case Declined
    case Hired
}

// Language Code
enum ELangCode: Int {
    case English = 0
    case France
}

enum EDialogType: Int {
    case SharePhoto = 0
    case ChooseProjectType
    case Congratulation
    case ConfirmAlert
    case ShareNote
    case FindPartnr
}

// User Type
enum EUserType: Int {
    case Follower = 0
    case Following
    case Partnr
}

// Transition Mode
enum TransitionMode: Int {
    case transitionBottomToTop = 0
    case transitionTopToBottom // 1
}

// Notification
let kNotiRefreshNewsFeed = "NotiRefreshNewsFeed"
let kNotiRefreshProjectsFeed = "NotiRefreshProjectsFeed"
let kNotiRefreshSideMenu = "Noti:SideMenuRefresh"
let kNotiSearchUser = "NotiSearchUser"

// Storyboard Identifier
let kWelcomeNC = "WelcomeNC"

// Page Navigation Identifier
let kShowTutorial = "ShowTutorial"
let kShowTabbar = "ShowTabbar"
let kShowWelcome = "ShowWelcome"
let kShowWelcomeWithAnimation = "ShowWelcomeWithAnimation"
let kShowSignupStepVC = "ShowSignupStepVC"

// Message
let kHireMeConfirmMessage = "One step closer. By applying to this project you give the project admin permission to shoot you an e-mail in order to get to know you better before bringing you on. Are you sure you want to apply?"
//
//  PNRoundedShadowView.swift
//  Partnr
//
//  Created by Yosemite on 2/20/16.
//  Copyright © 2016 YulianMobile. All rights reserved.
//

import UIKit

import ParseUI

@IBDesignable
public class PNRoundedShadowView: PFImageView {
    
    @IBInspectable public var cornerRadius: CGFloat = 5 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable public var shadowOffset: CGFloat = 3 {
        didSet {
            self.layer.shadowColor = UIColor.blackColor().CGColor
            self.layer.shadowRadius = 2.0
            self.layer.shadowOpacity = 0.6
            self.layer.shadowOffset = CGSizeMake(0.0, shadowOffset)
        }
    }

    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
//    override public func drawRect(rect: CGRect) {
//        // Drawing code
//    }

}

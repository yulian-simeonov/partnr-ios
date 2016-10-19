//
//  PNStarPointView.swift
//  Partnr
//
//  Created by Yulian Simeonov on 2/20/16.
//  Copyright © 2016 YulianMobile. All rights reserved.
//

import UIKit

public class PNStarPointView: UIView {

    var star1: UIButton!
    var star2: UIButton!
    var star3: UIButton!
    var star4: UIButton!
    var star5: UIButton!
    
    var markLabel: UILabel!
    
    @IBInspectable public var rateMark: CGFloat = 5 {
        didSet {
            if markLabel == nil {
                self.addMarkLabel()
            }
            if star1 == nil {
                self.addStarButtons()
            }

            rateMark = rateMark < 0 ? 0 : rateMark
            markLabel.text = "\(rateMark)"

            for i in 0...Int(rateMark)-1 {
                [star1, star2, star3, star4, star5][i].selected = true
            }
        }
    }
    
    @IBInspectable public var isPoint: Bool = false {
        didSet {
            
        }
    }
    
    func makeStarButton(index: Int) -> UIButton {
        let button = UIButton.init(frame: CGRectMake(16*CGFloat(index), (self.frame.size.height-13)/2, 14, 13))
        button.setImage(UIImage.init(named: isPoint == true ? "star-white" : "ico-star"), forState: .Normal)
        button.setImage(UIImage.init(named: isPoint == true ? "star-white-h" : "ico-star-h"), forState: .Selected)
        return button
    }
    
    func addMarkLabel() {

        markLabel = UILabel.init(frame: CGRectMake(16*5.0, (self.frame.size.height-13)/2, 50, 13))
        markLabel.backgroundColor = UIColor.clearColor()
        markLabel.textColor = UIColor.darkGrayColor()
        
        self.addSubview(markLabel)
    }
    
    func addStarButtons() {
        star1 = self.makeStarButton(0)
        star2 = self.makeStarButton(1)
        star3 = self.makeStarButton(2)
        star4 = self.makeStarButton(3)
        star5 = self.makeStarButton(4)
        
        
        self.addSubview(star1)
        self.addSubview(star2)
        self.addSubview(star3)
        self.addSubview(star4)
        self.addSubview(star5)
    }
    
    public override func awakeFromNib() {

        if star1 == nil {
            self.addStarButtons()
        }
        
        if markLabel == nil {
            self.addMarkLabel()
        }
        
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}

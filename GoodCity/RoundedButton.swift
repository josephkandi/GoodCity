//
//  RoundedButton.swift
//  GoodCity
//
//  Created by Yili Aiwazian on 10/12/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

class RoundedButton: UIButton {

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.backgroundColor = UIColor(white: 0.8, alpha: 1.0).CGColor
        self.layer.cornerRadius = frame.height/2
        self.layer.masksToBounds = true
        
        let attributedTitle = NSMutableAttributedString(string: self.titleLabel!.text!)
        let range = NSMakeRange(0, attributedTitle.length)
        attributedTitle.addAttribute(NSFontAttributeName, value: FONT_MEDIUM_14, range: range)
        attributedTitle.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: range)
        self.setAttributedTitle(attributedTitle, forState: .Normal)
    }
    
    func setButtonTitle(text: String) {
        let attributedTitle = NSMutableAttributedString(string: text)
        let range = NSMakeRange(0, attributedTitle.length)
        attributedTitle.addAttribute(NSFontAttributeName, value: FONT_BOLD_14, range: range)
        attributedTitle.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: range)
        self.setAttributedTitle(attributedTitle, forState: .Normal)
    }
    
}

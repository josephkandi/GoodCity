//
//  RoundedButton.swift
//  GoodCity
//
//  Created by Yili Aiwazian on 10/12/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

class RoundedButton: UIButton {

    // 0: Solid style
    // 1: Bordered style
    var style = 0
    var color = UIColor(white: 0.8, alpha: 1.0)
    var text = ""
    
    override init() {
        super.init()
        setup()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    func setup() {
        self.layer.backgroundColor = color.CGColor
        self.layer.cornerRadius = frame.height/2
        self.layer.masksToBounds = true
        
        if (self.titleLabel!.text != nil) {
            let attributedTitle = NSMutableAttributedString(string: self.titleLabel!.text!)
            let range = NSMakeRange(0, attributedTitle.length)
            attributedTitle.addAttribute(NSFontAttributeName, value: FONT_MEDIUM_14!, range: range)
            attributedTitle.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: range)
            self.setAttributedTitle(attributedTitle, forState: .Normal)
        }
    }
    func setButtonTitle(text: String) {
        let textColor = style == 0 ? UIColor.whiteColor() : color
        let attributedTitle = NSMutableAttributedString(string: text)
        let range = NSMakeRange(0, attributedTitle.length)
        attributedTitle.addAttribute(NSFontAttributeName, value: FONT_MEDIUM_14!, range: range)
        attributedTitle.addAttribute(NSForegroundColorAttributeName, value: textColor, range: range)
        self.setAttributedTitle(attributedTitle, forState: .Normal)
        
        self.text = text
    }
    func setButtonColor(color: UIColor) {
        self.layer.backgroundColor = color.CGColor
        self.color = color
    }
    // 0: Solid style
    // 1: Bordered style
    func setButtonSytle(style: Int) {
        if style == 0 {
            self.layer.backgroundColor = UIColor(white: 0.8, alpha: 1.0).CGColor
        }
        else {
            self.layer.borderColor = color.CGColor
            self.layer.borderWidth = 2
            self.layer.backgroundColor = UIColor.clearColor().CGColor
            setButtonTitle(self.text)
        }
        self.style = style
    }
    
    
}

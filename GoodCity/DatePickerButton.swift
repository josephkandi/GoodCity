//
//  DatePickerButton.swift
//  GoodCity
//
//  Created by Yili Aiwazian on 10/12/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

let BUTTON_INSET = CGFloat(12)
let ICON_SIZE = CGFloat(15)

class DatePickerButton: UIButton {
    
    private var dropdownIcon : UIImageView!
    var datePicked : NSDate! {
        didSet(oldDateOrNil) {
            if let newDate = datePicked {
                let dateString = getFriendlyDateFormatter().stringFromDate(newDate)
                self.setAttributedTitle(formatTitle(dateString), forState: .Normal)
            }
        }
    }

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
        self.layer.backgroundColor = UIColor.whiteColor().CGColor
        self.layer.cornerRadius = ROUNDED_CORNER
        self.layer.masksToBounds = true
        
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        self.contentEdgeInsets = UIEdgeInsetsMake(0, BUTTON_INSET, 0, 0)
        
        // setup the dropdown icon
        dropdownIcon = UIImageView(image: UIImage(named: "schedule_dropdown")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate))
        dropdownIcon.tintColor = UIColor.lightGrayColor()
        dropdownIcon.contentMode = UIViewContentMode.ScaleAspectFill
        self.addSubview(dropdownIcon)
        
        self.titleLabel!.text = ""
        self.setAttributedTitle(formatTitle(self.titleLabel!.text!), forState: .Normal)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = self.bounds
        dropdownIcon.frame = CGRectMake(bounds.width-BUTTON_INSET-ICON_SIZE, (bounds.height-ICON_SIZE)/2, ICON_SIZE, ICON_SIZE)
    }
        
    func setButtonTitle(text: String) {
        self.setAttributedTitle(formatTitle(text), forState: .Normal)
    }
    func setButtonColor(color: UIColor) {
        self.layer.backgroundColor = color.CGColor
    }
    
    func formatTitle(text: String) -> NSMutableAttributedString {
        let attributedTitle = NSMutableAttributedString(string: text)
        let range = NSMakeRange(0, attributedTitle.length)
        attributedTitle.addAttribute(NSFontAttributeName, value: FONT_15!, range: range)
        attributedTitle.addAttribute(NSForegroundColorAttributeName, value: UIColor.darkTextColor(), range: range)
        return attributedTitle
    }
}
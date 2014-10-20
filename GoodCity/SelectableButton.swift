//
//  SelectableButton.swift
//  GoodCity
//
//  Created by Yili Aiwazian on 10/20/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

class SelectableButton: UIButton {

    private var dropdownIcon : UIImageView!
    var slotHour : Int! {
        didSet(oldDateOrNil) {
            if let newSlot = slotHour {
                let dateString = getSlotTitle(newSlot)
                self.setAttributedTitle(formatTitle(dateString), forState: .Normal)
            }
        }
    }
    var slotSelected : Bool! {
        didSet (oldValue) {
            if let newValue = slotSelected {
                if newValue {
                    formatSelectedButton()
                }
                else {
                    formatAvailableButton()
                }
            }
        }
    }
    var slotDisabled : Bool! {
        didSet (oldValue) {
            if let newValue = slotDisabled {
                if newValue {
                    formatDisabledButton()
                }
                else {
                    slotSelected = false
                }
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
        
        self.titleLabel!.text = ""
        //self.setAttributedTitle(formatTitle(self.titleLabel!.text!), forState: .Normal)
        self.slotDisabled = true
    }
    
    func setButtonTitle(text: String) {
        self.setAttributedTitle(formatTitle(text), forState: .Normal)
    }
    func setButtonColor(color: UIColor) {
        self.layer.backgroundColor = color.CGColor
    }
    func formatTitle(text: String, color: UIColor) -> NSMutableAttributedString {
        let attributedTitle = NSMutableAttributedString(string: text)
        let range = NSMakeRange(0, attributedTitle.length)
        attributedTitle.addAttribute(NSFontAttributeName, value: FONT_15, range: range)
        attributedTitle.addAttribute(NSForegroundColorAttributeName, value: color, range: range)
        return attributedTitle
    }
    func formatTitle(text: String) -> NSMutableAttributedString {
        return formatTitle(text, color: UIColor.darkTextColor())
    }
    
    func getSlotTitle(hour: Int) -> String {        
        return get12hour(hour) + " - " + get12hour(hour+1)
    }
    
    private func formatDisabledButton() {
        let text = self.titleLabel?.text
        self.setAttributedTitle(formatTitle(text!, color: UIColor(white: 0.8, alpha: 1)), forState: .Normal)
        setButtonColor(UIColor(white: 0.9, alpha: 1))
    }
    private func formatSelectedButton() {
        let text = self.titleLabel?.text
        self.setAttributedTitle(formatTitle(text!,color:  UIColor.whiteColor()), forState: .Normal)
        setButtonColor(tintColor!)
    }
    private func formatAvailableButton() {
        let text = self.titleLabel?.text
        self.setAttributedTitle(formatTitle(text!,color:  UIColor.darkTextColor()), forState: .Normal)
        setButtonColor(UIColor.whiteColor())
    }
    private func get12hour(hour: Int) -> String {
        var string = ""
        
        if hour <= 12 {
            string += String(hour)
        }
        else {
            string += String(hour-12)
        }
        if hour < 12 {
            string += "am"
        }
        else {
            string += "pm"
        }
        return string
    }
}

//
//  EditItemView.swift
//  GoodCity
//
//  Created by Nick Aiwazian on 10/17/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

private let marginTopBottom: CGFloat = 30
private let marginLeftRight: CGFloat = 20
private let gapMargin: CGFloat = 24

class EditItemView: UIView, UITextViewDelegate {

    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!

    @IBOutlet weak var fieldsContainerView: UIView!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var line: UIView!
    @IBOutlet weak var conditionChooser: YASegmentedControl!

    @IBOutlet weak var blurView: UIVisualEffectView!

    var delegate: CameraViewDelegate?
    var photo: UIImage?
    var itemDescription = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        // Set up the text compose field
        descriptionText.delegate = self
        descriptionText.textAlignment = .Center
        formatTextView(false)

        line.backgroundColor = UIColor(white: 0.1, alpha: 0.6)
        fieldsContainerView.backgroundColor = UIColor.clearColor()
    }
    
    @IBAction func onTap(sender: UITapGestureRecognizer) {
        if descriptionText.isFirstResponder() {
            dismissKeyboard()
        }
    }
    
    @IBAction func onTapClose(sender: AnyObject) {
        delegate?.dismissEditItem()
    }
    
    @IBAction func onTapSubmit(sender: AnyObject) {
        if !submitButton.enabled {
            return
        }
        
        var condition: String
        switch conditionChooser.selectedSegmentIndex {
        case 0: condition = "New"
        case 1: condition = "Lightly Used"
        case 2: condition = "Heavily Used"
        default: condition = ""
        }
        
        let newItem = DonationItem.newItem(descriptionText.text, photo: photo!, condition: condition)
        delegate?.submitItem(newItem)
    }
    
    override func layoutSubviews() {
        
        if descriptionText.isFirstResponder() {
            blurView.frame = CGRectMake(0, 0, self.frame.width, self.frame.height)
            fieldsContainerView.frame = blurView.frame
            descriptionText.frame = CGRectMake(marginLeftRight, 100, self.frame.width - 2 * marginLeftRight, 300)
            
            // Hiding everything except for the text field and the blurview
            line.alpha = 0
            conditionChooser.alpha = 0
            closeButton.alpha = 0
            submitButton.alpha = 0
        }
        else {
            var yOffset = marginTopBottom
            descriptionText.frame = CGRectMake(marginLeftRight, yOffset, blurView.frame.width-marginLeftRight*2, descriptionText.frame.height)
            descriptionText.sizeToFit()
            descriptionText.frame = CGRectMake(marginLeftRight, yOffset, blurView.frame.width-marginLeftRight*2, descriptionText.frame.height)
            
            yOffset += descriptionText.frame.height 
            line.frame = CGRectMake(marginLeftRight*1.5,yOffset, blurView.frame.width-marginLeftRight*3, 2)
            
            yOffset += gapMargin + line.frame.height
            conditionChooser.frame = CGRectMake(marginLeftRight,yOffset, blurView.frame.width-marginLeftRight*2, 50)
            
            yOffset += conditionChooser.frame.height + marginTopBottom
            blurView.frame = CGRectMake(0, self.frame.height - yOffset, self.frame.width, yOffset)
            fieldsContainerView.frame = blurView.frame
            
            // Showing everything again
            closeButton.alpha = 1
            submitButton.alpha = 1
            line.alpha = 1
            conditionChooser.alpha = 1
        }
    }
    
    private func formatTextView(active: Bool) {
        descriptionText.textColor = UIColor.darkTextColor()
        descriptionText.sizeToFit()
        if !active {
            descriptionText.alpha = 0.5
            descriptionText.font = FONT_MEDIUM_14
        }
        else {
            descriptionText.font = FONT_MEDIUM_20
        }
        
        if itemDescription == "" && !active {
            showPlaceholderText()
            submitButton.setImage(UIImage(named: "edit_submit_disabled"), forState: .Normal)
            submitButton.enabled = false
        }
        else {
            descriptionText.text = itemDescription
            submitButton.setImage(UIImage(named: "edit_submit"), forState: .Normal)
            submitButton.enabled = true
        }
    }
    func dismissKeyboard() {
        itemDescription = descriptionText.text
        formatTextView(false)
        descriptionText.resignFirstResponder()
        layoutSubviews()
    }

    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n" {
            dismissKeyboard()
            return false
        }
        return true
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        
        formatTextView(true)
        descriptionText.becomeFirstResponder()
        layoutSubviews()
    }
    
    private func showPlaceholderText() {
        descriptionText.text = "What is it? How many items are there?\nHow big is it?"
    }

}

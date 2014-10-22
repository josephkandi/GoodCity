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
private let gapMargin: CGFloat = 20

class EditItemView: UIView, UITextViewDelegate {

    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var line: UIView!
    @IBOutlet weak var conditionChooser: YASegmentedControl!
    
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    var delegate: CameraViewDelegate?
    var photo: UIImage?

    var itemDescription = ""
    
    @IBOutlet weak var blurView: UIVisualEffectView!

    
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

        line.backgroundColor = UIColor(white: 0.1, alpha: 0.7)
    }
    
    @IBAction func onTap(sender: UITapGestureRecognizer) {
        descriptionText.resignFirstResponder()
    }
    
    @IBAction func onTapClose(sender: AnyObject) {
        delegate?.dismissEditItem()
    }
    
    @IBAction func onTapSubmit(sender: AnyObject) {
        
        let newItem = DonationItem.newItem(descriptionText.text, photo: photo!, condition: conditionChooser.titleForSegmentAtIndex(conditionChooser.selectedSegmentIndex))
        
        delegate?.submitItem(newItem)
    }
    
    override func layoutSubviews() {
        
        if descriptionText.isFirstResponder() {
            blurView.frame = CGRectMake(0, 0, self.frame.width, self.frame.height-200)
            descriptionText.frame = CGRectMake(marginLeftRight, blurView.frame.height/2-descriptionText.frame.height, blurView.frame.width - 2 * marginLeftRight, descriptionText.frame.height)
            line.alpha = 0
            conditionChooser.alpha = 0
            closeButton.alpha = 0
            submitButton.alpha = 0
            blurView.alpha = 1
        }
        else {
            var yOffset = marginTopBottom
            descriptionText.sizeToFit()
            descriptionText.frame = CGRectMake(marginLeftRight, yOffset, blurView.frame.width-marginLeftRight*2, descriptionText.frame.height)
            
            yOffset += descriptionText.frame.height + 5
            line.frame = CGRectMake(marginLeftRight,yOffset, blurView.frame.width-marginLeftRight*2, 2)
            
            yOffset += gapMargin + line.frame.height
            conditionChooser.frame = CGRectMake(marginLeftRight,yOffset, blurView.frame.width-marginLeftRight*2, 50)
            
            yOffset += conditionChooser.frame.height + marginTopBottom
            blurView.frame = CGRectMake(0, self.frame.height - yOffset, self.frame.width, yOffset)
            
            blurView.alpha = 0.7
            closeButton.alpha = 1
            submitButton.alpha = 1
            line.alpha = 1
            conditionChooser.alpha = 1
        }
        

    }
    
    private func formatTextView(active: Bool) {
        descriptionText.sizeToFit()
        if !active {
            descriptionText.textColor = offWhiteColor
            descriptionText.alpha = 0.5
            descriptionText.font = FONT_MEDIUM_14
        }
        else {
            descriptionText.font = FONT_MEDIUM_20
            descriptionText.textColor = UIColor.whiteColor()
        }
        
        if itemDescription == "" && !active {
            showPlaceholderText()
        }
        else {
            descriptionText.text = itemDescription
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

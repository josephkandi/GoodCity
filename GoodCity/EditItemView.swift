//
//  EditItemView.swift
//  GoodCity
//
//  Created by Nick Aiwazian on 10/17/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

class EditItemView: UIView, UITextViewDelegate {

    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var line: UIView!

    @IBOutlet weak var conditionChooser: YASegmentedControl!
    
    var delegate: CameraViewDelegate?
    var photo: UIImage?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        // Set up the text compose field
        descriptionText.delegate = self

        line.backgroundColor = UIColor(white: 0.1, alpha: 0.7)
        descriptionText.textColor = offWhiteColor
        descriptionText.alpha = 0.5
        descriptionText.font = FONT_MEDIUM_14
        descriptionText.textAlignment = .Center
        descriptionText.text = "What is it? How many items are there?\nHow big is it?"
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
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        descriptionText.becomeFirstResponder()
        descriptionText.textColor = UIColor.whiteColor()
        descriptionText.text = ""
    }

}

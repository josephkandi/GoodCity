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
    @IBOutlet weak var submitButton: RoundedButton!
    @IBOutlet weak var conditionChooser: UISegmentedControl!

    var delegate: CameraViewDelegate?
    var photo: UIImage?

    override init(frame: CGRect) {
        super.init(frame: frame)
        println("hello from init frame")
        let textViewFrame = CGRectMake(100, 100, 100, 100)
        let textView = UITextView(frame: textViewFrame)

        textView.backgroundColor = UIColor.clearColor()
        textView.text = "HELLO there"
        addSubview(textView)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    @IBAction func onTap(sender: UITapGestureRecognizer) {
        descriptionText.resignFirstResponder()
    }
    
    @IBAction func onTapClose(sender: UITapGestureRecognizer) {
        delegate?.dismissEditItem()
    }

    @IBAction func onTapSubmit(sender: AnyObject) {
        
        let newItem = DonationItem.newItem(descriptionText.text, photo: photo!, condition: conditionChooser.titleForSegmentAtIndex(conditionChooser.selectedSegmentIndex)!)
        
        delegate?.submitItem(newItem)
    }
    
    override func layoutSubviews() {
        // Set up the text compose field
        descriptionText.delegate = self
        descriptionText.textColor = UIColor.lightTextColor()

        submitButton.setButtonColor(tintColor)
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        descriptionText.becomeFirstResponder()
        descriptionText.textColor = UIColor.whiteColor()
        descriptionText.text = ""
    }

}

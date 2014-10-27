//
//  EditAddressView.swift
//  GoodCity
//
//  Created by Yili Aiwazian on 10/26/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit
import QuartzCore

private let marginTopBottom: CGFloat = 20
private let marginLeftRight: CGFloat = 15
private let gapMargin: CGFloat = 24
private let fieldHeight: CGFloat = 40

protocol EditAddressViewDelegate {
    func onTapDone()
}
class EditAddressView: UIView, UITextFieldDelegate {

    var viewTitleLabel: UILabel!
    var explanationLabel: UILabel!
    var fieldsContainerView: UIView!
    var addressLine1: UITextField!
    var addressLine2: UITextField!
    var city: UITextField!
    var state: UITextField!
    var zipcode: UITextField!
    var doneButton: RoundedButton!
    var tapGesture: UITapGestureRecognizer!
    var delegate: EditAddressViewDelegate?
    
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
        viewTitleLabel = UILabel()
        viewTitleLabel.text = "Enter Pickup Address"
        viewTitleLabel.font = FONT_MEDIUM_17
        viewTitleLabel.textAlignment = .Center
        
        explanationLabel = UILabel()
        explanationLabel.numberOfLines = 0
        explanationLabel.text = "Since this is your first time scheduling a pickup, please enter your address."
        explanationLabel.textAlignment = .Left
        explanationLabel.font = FONT_14
        
        tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: "dismissKeyboard")
        self.addGestureRecognizer(tapGesture)
        
        fieldsContainerView = UIView(frame: CGRectZero)
        fieldsContainerView.layer.cornerRadius = 4
        fieldsContainerView.layer.masksToBounds = true
        fieldsContainerView.layer.borderColor = UIColor.grayColor().CGColor
        fieldsContainerView.layer.borderWidth = 1
        
        addressLine1 = UITextField(frame: CGRectZero)
        addressLine2 = UITextField(frame: CGRectZero)
        city = UITextField(frame: CGRectZero)
        state = UITextField(frame: CGRectZero)
        zipcode = UITextField(frame: CGRectZero)
        
        setupTextField(addressLine1, placeholder: "Street")
        setupTextField(addressLine2, placeholder: "Apt/Suite (optional)")
        setupTextField(city, placeholder: "City")
        setupTextField(state, placeholder: "State")
        setupTextField(zipcode, placeholder: "Zip Code")
        zipcode.keyboardType = UIKeyboardType.NumberPad
        
        doneButton = RoundedButton(frame: CGRectMake(0, 0, 180, 40))
        doneButton.setButtonColor(BLUE_TEAL)
        doneButton.setButtonTitle("Next")
        doneButton.addTarget(self, action: "onTapDoneButton", forControlEvents: UIControlEvents.TouchUpInside)
        
        city.text = "San Francisco"
        state.text = "CA"
        
        self.addSubview(viewTitleLabel)
        self.addSubview(explanationLabel)
        self.addSubview(fieldsContainerView)
        fieldsContainerView.addSubview(addressLine1)
        fieldsContainerView.addSubview(addressLine2)
        fieldsContainerView.addSubview(city)
        fieldsContainerView.addSubview(state)
        fieldsContainerView.addSubview(zipcode)
        self.addSubview(doneButton)
    }
    
    func setupTextField(textField: UITextField, placeholder: String) {
        //textField.borderStyle = UITextBorderStyle.Line
        textField.placeholder = placeholder
        textField.font = FONT_14
        textField.layer.borderColor = UIColor.grayColor().CGColor
        textField.layer.borderWidth = 1.0
        
        let spacerView = UIView(frame: CGRectMake(0, 0, 10, 10))
        textField.leftViewMode = UITextFieldViewMode.Always
        textField.leftView = spacerView
        
        textField.returnKeyType = UIReturnKeyType.Next
        textField.delegate = self
    }
    
    override func layoutSubviews() {
        let bounds = self.bounds
        
        var yOffset = marginTopBottom
        viewTitleLabel.frame = CGRectMake(marginLeftRight, yOffset, bounds.width - marginLeftRight*2, fieldHeight)
        
        yOffset += viewTitleLabel.frame.height + TEXT_MARGIN
        explanationLabel.frame = CGRectMake(marginLeftRight, yOffset, bounds.width - marginLeftRight*2, fieldHeight)
        explanationLabel.sizeToFit()
        
        yOffset += explanationLabel.frame.height + gapMargin
        fieldsContainerView.frame = CGRectMake(marginLeftRight, yOffset, bounds.width - marginLeftRight*2, fieldHeight*4-3)
        
        addressLine1.frame = CGRectMake(0, 0, fieldsContainerView.frame.width, fieldHeight)
        addressLine2.frame = CGRectMake(0, fieldHeight-1, fieldsContainerView.frame.width, fieldHeight)
        city.frame = CGRectMake(0, fieldHeight*2-2, fieldsContainerView.frame.width, fieldHeight)
        state.frame = CGRectMake(0, fieldHeight*3-3, fieldsContainerView.frame.width/2, fieldHeight)
        zipcode.frame = CGRectMake(state.frame.width-1, state.frame.origin.y, state.frame.width+1, fieldHeight)
        
        yOffset = self.bounds.height - 40 - 30
        doneButton.frame = CGRectMake((self.bounds.width-180)/2, yOffset, 180, 40)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == addressLine1 {
            addressLine2.becomeFirstResponder()
        }
        else if textField == addressLine2 {
            city.becomeFirstResponder()
        }
        else if textField == city {
            state.becomeFirstResponder()
        }
        else if textField == state {
            zipcode.becomeFirstResponder()
        }
        else {
            zipcode.resignFirstResponder()
        }
        return true
    }
    
    func dismissKeyboard() {
        addressLine1.resignFirstResponder()
        addressLine2.resignFirstResponder()
        city.resignFirstResponder()
        state.resignFirstResponder()
        zipcode.resignFirstResponder()
    }
    
    func onTapDoneButton() {
        println("tapped on done button")
        if delegate != nil {
            delegate!.onTapDone()
        }
    }
    
    func setTitleText(text: String) {
        viewTitleLabel.text = text
    }
    func setExplanationText(text: String) {
        explanationLabel.text = text
    }
    func setDoneButtonText(text: String) {
        doneButton.setButtonTitle(text)
    }
}

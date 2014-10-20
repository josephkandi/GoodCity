//
//  SlotPickerView.swift
//  GoodCity
//
//  Created by Yili Aiwazian on 10/20/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

let DEFAULT_SLOTS = [9, 10, 11, 12, 13, 14, 15, 16]
let BUTTONS_PER_ROW : CGFloat = 2

class SlotPickerView: UIView {
    
    var buttonsArray: [SelectableButton]!
    var selectedSlotIndex: Int!
    
    // Keep track of a list of available slots by their indices
    var availableSlots: [Int]!

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
        // Set up the view with buttons for all the default slots
        // By default, all slots are disabled
        buttonsArray = [SelectableButton]()
        for slot in DEFAULT_SLOTS {
            let slotButton = SelectableButton()
            slotButton.slotHour = slot
            slotButton.slotDisabled = true
            buttonsArray.append(slotButton)
            self.addSubview(slotButton)
        }
        
        availableSlots = [Int]()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let frame = self.frame
        let rows = Int(CGFloat(DEFAULT_SLOTS.count) / BUTTONS_PER_ROW + 1)
        let buttonWidth = (frame.width - SPACING * 2 * (BUTTONS_PER_ROW-1)) / BUTTONS_PER_ROW
        
        //self.frame = BUTTON_HEIGHT * rows + SPACING * (rows-1)
        
        var index = 0
        var yOffset: CGFloat = 0
        for var row = 0; row < rows; row++ {
            var xOffset: CGFloat = 0
            for var i = 0; i < Int(BUTTONS_PER_ROW) && index < DEFAULT_SLOTS.count; i++ {
                let button = buttonsArray[index]
                button.frame = CGRectMake(xOffset, yOffset, buttonWidth, BUTTON_HEIGHT)
                xOffset += buttonWidth + SPACING*2
                index += 1
                println("button \(index) \(button.frame)")
            }
            yOffset += BUTTON_HEIGHT + SPACING*2
        }
    }
    func updateAvailableSlots(slots : [Int]) {
        for slot in slots {
            let index = slot - 9
            if (index >= 0 && index < buttonsArray.count) {
                buttonsArray[index].slotDisabled = false
            }
        }
    }
    func resetSlots() {
        for button in buttonsArray {
            button.slotDisabled = true
        }
    }
}

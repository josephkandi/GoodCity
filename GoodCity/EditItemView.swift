//
//  EditItemView.swift
//  GoodCity
//
//  Created by Nick Aiwazian on 10/17/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

class EditItemView: UIView {

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
        fatalError("init(coder:) has not been implemented")
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect)
    {
        // Drawing code
    }
    */

}

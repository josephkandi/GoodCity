//
//  SchedulePickupViewController.swift
//  GoodCity
//
//  Created by Nick Aiwazian on 10/5/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

class SchedulePickupViewController: UIViewController {

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var datePickerButton: RoundedButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        closeButton.setImage(UIImage(named: "edit_close").imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: .Normal)
        closeButton.tintColor = tintColor
        
        // Do any additional setup after loading the view.
    }


    @IBAction func onTapClose(sender: AnyObject) {
    }


    @IBAction func onTapDatePicker(sender: AnyObject) {
    }

}

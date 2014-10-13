//
//  ItemsGroupCell.swift
//  GoodCity
//
//  Created by Yili Aiwazian on 10/12/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

class ItemsGroupCell: UITableViewCell {

    @IBOutlet weak var donationDateLabel: UILabel!
    @IBOutlet weak var thumbnailsContainer: UIView!
    @IBOutlet weak var thumbnail1: UIImageView!
    @IBOutlet weak var thumbnail2: UIImageView!
    @IBOutlet weak var thumbnail3: UIImageView!
    @IBOutlet weak var thumbnail4: UIImageView!
    @IBOutlet weak var thumbnail5: UIImageView!
    @IBOutlet weak var buttonContainer: UIView!
    
    // Constraints
    @IBOutlet weak var buttonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var thumbnailHeightConstraint: NSLayoutConstraint!
    
    // Delegate
    var actionDelegate: ItemsActionDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        thumbnail1.setRoundedCorners(true)
        thumbnail2.setRoundedCorners(true)
        thumbnail3.setRoundedCorners(true)
        thumbnail4.setRoundedCorners(true)
        thumbnail5.setRoundedCorners(true)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        let frame = thumbnailsContainer.frame
        let thumbnailWidth = (frame.width - SPACING * 4) / 5
        thumbnailHeightConstraint.constant = thumbnailWidth
        
        donationDateLabel.numberOfLines = 0
        donationDateLabel.text = "Donated on: Oct 8, 2014"
        donationDateLabel.sizeToFit()
        
        buttonWidthConstraint.constant = (buttonContainer.frame.width - SPACING) / 2
    }
    
    @IBAction func tapPickupButton(sender: AnyObject) {
    }
    
    @IBAction func tapDropoffButton(sender: AnyObject) {
        if actionDelegate != nil {
            actionDelegate!.viewDropoffLocations()
        }
    }
}

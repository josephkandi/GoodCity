//
//  ItemsGroupCell.swift
//  GoodCity
//
//  Created by Yili Aiwazian on 10/12/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

let SPACING = CGFloat(5)

class ItemsGroupCell: UITableViewCell {

    @IBOutlet weak var donationDateLabel: UILabel!
    @IBOutlet weak var thumbnailsContainer: UIView!
    
    @IBOutlet weak var thumbnailHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
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
        donationDateLabel.text = "Donation on: Oct 8, 2014"
        donationDateLabel.sizeToFit()        
    }
    
}

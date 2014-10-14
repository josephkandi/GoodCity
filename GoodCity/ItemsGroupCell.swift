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
    @IBOutlet weak var buttonContainer: UIView!
    @IBOutlet weak var thumbnail1: UIImageView!
    @IBOutlet weak var thumbnail2: UIImageView!
    @IBOutlet weak var thumbnail3: UIImageView!
    @IBOutlet weak var thumbnail4: UIImageView!
    @IBOutlet weak var thumbnail5: UIImageView!
    
    var buttonsView: ActionButtonsView!
    
    // Constraints
    @IBOutlet weak var thumbnailHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonsHeightConstraint: NSLayoutConstraint!
    
    // Delegate
    private var actionDelegate: ItemsActionDelegate?
    
    // Items State
    private var itemsState: ItemState?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        thumbnail1.setRoundedCorners(true)
        thumbnail2.setRoundedCorners(true)
        thumbnail3.setRoundedCorners(true)
        thumbnail4.setRoundedCorners(true)
        thumbnail5.setRoundedCorners(true)
        
        buttonsView = ActionButtonsView(frame: buttonContainer.bounds)
        buttonContainer.addSubview(buttonsView)
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
        
        buttonsView.frame = buttonContainer.bounds
        buttonsView.layoutSubviews()
        buttonsHeightConstraint.constant = buttonsView.frame.height
    }
    
    @IBAction func tapPickupButton(sender: AnyObject) {
    }
    
    @IBAction func tapDropoffButton(sender: AnyObject) {
        if actionDelegate != nil {
            actionDelegate!.viewDropoffLocations()
        }
    }
    
    func setItemsState(state: ItemState) {
        self.itemsState = state
        buttonsView.setItemsState(state)
    }
    func setDelegate(delegate: ItemsActionDelegate) {
        self.actionDelegate = delegate
        buttonsView.setDelegate(delegate)
    }
}

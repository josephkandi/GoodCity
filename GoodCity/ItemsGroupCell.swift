//
//  ItemsGroupCell.swift
//  GoodCity
//
//  Created by Yili Aiwazian on 10/12/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

let ITEMS_PER_ROW : CGFloat = 5

class ItemsGroupCell: UITableViewCell {

    @IBOutlet weak var donationDateLabel: UILabel!
    @IBOutlet weak var buttonContainer: UIView!
    @IBOutlet weak var thumbnailsContainer: UIView!
    
    var thumbnailsArray: [UIImageView]!
    var buttonsView: ActionButtonsView!
    
    // Constraints
    @IBOutlet weak var thumbnailHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonsHeightConstraint: NSLayoutConstraint!
    
    // Delegate
    private var actionDelegate: ItemsActionDelegate?
    
    // Items State
    private var itemsState: ItemState?
    private var itemsGroup: DonationItemsAggregator.DonationGroup?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        buttonsView = ActionButtonsView(frame: buttonContainer.bounds)
        buttonContainer.addSubview(buttonsView)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        donationDateLabel.numberOfLines = 0
        donationDateLabel.text = "Donated on: Oct 8, 2014"
        donationDateLabel.sizeToFit()
        
        let frame = thumbnailsContainer.frame
        let rows = Int(CGFloat(thumbnailsArray.count) / ITEMS_PER_ROW) + 1
        let thumbnailWidth = (frame.width - SPACING * (ITEMS_PER_ROW-1)) / ITEMS_PER_ROW
        thumbnailHeightConstraint.constant = thumbnailWidth * CGFloat(rows) + SPACING * CGFloat(rows-1)
        
        var index = 0
        var yOffset: CGFloat = 0
        for var row = 0; row < rows; row++ {
            var xOffset: CGFloat = 0
            for var i = 0; i < Int(ITEMS_PER_ROW) && index < thumbnailsArray.count; i++ {
                let thumb = thumbnailsArray[index]
                thumb.frame = CGRectMake(xOffset, yOffset, thumbnailWidth, thumbnailWidth)
                xOffset += thumbnailWidth + SPACING
                index += 1
            }
            yOffset += thumbnailWidth + SPACING
        }

        buttonsView.frame = buttonContainer.bounds
        buttonsView.layoutSubviews()
        buttonsHeightConstraint.constant = buttonsView.frame.height
    }
    
    func setItemsState(state: ItemState) {
        self.itemsState = state
        buttonsView.setItemsState(state)
    }
    func setDelegate(delegate: ItemsActionDelegate) {
        self.actionDelegate = delegate
        buttonsView.setDelegate(delegate)
    }
    func setItemsGroup(group: DonationItemsAggregator.DonationGroup) {
        
        thumbnailsArray = [UIImageView]()
        self.itemsGroup = group
        buttonsView.setItemsGroup(group)
        
        for item in self.itemsGroup!.sortedDonationItems {
            let thumb = UIImageView()
            thumb.setRoundedCorners(true)
            thumb.contentMode = UIViewContentMode.ScaleAspectFill
            item.photo.getDataInBackgroundWithBlock({ (photoData, error) -> Void in
                if error == nil {
                    let image = UIImage(data: photoData)
                    thumb.image = image
                }
            })
            thumb.backgroundColor = UIColor.darkGrayColor()
            thumbnailsArray.append(thumb)
            thumbnailsContainer.addSubview(thumb)
        }
    }
}

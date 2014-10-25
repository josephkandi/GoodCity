//
//  ItemsGroupCell.swift
//  GoodCity
//
//  Created by Yili Aiwazian on 10/12/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

let ITEMS_PER_ROW : CGFloat = 3
private let marginTopBottom: CGFloat = 20
private let marginLeftRight: CGFloat = 12
private let gapMargin: CGFloat = 10

class ItemsGroupCell: UITableViewCell {
    
    @IBOutlet weak var stateIcon: UIImageView!
    @IBOutlet weak var donationTextLabel: UILabel!
    @IBOutlet weak var buttonContainer: UIView!
    @IBOutlet weak var thumbnailsContainer: UIView!
    
    var thumbnailsArray: [UIImageView]!
    var buttonsView: ActionButtonsView!
    
    // Delegate
    private var actionDelegate: ItemsActionDelegate?
    
    // Items State
    private var itemsState: ItemState?
    var itemsGroup: DonationItemsAggregator.DonationGroup?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        stateIcon.backgroundColor = UIColor.purpleColor()

        buttonsView = ActionButtonsView(frame: buttonContainer.bounds)
        buttonContainer.addSubview(buttonsView)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        let bounds = self.bounds
        var xOffset = marginLeftRight
        var yOffset = marginTopBottom
        
        // Set up the state icon image
        stateIcon.frame = CGRectMake(xOffset, yOffset, 40, 40)
        stateIcon.layer.cornerRadius = 20
        stateIcon.layer.masksToBounds = true
        
        xOffset += stateIcon.frame.width + gapMargin
        
        // Set up the donation title text label
        donationTextLabel.frame = CGRectMake(xOffset, yOffset, bounds.width - xOffset - marginLeftRight, 30)
        donationTextLabel.numberOfLines = 0
        donationTextLabel.text = "Donated on: Oct 8, 2014"
        donationTextLabel.sizeToFit()
        
        yOffset += donationTextLabel.frame.height + gapMargin
        
        // Set up the thumbnails
        thumbnailsContainer.frame = CGRectMake(xOffset, yOffset, bounds.width - xOffset - marginLeftRight, 60)
        let frame = thumbnailsContainer.frame
        let rows = Int(CGFloat(thumbnailsArray.count) / ITEMS_PER_ROW) + 1
        let thumbnailWidth = (frame.width - SPACING * (ITEMS_PER_ROW-1)) / ITEMS_PER_ROW
        
        var index = 0
        var y: CGFloat = 0
        for var row = 0; row < rows; row++ {
            var x: CGFloat = 0
            for var i = 0; i < Int(ITEMS_PER_ROW) && index < thumbnailsArray.count; i++ {
                let thumb = thumbnailsArray[index]
                thumb.frame = CGRectMake(x, y, thumbnailWidth, thumbnailWidth)
                x += thumbnailWidth + SPACING
                index += 1
            }
            y += thumbnailWidth + SPACING
        }
        
        let thumbnailsContainerHeight = thumbnailWidth * CGFloat(rows) + SPACING * CGFloat(rows-1)

        thumbnailsContainer.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.width, thumbnailsContainerHeight)
        yOffset += thumbnailsContainerHeight + gapMargin * 2
        
        // Set up the buttons (optional)
        buttonContainer.frame = CGRectMake(marginLeftRight, yOffset, bounds.width - 2 * marginLeftRight, 35)
        buttonsView.frame = buttonContainer.bounds
        buttonsView.layoutSubviews()
        buttonContainer.frame = CGRectMake(buttonContainer.frame.origin.x, buttonContainer.frame.origin.y, buttonContainer.frame.width, buttonsView.frame.height)
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
        // reset
        cleanupThumbs()
    
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
    
    func cleanupThumbs() {
        thumbnailsArray = [UIImageView]()
        for thumb in thumbnailsContainer.subviews {
            thumb.removeFromSuperview()
        }
    }
    
    class func getThumbnailsHeight(width: CGFloat, count: Int) -> CGFloat {
        let rows = Int(CGFloat(count) / ITEMS_PER_ROW) + 1
        let thumbnailWidth = (width - SPACING * (ITEMS_PER_ROW-1)) / ITEMS_PER_ROW
        let height = thumbnailWidth * CGFloat(rows) + SPACING * CGFloat(rows-1)
        return height
    }
}

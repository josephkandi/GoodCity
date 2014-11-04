//
//  ItemsGroupCell.swift
//  GoodCity
//
//  Created by Yili Aiwazian on 10/12/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

let ITEMS_PER_ROW : CGFloat = 3
private let marginTopBottom: CGFloat = 10
private let marginLeftRight: CGFloat = 10
private let gapMargin: CGFloat = 6
private let iconWidth: CGFloat = 34

class ItemsGroupCell: UITableViewCell {
    
    @IBOutlet weak var cardContainerView: UIView!
    @IBOutlet weak var headerContainerView: UIView!
    
    @IBOutlet weak var stateIcon: UIImageView!
    @IBOutlet weak var donationTextLabel: UILabel!
    @IBOutlet weak var buttonContainer: UIView!
    @IBOutlet weak var thumbnailsContainer: UIView!
    
    var thumbnailsArray: [PFImageView]!
    var buttonsView: ActionButtonsView!
    
    // Delegate
    private var actionDelegate: ItemsActionDelegate?
    
    // Items State
    private var itemsState: ItemState?
    var itemsGroup: DonationItemsAggregator.DonationGroup?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        buttonsView = ActionButtonsView(frame: buttonContainer.bounds)
        buttonContainer.addSubview(buttonsView)

        cardContainerView.layer.cornerRadius = 4
        cardContainerView.layer.masksToBounds = true
        
        donationTextLabel.textAlignment = .Center
        donationTextLabel.font = FONT_BOLD_15
        donationTextLabel.textColor = UIColor.whiteColor()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func layoutDonationTextLabel() {
        var text = ""
        var itemsCount = itemsGroup!.sortedDonationItems.count
        var date = getFriendlyShortDateFormatter().stringFromDate(itemsGroup!.originalDate)
        var pickedUpDateString: String
        if let pickupDate = itemsGroup?.pickupDate {
            pickedUpDateString = getFriendlyShortDateFormatter().stringFromDate(pickupDate)
        } else {
            pickedUpDateString = ""
        }

        var s = ""
        var have = "has"
        var are = "is"
        if itemsCount > 1 {
            s = "s"
            have = "have"
            are = "are"
        }
        
        if itemsState == ItemState.Approved {
            text = "\(itemsCount) item\(s) approved".uppercaseString
        }
        else if itemsState == ItemState.Scheduled {
            text = "Scheduled Pickup @ \(pickedUpDateString)".uppercaseString
        }
        else if itemsState == ItemState.Pending {
            text = "\(itemsCount) item\(s) pending review".uppercaseString
        }
        else if itemsState == ItemState.PickedUp {
            text = "\(itemsCount) item\(s) received on \(pickedUpDateString)"
        }
        else if itemsState == ItemState.NotNeeded {
            text = "\(itemsCount) item\(s) donated on \(date) \(are) currently not needed"
        }
        else {
            text = "Donated on: Oct 8, 2014"
        }
        //donationTextLabel.numberOfLines = 0
        donationTextLabel.text = text
        //donationTextLabel.sizeToFit()
    }
    
    func setupHeaderView() {
        stateIcon.tintColor = UIColor.whiteColor()
        if itemsState == ItemState.Approved {
            stateIcon.image = UIImage(named: "history_approved")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            headerContainerView.backgroundColor = greenHighlight
        }
        else if itemsState == ItemState.Scheduled {
            stateIcon.image = UIImage(named: "history_scheduled")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            headerContainerView.backgroundColor = blueHighlight
        }
        else if itemsState == ItemState.Pending {
            stateIcon.image = UIImage(named: "history_pending")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            headerContainerView.backgroundColor = yellowHighlight
        }
        else if itemsState == ItemState.PickedUp {
            stateIcon.image = UIImage(named: "history_pickedup")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            headerContainerView.backgroundColor = pinkHighlight
        }
        else if itemsState == ItemState.NotNeeded {
            stateIcon.image = UIImage(named: "history_notneeded")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            headerContainerView.backgroundColor = UIColor.lightGrayColor()
        }
        else {
            stateIcon.image = nil
            stateIcon.backgroundColor = UIColor.lightGrayColor()
        }
        stateIcon.contentMode = UIViewContentMode.ScaleAspectFill
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Set the main container view
        cardContainerView.frame = CGRectMake(10, 10, self.bounds.width-20, self.bounds.height-10)
        let bounds = cardContainerView.bounds
        
        // Set the header container view at the top of the card
        headerContainerView.frame = CGRectMake(0, 0, bounds.width, 55)
        headerContainerView.backgroundColor = greenHighlight
        
        var xOffset = marginLeftRight
        var yOffset = marginTopBottom
        
        // Set up the state icon image
        stateIcon.frame = CGRectMake(xOffset, yOffset+4, iconWidth, iconWidth)
        stateIcon.layer.cornerRadius = stateIcon.frame.height / 2
        stateIcon.layer.masksToBounds = true
        setupHeaderView()
        xOffset += iconWidth + gapMargin + 5
        
        // Set up the donation title text label
        donationTextLabel.frame = CGRectMake(xOffset, 0, bounds.width - xOffset - marginLeftRight, headerContainerView.frame.height)
        layoutDonationTextLabel()
        
        yOffset += donationTextLabel.frame.height + gapMargin
        
        // Set up the thumbnails
        thumbnailsContainer.frame = CGRectMake(16, yOffset, bounds.width - 16*2, 60)
        let frame = thumbnailsContainer.frame
        let rows = Int(ceil(CGFloat(thumbnailsArray.count) / ITEMS_PER_ROW))
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
        yOffset += thumbnailsContainerHeight + 20
        
        // Set up the buttons (optional)
        buttonContainer.frame = CGRectMake(marginLeftRight, yOffset, bounds.width - 2 * marginLeftRight, 35)
        buttonsView.frame = buttonContainer.bounds
        buttonsView.layoutSubviews()
        buttonContainer.frame = CGRectMake(buttonContainer.frame.origin.x, buttonContainer.frame.origin.y, buttonContainer.frame.width, buttonsView.frame.height + marginTopBottom)
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
        
        // TODO: Add the ability to compare if the new group is the same as the old group. If so, don't need to update
        //if group == self.itemsGroup {
        //    return
        //}
        
        // reset
        cleanupThumbs()
    
        self.itemsGroup = group
        buttonsView.setItemsGroup(group)
        
        for item in self.itemsGroup!.sortedDonationItems {
            let thumb = PFImageView()
            thumb.setRoundedCorners(true)
            thumb.contentMode = UIViewContentMode.ScaleAspectFill
            thumb.file = item.photo
            thumb.loadInBackground(nil)

            thumb.backgroundColor = UIColor.darkGrayColor()
            thumbnailsArray.append(thumb)
            thumbnailsContainer.addSubview(thumb)
        }
    }
    
    func cleanupThumbs() {
        thumbnailsArray = [PFImageView]()
        for thumb in thumbnailsContainer.subviews {
            thumb.removeFromSuperview()
        }
    }
    
    class func getThumbnailsHeight(width: CGFloat, count: Int) -> CGFloat {
        let rows = Int(ceil(CGFloat(count) / ITEMS_PER_ROW))
        let xOffset = marginLeftRight + 16
        let thumbnailWidth = (width - xOffset - SPACING * (ITEMS_PER_ROW-1)) / ITEMS_PER_ROW
        let height = thumbnailWidth * CGFloat(rows) + SPACING * CGFloat(rows-1)
        return height
    }
}

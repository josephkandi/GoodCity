//
//  CartItemCell.swift
//  GoodCity
//
//  Created by Yili Aiwazian on 10/11/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

let TEXT_MARGIN = CGFloat(8)
private let marginTopBottom: CGFloat = 8
private let marginLeftRight: CGFloat = 8
private let gapMargin: CGFloat = 6

class CartItemCell: UICollectionViewCell {
    
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var itemDescription: UILabel!
    @IBOutlet weak var itemCondition: UILabel!
    
    var donationItem: DonationItem? {
        didSet(oldItemOrNil) {
            if donationItem == oldItemOrNil {
                return
            }
            else if let newItem = donationItem {
                self.itemDescription.text = newItem.itemDescription
                self.itemCondition.text = newItem.condition
                // Can move this over to PFImageView to improve perf
                newItem.photo.getDataInBackgroundWithBlock({ (photoData, error) -> Void in
                    if error == nil {
                        let image = UIImage(data: photoData)
                        self.itemImage.image = image
                    }
                })
            }
        }
    }
    
    override func layoutSubviews() {
        
        let bounds = self.bounds
        itemImage.frame = CGRectMake(0, 0, bounds.width, bounds.width)
        var yOffset = itemImage.frame.height + gapMargin
        itemDescription.numberOfLines = 0
        itemDescription.frame = CGRectMake(marginLeftRight, yOffset, bounds.width-2*marginLeftRight, 40)
        itemDescription.sizeToFit()
        yOffset += 40 + gapMargin
        
        itemCondition.numberOfLines = 0
        itemCondition.frame = CGRectMake(marginLeftRight, yOffset, bounds.width-2*marginLeftRight, 16)
        itemCondition.sizeToFit()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 4.0
        self.layer.masksToBounds = true
        self.backgroundColor = UIColor.whiteColor()
        
        //itemCondition.backgroundColor = UIColor(white: 0.8, alpha: 1)
        itemCondition.textColor = UIColor.lightGrayColor()
    }
}

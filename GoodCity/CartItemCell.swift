//
//  CartItemCell.swift
//  GoodCity
//
//  Created by Yili Aiwazian on 10/11/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

let TEXT_MARGIN = CGFloat(8)

class CartItemCell: UICollectionViewCell {

    private let itemImage: UIImageView!
    private let descriptionLabel: UILabel!
    private let conditionLabel: UILabel!

    var donationItem: DonationItem? {
        didSet(oldItemOrNil) {
            if donationItem == oldItemOrNil {
                return
            }
            else if let newItem = donationItem {
                self.descriptionLabel.text = newItem.itemDescription
                self.conditionLabel.text = newItem.condition
                newItem.photo.getDataInBackgroundWithBlock({ (photoData, error) -> Void in
                    if error == nil {
                        let image = UIImage(data: photoData)
                        self.itemImage.image = image
                    }
                })
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.layer.cornerRadius = 4.0
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = UIColor.whiteColor()
        
        itemImage = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.width))
        itemImage.contentMode = UIViewContentMode.ScaleAspectFill
        itemImage.clipsToBounds = true
        contentView.addSubview(itemImage)
        
        let textFrame = CGRect(x: TEXT_MARGIN, y: itemImage.frame.size.height, width: frame.size.width - 2*TEXT_MARGIN, height: frame.size.height - itemImage.frame.height - 25)
        descriptionLabel = UILabel(frame: textFrame)
        descriptionLabel.textAlignment = .Left
        descriptionLabel.font = FONT_14
        contentView.addSubview(descriptionLabel)
        
        let conditionFrame = CGRect(x: TEXT_MARGIN, y: textFrame.origin.y + textFrame.height, width: frame.size.width - 2*TEXT_MARGIN, height: 25)
        conditionLabel = UILabel(frame: conditionFrame)
        conditionLabel.textAlignment = .Left
        conditionLabel.font = FONT_MEDIUM_12
        contentView.addSubview(conditionLabel)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

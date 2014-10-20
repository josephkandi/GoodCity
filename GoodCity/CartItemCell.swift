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
                newItem.photo.getDataInBackgroundWithBlock({ (photoData, error) -> Void in
                    if error == nil {
                        let image = UIImage(data: photoData)
                        self.itemImage.image = image
                    }
                })
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 4.0
        self.layer.masksToBounds = true
        self.backgroundColor = UIColor.whiteColor()
    }
}

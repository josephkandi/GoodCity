//
//  CartItemCell.swift
//  GoodCity
//
//  Created by Yili Aiwazian on 10/11/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

let FONT = UIFont(name: "Avenir Next", size: 14.0)
let TEXT_MARGIN = CGFloat(8)

class CartItemCell: UICollectionViewCell {

    let itemImage: UIImageView!
    let descriptionLabel: UILabel!
    let conditionLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.layer.cornerRadius = 4.0
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = UIColor.whiteColor()
        
        itemImage = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.width))
        itemImage.contentMode = UIViewContentMode.ScaleAspectFit
        itemImage.image = UIImage(named: "kitty")
        contentView.addSubview(itemImage)
        
        let textFrame = CGRect(x: TEXT_MARGIN, y: itemImage.frame.size.height, width: frame.size.width - 2*TEXT_MARGIN, height: frame.size.height - itemImage.frame.height)
        descriptionLabel = UILabel(frame: textFrame)
        descriptionLabel.textAlignment = .Left
        descriptionLabel.font = FONT
        contentView.addSubview(descriptionLabel)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

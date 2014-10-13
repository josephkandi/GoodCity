//
//  CollectionHeaderView.swift
//  GoodCity
//
//  Created by Yili Aiwazian on 10/11/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

let SECTION_HEADER_FONT = UIFont(name: "Avenir Next-Medium", size: 12.0)

class CollectionHeaderView: UICollectionReusableView {
    
    let sectionLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.whiteColor()
        
        let textFrame = CGRect(x: TEXT_MARGIN, y: 0, width: frame.size.width - 2*TEXT_MARGIN, height: frame.height)
        sectionLabel = UILabel(frame: textFrame)
        sectionLabel.textAlignment = .Left
        sectionLabel.text = "Section Header"
        sectionLabel.font = SECTION_HEADER_FONT
        self.addSubview(sectionLabel)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

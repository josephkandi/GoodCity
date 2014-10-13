//
//  SectionHeaderView.swift
//  GoodCity
//
//  Created by Yili Aiwazian on 10/12/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

let SECTION_HEADER_FONT = UIFont(name: "AvenirNext-Medium", size: 14.0)

class SectionHeaderView: UITableViewHeaderFooterView {

    let sectionLabel: UILabel!
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        sectionLabel = UILabel(frame: CGRectMake(TEXT_MARGIN, 0, 300, 40))
        sectionLabel.font = SECTION_HEADER_FONT

        self.addSubview(sectionLabel)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSectionTitle(title: String) {
        sectionLabel.text = title.uppercaseString
    }
}

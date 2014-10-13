//
//  UIImageView+Extensions.swift
//  GoodCity
//
//  Created by Yili Aiwazian on 10/12/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import Foundation

extension UIImageView {
    
    func setRoundedCorners(on: Bool) {
        if on {
            self.layer.cornerRadius = 4.0
            self.layer.masksToBounds = true
        }
        else {
            self.layer.cornerRadius = 0.0
            self.layer.masksToBounds = false
        }
    }
}
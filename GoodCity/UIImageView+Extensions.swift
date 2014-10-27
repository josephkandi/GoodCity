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
    func fadeInImageFromURL(url: NSURL, border: Bool) {
        let request = NSURLRequest(URL: url)
        self.setImageWithURLRequest(request, placeholderImage: nil, success: { (request, response, image) -> Void in
            if (response == nil) {
                self.image = image
                if border {
                    self.layer.borderColor = UIColor.whiteColor().CGColor
                    self.layer.borderWidth = 2
                }
                return
            }
            self.alpha = 0.0
            UIView.animateWithDuration(0.4, animations: { () -> Void in
                self.image = image
                self.alpha = 1.0
                if border {
                    self.layer.borderColor = UIColor.whiteColor().CGColor
                    self.layer.borderWidth = 2                    
                }
            })
            }, failure: nil)
    }

}
//
//  UIView+Extensions.swift
//  GoodCity
//
//  Created by Yili Aiwazian on 10/17/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import Foundation

extension UIViewController {
    
    // Returns a date formatted for display showing time elapsed since now
    func styleNavBar() {
        let titleSytle: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: FONT_BOLD_18]
        self.navigationController?.navigationBar.titleTextAttributes = titleSytle
        self.navigationItem.title = "GoodCity.HK"
        self.navigationController?.navigationBar.barTintColor = NAV_BAR_COLOR
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
    }
}
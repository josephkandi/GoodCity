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
        self.navigationItem.title = "GoodCity.HK"
        
        if let navController = self.navigationController {
            self.styleNavBar(navController.navigationBar)
        }
    }
    
    func styleNavBar(navBar: UINavigationBar) {
        let titleSytle: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: FONT_BOLD_18]
        navBar.titleTextAttributes = titleSytle
        navBar.barTintColor = NAV_BAR_COLOR
        navBar.translucent = false
        navBar.tintColor = UIColor.whiteColor()
    }
}
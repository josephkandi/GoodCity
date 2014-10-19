//
//  CartViewDelegate.h
//  GoodCity
//
//  Created by Yili Aiwazian on 10/18/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#ifndef GoodCity_CartViewDelegate_h
#define GoodCity_CartViewDelegate_h

@class DonationItem;

@protocol CartViewDelegate <NSObject>

- (void) addNewItem:(DonationItem *)item;

@end

#endif

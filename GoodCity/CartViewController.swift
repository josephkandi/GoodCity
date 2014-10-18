//
//  CartViewController.swift
//  GoodCity
//
//  Created by Yili Aiwazian on 10/10/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

let TOP_MARGIN = CGFloat(20)
let BOTTOM_MARGIN = CGFloat(20)
let SIDE_MARGIN = CGFloat(12)
let ITEM_SPACING = CGFloat(10)

class CartViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var cartCollectionView: UICollectionView!
    @IBOutlet weak var collectionHeader: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.styleNavBar()
        collectionHeader.backgroundColor = NAV_BAR_COLOR
        
        cartCollectionView.dataSource = self
        cartCollectionView.delegate = self
 
        cartCollectionView.registerClass(CartItemCell.self, forCellWithReuseIdentifier: "cartItemCell")
        cartCollectionView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        let layout = cartCollectionView.collectionViewLayout as UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsets(top: TOP_MARGIN, left: SIDE_MARGIN, bottom: BOTTOM_MARGIN, right: SIDE_MARGIN)
        layout.itemSize = getCellSize()
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = cartCollectionView.dequeueReusableCellWithReuseIdentifier("cartItemCell", forIndexPath: indexPath) as CartItemCell
        cell.descriptionLabel.text = "Item " + String(indexPath.row+1)
        
        return cell
    }
    
    private func getCellSize() -> CGSize {
        let containerSize = cartCollectionView.bounds
        let width = (containerSize.width - SIDE_MARGIN * 2 - ITEM_SPACING) / 2
        return CGSizeMake(width, width/3*4)
    }
}

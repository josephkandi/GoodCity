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

class CartViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CartViewDelegate {
    
    @IBOutlet weak var cartCollectionView: UICollectionView!
    @IBOutlet weak var collectionHeader: UIView!
    @IBOutlet weak var collectionHeaderLabel: UILabel!
    var cameraViewDelegate: CameraViewDelegate?
    
    // Array of pending donation items
    var pendingItems = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.styleNavBar()
        collectionHeader.backgroundColor = NAV_BAR_COLOR
        self.view.backgroundColor = LIGHT_GRAY_BG
        
        cartCollectionView.dataSource = self
        cartCollectionView.delegate = self
 
        let cellNib = UINib(nibName: "CartItemCell", bundle: nil)
        cartCollectionView.registerNib(cellNib, forCellWithReuseIdentifier: "cartItemCell")
        
        getPendingItems()
        cartCollectionView.reloadData()
    }

    override func viewDidLayoutSubviews() {
        let layout = cartCollectionView.collectionViewLayout as UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsets(top: TOP_MARGIN, left: SIDE_MARGIN, bottom: BOTTOM_MARGIN, right: SIDE_MARGIN)
        layout.itemSize = getCellSize()
    }
    
    // There's always only 1 section in this collection view for pending items
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        println(pendingItems.count)
        return pendingItems.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = cartCollectionView.dequeueReusableCellWithReuseIdentifier("cartItemCell", forIndexPath: indexPath) as CartItemCell
        cell.donationItem = pendingItems[indexPath.row] as? DonationItem

        return cell
    }
    
    private func getCellSize() -> CGSize {
        let containerSize = cartCollectionView.bounds
        let width = (containerSize.width - SIDE_MARGIN * 2 - ITEM_SPACING) / 2
        return CGSizeMake(width, width/3*4.5)
    }
    
    private func getPendingItems() {
        DonationItem.getAllItemsWithStates({
            (objects, error) -> () in
            println("Completed")
            if let donationItems = objects as? [DonationItem] {
                println(donationItems)
                self.pendingItems.addObjectsFromArray(donationItems)
                self.updateCount()
                self.cartCollectionView.reloadData()
            }
            else {
                println(error)
            }
        }, states: [ItemState.Pending])
    }
    
    func updateCount() {
        let count = self.pendingItems.count > 0 ? String(self.pendingItems.count) : ""
        self.collectionHeaderLabel.text = "PENDING REVIEW (" + count + ")"
        self.cameraViewDelegate?.updateItemsCount(String(self.pendingItems.count))
    }
    //Delegate functions
    func addNewItem(newItem: DonationItem) {
        pendingItems.insertObject(newItem, atIndex: 0)
        updateCount()
        cartCollectionView.reloadData()
    }
    func getItemsCount() -> NSInteger {
        return self.pendingItems.count
    }
}

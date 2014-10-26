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

class CartViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CartViewDelegate,
    GHContextOverlayViewDelegate, GHContextOverlayViewDataSource {
    
    @IBOutlet weak var cartCollectionView: UICollectionView!
    var cameraViewDelegate: CameraViewDelegate?
    var submitButton: UIBarButtonItem!

    // Array of pending donation items
    var cartItems = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Style the nav bar
        self.navigationItem.title = "CART"
        self.styleNavBar(self.navigationController!.navigationBar)
        
        // Add submit button to the nav bar
        let submitIcon = UIImage(named: "cart_submit")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        submitButton = UIBarButtonItem(image: submitIcon, style: UIBarButtonItemStyle.Plain, target: self, action: "submitCartItems")
        submitButton.tintColor = UIColor.whiteColor()
        self.navigationItem.setRightBarButtonItem(submitButton, animated: true)

        // Set up the collection view
        self.view.backgroundColor = LIGHT_GRAY_BG
        cartCollectionView.backgroundColor = LIGHT_GRAY_BG
        cartCollectionView.dataSource = self
        cartCollectionView.delegate = self
 
        let cellNib = UINib(nibName: "CartItemCell", bundle: nil)
        cartCollectionView.registerNib(cellNib, forCellWithReuseIdentifier: "cartItemCell")
        
        // Load data
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
        println(cartItems.count)
        return cartItems.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = cartCollectionView.dequeueReusableCellWithReuseIdentifier("cartItemCell", forIndexPath: indexPath) as CartItemCell
        cell.donationItem = cartItems[indexPath.row] as? DonationItem
        cell.layoutSubviews()
        
        let overlay = GHContextMenuView()
        overlay.delegate = self
        overlay.dataSource = self

        let longPressRecognizer = UILongPressGestureRecognizer(target: overlay, action: "longPressDetected:")
        cell.contentView.addGestureRecognizer(longPressRecognizer)

        return cell
    }
    
    private func getCellSize() -> CGSize {
        let containerSize = cartCollectionView.bounds
        let width = (containerSize.width - SIDE_MARGIN * 2 - ITEM_SPACING) / 2
        return CGSizeMake(width, width + 74)
    }
    
    private func getPendingItems() {
        DonationItem.getAllItemsWithStates({
            (objects, error) -> () in
            println("Completed")
            if let donationItems = objects as? [DonationItem] {
                println(donationItems)
                self.cartItems.addObjectsFromArray(donationItems)
                self.updateCount()
                self.cartCollectionView.reloadData()
            }
            else {
                println(error)
            }
        }, states: [ItemState.Draft])
    }

    func updateCount() {
        var string = "CART"
        let count = self.cartItems.count > 0 ? " (\(String(self.cartItems.count)))" : ""
        string = string + count
        self.navigationItem.title = string
        
        self.cameraViewDelegate?.updateItemsCount(String(self.cartItems.count), animated: true)
    }
    
    func submitCartItems() {
        for item in cartItems {
            let donationItem = item as DonationItem
            donationItem.updateState(ItemState.Pending)
        }
        cartItems.removeAllObjects()
        cartCollectionView.reloadData()
    }
    
    //Delegate functions
    func addNewItem(newItem: DonationItem) {
        cartItems.insertObject(newItem, atIndex: 0)
        updateCount()
        cartCollectionView.reloadData()
    }
    func getItemsCount() -> NSInteger {
        return self.cartItems.count
    }

    // Context menu
    func numberOfMenuItems() -> Int {
        return 2
    }

    func imageForItemAtIndex(index: Int) -> UIImage! {
        let images = ["history_scheduled", "history_pending"]
        return UIImage(named: images[index])
    }

    func didSelectItemAtIndex(selectedIndex: Int, forMenuAtPoint point: CGPoint) {
        if let indexPath = self.cartCollectionView.indexPathForItemAtPoint(point) {
            if let cell = self.cartCollectionView.cellForItemAtIndexPath(indexPath) as? CartItemCell {
                println("Found the cell to delete")

                var message = ""

                switch selectedIndex {
                case 0:
                    message = "scheduled"
                case 1:
                    message = "delete"
                    if let donationItem = cell.donationItem {
                        println("Found donationitem to delete....deleting")
                        cartItems.removeObject(donationItem)
                        donationItem.deleteEventually()
                        self.cartCollectionView.performBatchUpdates({ () -> Void in
                            self.cartCollectionView.deleteItemsAtIndexPaths([indexPath])
                        }, completion: { (success) -> Void in
                            if success {
                                self.updateCount()
                            }
                        })
                    }
                default:
                    message = "unknown"
                }
            }
        }
    }
}

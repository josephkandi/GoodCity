//
//  CartViewController.swift
//  GoodCity
//
//  Created by Yili Aiwazian on 10/10/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

class CartViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var cartCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register collection cells
        //self.cartCollectionView.registerClass(CartItemCell.self, forCellWithReuseIdentifier: "cartItemCell")
        registerCollectionViewCellNib("CartItemCell", reuseIdentifier: "cartItemCell")
        
        
        cartCollectionView.dataSource = self
        cartCollectionView.delegate = self
        
        let layout = cartCollectionView.collectionViewLayout as UICollectionViewFlowLayout
        
        layout.itemSize = CGSize (width: 300, height: 400)
        
        cartCollectionView.reloadData()
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        var cell = cartCollectionView.dequeueReusableCellWithReuseIdentifier("cartItemCell", forIndexPath: indexPath) as CartItemCell

        cell.backgroundColor = UIColor.orangeColor()
        
        return cell
    }
    
    // Helper functions
    func registerCollectionViewCellNib(nibName: String, reuseIdentifier: String) {
        let nib = UINib(nibName: nibName, bundle: nil)
        //self.cartCollectionView.registerClass(cellClass, forCellWithReuseIdentifier: reuseIdentifier)
        self.cartCollectionView.registerNib(nib, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
}

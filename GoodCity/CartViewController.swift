import UIKit

let TOP_MARGIN = CGFloat(20)
let BOTTOM_MARGIN = CGFloat(20)
let SIDE_MARGIN = CGFloat(12)
let ITEM_SPACING = CGFloat(10)

class CartViewController: UIViewController {
    
    @IBOutlet weak var cartCollectionView: UICollectionView!
    var cartItems = NSMutableArray()

    var cameraViewDelegate: CameraViewDelegate?
    var submitButton: UIBarButtonItem!


    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = LIGHT_GRAY_BG
    }

    override func viewWillAppear(animated: Bool) {
        self.configureNavigationBar()
        self.configureCollectionView()
        self.refreshDataFromServer()
    }

    // Set up cell sizes
    override func viewDidLayoutSubviews() {
        let layout = cartCollectionView.collectionViewLayout as UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsets(top: TOP_MARGIN, left: SIDE_MARGIN, bottom: BOTTOM_MARGIN, right: SIDE_MARGIN)
        layout.itemSize = getCellSize()
    }

    private func configureNavigationBar() {
        // Style the nav bar
        self.navigationItem.title = "CART"
        self.styleNavBar(self.navigationController!.navigationBar)

        // Add submit button to the nav bar
        let submitIcon = UIImage(named: "cart_submit")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        submitButton = UIBarButtonItem(image: submitIcon, style: UIBarButtonItemStyle.Plain, target: self, action: "showSubmitConfirmationPopup")
        submitButton.tintColor = UIColor.whiteColor()
        self.navigationItem.setRightBarButtonItem(submitButton, animated: true)
    }

    private func configureCollectionView() {
        cartCollectionView.backgroundColor = LIGHT_GRAY_BG
        cartCollectionView.dataSource = self

        let cellNib = UINib(nibName: "CartItemCell", bundle: nil)
        cartCollectionView.registerNib(cellNib, forCellWithReuseIdentifier: "cartItemCell")
    }

    func refreshDataFromServer() {
        // Load data
        self.emptyCart()
        getDraftItemsFromServer()
        cartCollectionView.reloadData()
    }

    private func getCellSize() -> CGSize {
        let containerSize = cartCollectionView.bounds
        let width = (containerSize.width - SIDE_MARGIN * 2 - ITEM_SPACING) / 2
        return CGSizeMake(width, width + 74)
    }
    
    private func getDraftItemsFromServer() {
        DonationItem.getAllItemsWithStates({
            (objects, error) -> () in
            if let donationItems = objects as? [DonationItem] {
                self.cartItems.addObjectsFromArray(donationItems)
                self.updateCount(false)
                self.cartCollectionView.reloadData()
            }
            else {
                println("Error trying to get pending items from server: \(error)")
            }
        }, states: [ItemState.Draft])
    }

    func updateCount(animated: Bool) {
        var string = "CART"
        let count = self.cartItems.count > 0 ? " (\(String(self.cartItems.count)))" : ""
        string = string + count
        self.navigationItem.title = string
        self.navigationItem.rightBarButtonItem!.enabled = self.cartItems.count > 0
        
        self.cameraViewDelegate?.updateItemsCount(String(self.cartItems.count), animated: animated)
    }

    func emptyCart() {
        cartItems.removeAllObjects()
        self.updateCount(false)
    }

    func submitCartItems() {
        for item in cartItems {
            let donationItem = item as DonationItem
            donationItem.updateState(ItemState.Pending)
        }
        self.emptyCart()
        cartCollectionView.reloadData()
    }

    func showSubmitConfirmationPopup() {
        let alertView = SIAlertView(title: "Thank you!", andMessage: "This will submit your items for review by one of our volunteers.")

        alertView.addButtonWithTitle("Cancel", type: SIAlertViewButtonType.Cancel) { (originatingView) -> Void in
            println("Cancel")
        }

        alertView.addButtonWithTitle("Submit", type: SIAlertViewButtonType.Default) { (originatingView) -> Void in
            println("SUBMIT")
            self.submitCartItems()
        }

        alertView.transitionStyle = SIAlertViewTransitionStyle.DropDown
        alertView.show()
    }

    private func deleteItem(indexPath: NSIndexPath) {
        if let donationItem = self.cartItems[indexPath.row] as? DonationItem {
            println("Found donationitem to delete....deleting")
            cartItems.removeObject(donationItem)
            donationItem.deleteEventually()
            self.cartCollectionView.performBatchUpdates({ () -> Void in
                self.cartCollectionView.deleteItemsAtIndexPaths([indexPath])
                }, completion: { (success) -> Void in
                    if success {
                        self.updateCount(false)
                    }
            })
        }
    }
}

// Data Source
extension CartViewController: UICollectionViewDataSource {
    // There's always only 1 section in this collection view for pending items
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
}

// Pinterest style menu
extension CartViewController: GHContextOverlayViewDelegate, GHContextOverlayViewDataSource {
    func numberOfMenuItems() -> Int {
        return 2
    }

    func imageForItemAtIndex(index: Int) -> UIImage! {
        
        let delete = UIImage(named: "cart_delete")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        let camera = UIImage(named: "cart_camera")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        
        let images = [delete, camera]
        return images[index]
    }

    func didSelectItemAtIndex(selectedIndex: Int, forMenuAtPoint point: CGPoint) {
        if let indexPath = self.cartCollectionView.indexPathForItemAtPoint(point) {
            println("Found the indexPath to delete")

            var message = ""

            switch selectedIndex {
            case 0:
                message = "scheduled"
                self.deleteItem(indexPath)
            case 1:
                message = "delete"
                self.deleteItem(indexPath)
            default:
                println("ERROR: Did not match item in menu")
                message = "unknown"
            }
        } else {
            println("ERROR: Could not find collection view cell at hit point")
        }
    }
}

extension CartViewController: CartViewDelegate {
    func addNewItem(newItem: DonationItem) {
        cartItems.insertObject(newItem, atIndex: 0)
        self.updateCount(true)
        cartCollectionView.reloadData()
    }

    func getItemsCount() -> NSInteger {
        return self.cartItems.count
    }
}

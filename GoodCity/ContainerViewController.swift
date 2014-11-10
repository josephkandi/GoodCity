import UIKit

protocol ChildViewControllerDelegate {
    func scrollToCamera()
    func scrollToHistory()
}

class ContainerViewController: UIViewController, UIScrollViewDelegate, ChildViewControllerDelegate {

    @IBOutlet weak var containerScrollView: UIScrollView!
    // Header status bar hack
    var headerView: UIView!
    
    private var statusBarHidden = true
    var historyViewController: UIViewController?

    private let CART_VIEW_CONTROLLER_INDEX = 0
    private let CAMERA_VIEW_CONTROLLER_INDEX = 1
    private let HISTORY_VIEW_CONTROLLER_INDEX = 2

    var viewControllers = [UIViewController]()
    var activeViewController: UIViewController? {
        didSet(oldViewControllerOrNil) {
            if activeViewController == oldViewControllerOrNil? {
                return
            }
            if let oldVC = oldViewControllerOrNil {
                oldVC.willMoveToParentViewController(nil)
                oldVC.removeFromParentViewController()
            }
            if let newVC = activeViewController {
                self.addChildViewController(newVC)
                newVC.didMoveToParentViewController(self)
            }
        }
    }
    private var currentViewControllerIndex : Int!
    
    override func viewDidLoad() {
        println("------------In container view controller view did load")

        super.viewDidLoad()
        setupViewControllers()
        containerScrollView.delegate = self
        currentViewControllerIndex = CAMERA_VIEW_CONTROLLER_INDEX
        
        self.refreshDataFromServer()
    }

    func refreshDataFromServer() {
        self.refreshFacebookInfo()

        // We have a user now...so update the total donation value in the background
        ParseClient.sharedInstance.updateTotalDonationsValueInUserDefaults()
    }

    func refreshFacebookInfo() {
        ParseClient.sharedInstance.refreshUserInfoFromFacebookWithCompletion({ (dictionary, error) -> () in
            if let dict = dictionary {
                println("Got a successful response from Facebook...refreshing facebook info")
                GoodCityUser.currentUser?.updateFacebookInfo(dict)
            } else {
                println("Facebook user info dict is nil")
            }
        })

    }
    override func viewDidLayoutSubviews() {
        setupViewOffsets(currentViewControllerIndex)
    }

    func setupViewControllers() {
        println("------------In container view controller setup view controllers")

        // 1. Cart View Controller
        let cartViewController = CartViewController(nibName: "CartViewController", bundle: nil)
        cartViewController.delegate = self
        let navController = UINavigationController(rootViewController: cartViewController)
        viewControllers.append(navController)
        navController.view.frame = CGRectMake(0, 20, containerScrollView.frame.width, containerScrollView.frame.height-20)
        navController.view.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight;
        containerScrollView.addSubview(navController.view)
        
        // 2. Camera View Controller
        let cameraViewController = AVCamViewController(nibName: "AVCamViewController", bundle: nil)
        cameraViewController.cartViewDelegate = cartViewController
        cartViewController.cameraViewDelegate = cameraViewController
        viewControllers.append(cameraViewController)
        cameraViewController.view.frame = CGRectMake(0, 0, containerScrollView.frame.width, containerScrollView.frame.height)
        cameraViewController.view.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight;
        containerScrollView.addSubview(cameraViewController.view)

        // 3. History View Controller
        self.historyViewController = HistoryViewController(nibName: "HistoryViewController", bundle: nil)
        let navController2 = UINavigationController(rootViewController: historyViewController!)
        viewControllers.append(navController2)
        navController2.view.frame = CGRectMake(0, 20, containerScrollView.frame.width, containerScrollView.frame.height-20)
        navController2.view.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight;
        containerScrollView.addSubview(navController2.view)
        
        // header status bar hack
        headerView = UIView()
        headerView.backgroundColor = blueHighlight
        self.view.insertSubview(headerView, belowSubview: containerScrollView)
    }

    func setupViewOffsets(activeViewIndex: Int) {
        let containerSize = containerScrollView.bounds
        var offset = CGFloat(0)
        for controller in viewControllers {
            controller.view.frame.origin.x = offset * CGFloat(containerSize.width)
            offset += 1
        }
        containerScrollView.contentSize = CGSize(width: containerSize.width * 3, height: containerSize.height)
        scrollToViewController(activeViewIndex)
        headerView.frame = CGRectMake(0, 0, containerSize.width, 20)
    }

    func scrollToViewController(index: Int, animated: Bool = false) {
        if animated {
            UIView.animateWithDuration(0.4, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                self.containerScrollView.contentOffset = CGPoint(x: CGFloat(index) * self.containerScrollView.bounds.width, y: 0)
            }, completion: { (finished) -> Void in
                // do nothing here
            })
        }
        else {
            containerScrollView.contentOffset = CGPoint(x: CGFloat(index) * containerScrollView.bounds.width, y: 0)
        }
        activeViewController = viewControllers[index]
        currentViewControllerIndex = index
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    func launchHistoryView() {
        self.scrollToViewController(HISTORY_VIEW_CONTROLLER_INDEX)
    }

    func launchScheduleView() {
        self.scrollToViewController(HISTORY_VIEW_CONTROLLER_INDEX)
        let scheduleViewController = SchedulePickupViewController(nibName: "SchedulePickupViewController", bundle: nil)
        self.historyViewController?.navigationController?.presentViewController(scheduleViewController, animated: true, completion: nil)
    }

    func launchMapView() {
        self.scrollToViewController(HISTORY_VIEW_CONTROLLER_INDEX)
        let dropoffViewController = MapViewController(nibName: "MapViewController", bundle: nil)
        self.historyViewController?.navigationController?.presentViewController(dropoffViewController, animated: true, completion: nil)
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        let pageWidth = containerScrollView.frame.width
        let xOffset = containerScrollView.contentOffset.x
        var bar: Bool
        
        bar = !(xOffset == 0 || xOffset >= pageWidth * 2)

        if (bar != statusBarHidden) {
            statusBarHidden = bar
            let duration = statusBarHidden ? NSTimeInterval(0) :  NSTimeInterval(0.3)
            UIView.animateWithDuration(duration, animations: { () -> Void in
                self.setNeedsStatusBarAppearanceUpdate()
            })
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let pageWidth = containerScrollView.frame.width
        let xOffset = containerScrollView.contentOffset.x
        let index : Int = Int(xOffset / pageWidth)
        activeViewController = viewControllers[index]
        currentViewControllerIndex = index
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return statusBarHidden
    }
    
    // Delegate methods to handle child view controller callbacks
    func scrollToCamera() {
        scrollToViewController(CAMERA_VIEW_CONTROLLER_INDEX, animated: true)
    }
    func scrollToHistory() {
        scrollToViewController(HISTORY_VIEW_CONTROLLER_INDEX, animated: true)
    }
}

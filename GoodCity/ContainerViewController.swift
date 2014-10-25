import UIKit

class ContainerViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var containerScrollView: UIScrollView!
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
            if let newVC = activeViewController {
                self.addChildViewController(newVC)
                newVC.view.autoresizingMask = .FlexibleWidth | .FlexibleHeight
                
                // Assuming that the active view controller is always in the middle of 3 view controllers
                newVC.view.frame = containerScrollView.frame
                newVC.view.frame.origin.x += containerScrollView.frame.width

                containerScrollView.addSubview(newVC.view)
                newVC.didMoveToParentViewController(self)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        containerScrollView.delegate = self
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
        setupViewOffsets(1)
    }

    func setupViewControllers() {
        
        // 1. Cart View Controller
        let cartViewController = CartViewController(nibName: "CartViewController", bundle: nil)
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
        let headerView = UIView(frame: CGRectMake(0, 0, containerScrollView.frame.width, 20))
        headerView.backgroundColor = tintColor
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
    }

    func scrollToViewController(index: Int) {
        containerScrollView.contentOffset = CGPoint(x: CGFloat(index) * containerScrollView.bounds.width, y: 0)
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
    
    override func prefersStatusBarHidden() -> Bool {
        return statusBarHidden
    }
}

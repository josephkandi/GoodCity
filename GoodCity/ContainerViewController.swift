//
//  ContainerViewController.swift
//  GoodCity
//
//  Created by Yili Aiwazian on 10/10/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var containerScrollView: UIScrollView!
    var statusBarHidden = true
    var historyViewController: UIViewController?

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
        updateTotalDonationsValueInUserDefaults()
    }

    func updateTotalDonationsValueInUserDefaults() {
        PFCloud.callFunctionInBackground("totalDonations",
            withParameters: ["userId": GoodCityUser.currentUser().objectId]) { (result, error) -> Void in
            if error == nil {
                println("Result from Parse Cloud Code: \(result)")
                let userDefaults = NSUserDefaults(suiteName: "group.com.codepath.goodcity")
                userDefaults?.setDouble(result as Double, forKey: "total_donation_value")
            } else {
                println("Error from Parse Cloud Code: \(error)")
            }
        }
    }

    override func viewDidLayoutSubviews() {
        setupViewOffsets(activeViewIndex: 1)
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

    func setupViewOffsets(activeViewIndex: CGFloat = CGFloat(0)) {
        let containerSize = containerScrollView.bounds
        var offset = CGFloat(0)
        for controller in viewControllers {
            controller.view.frame.origin.x = offset * CGFloat(containerSize.width)
            offset += 1
        }
        containerScrollView.contentSize = CGSize(width: containerSize.width * 3, height: containerSize.height)
        
        // Scroll to the current offset for the active view
        containerScrollView.contentOffset = CGPoint(x: activeViewIndex * containerSize.width, y: 0)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    func launchScheduleView() {
        //TODO: Move to schedule view (either history view or actual calendar page)
    }

    func launchMapView() {
        let dropoffViewController = MapViewController(nibName: "MapViewController", bundle: nil)
        //dropoffViewController.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal

        self.historyViewController?.navigationController?.presentViewController(dropoffViewController, animated: true, completion: { () -> Void in
            println("launched the dropoff view controller")
        })
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        let pageWidth = containerScrollView.frame.width
        let xOffset = containerScrollView.contentOffset.x
        var bar: Bool
        
        if (xOffset == 0 || xOffset >= pageWidth*2) {
            bar = false
        }
        else {
            bar = true
        }
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

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
        self.view.backgroundColor = tintColor
        setupViewControllers()
        containerScrollView.delegate = self
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
        
        viewControllers.append(cameraViewController)
        cameraViewController.view.frame = CGRectMake(0, 0, containerScrollView.frame.width, containerScrollView.frame.height)
        cameraViewController.view.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight;
        containerScrollView.addSubview(cameraViewController.view)

        // 3. History View Controller
        let historyViewController = HistoryViewController(nibName: "HistoryViewController", bundle: nil)
        let navController2 = UINavigationController(rootViewController: historyViewController)
        viewControllers.append(navController2)
        navController2.view.frame = CGRectMake(0, 20, containerScrollView.frame.width, containerScrollView.frame.height-20)
        navController2.view.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight;
        containerScrollView.addSubview(navController2.view)
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

//
//  ScaleModalAnimator.swift
//  GoodCity
//
//  Created by Yili Aiwazian on 10/25/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

class ScaleModalAnimator: NSObject, UIViewControllerAnimatedTransitioning {
   
    var presenting: Bool?
    
    override init() {
        super.init()
        presenting = false
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.3
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        // Get the from and to view controllers from the context
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        
        // Set our ending frame. We'll modify this later if we have to
        var endFrame = CGRectMake(20, 20, 300, 300)
        
            fromViewController.view.userInteractionEnabled = false
            transitionContext.containerView().addSubview(fromViewController.view)
            transitionContext.containerView().addSubview(toViewController.view)
            
            var startFrame = endFrame
            startFrame.origin.x += 320
            
            toViewController.view.frame = startFrame
            
            UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                fromViewController.view.tintAdjustmentMode = UIViewTintAdjustmentMode.Dimmed
                toViewController.view.frame = endFrame
            }, completion: { (finished) -> Void in
                println("presented")
            })
    }
    
    
    /*- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.5f;
    }
    
    - (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    // Grab the from and to view controllers from the context
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    // Set our ending frame. We'll modify this later if we have to
    CGRect endFrame = CGRectMake(80, 280, 160, 100);
    
    if (self.presenting) {
    fromViewController.view.userInteractionEnabled = NO;
    
    [transitionContext.containerView addSubview:fromViewController.view];
    [transitionContext.containerView addSubview:toViewController.view];
    
    CGRect startFrame = endFrame;
    startFrame.origin.x += 320;
    
    toViewController.view.frame = startFrame;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
    fromViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
    toViewController.view.frame = endFrame;
    } completion:^(BOOL finished) {
    [transitionContext completeTransition:YES];
    }];
    }
    else {
    toViewController.view.userInteractionEnabled = YES;
    
    [transitionContext.containerView addSubview:toViewController.view];
    [transitionContext.containerView addSubview:fromViewController.view];
    
    endFrame.origin.x += 320;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
    toViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
    fromViewController.view.frame = endFrame;
    } completion:^(BOOL finished) {
    [transitionContext completeTransition:YES];
    }];
    }
    }*/
}

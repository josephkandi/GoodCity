//
//  DraggableItemImageView.swift
//  GoodCity
//
//  Created by Yili Aiwazian on 11/1/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

private let threshold: CGFloat = 100
private let overlayHeight: CGFloat = 75

protocol DraggableItemImageViewDelegate {
    func onApprove()
    func onReject()
}

class DraggableItemImageView: UIImageView {

    var cardInitialCenter: CGPoint!
    var panGesture: UIPanGestureRecognizer!
    var acceptedLabel: UILabel!
    var rejectedLabel: UILabel!
    var delegate: DraggableItemImageViewDelegate?
    
    var overlayContainer: UIView!
    var profilePhoto: UIImageView!
    var userName: UILabel!
    var itemDescription: UILabel!
    var conditionLabel: UILabel!
    
    override var frame: CGRect {
        didSet(oldFrameOrNil) {
            cardInitialCenter = CGPointMake(self.center.x, self.center.y)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        cardInitialCenter = CGPointMake(self.center.x, self.center.y)
        panGesture = UIPanGestureRecognizer()
        panGesture.addTarget(self , action: "onPanItem:")
        self.addGestureRecognizer(panGesture)
        self.layer.cornerRadius = 4
        self.layer.masksToBounds = true
        self.layer.borderColor = UIColor(white: 1, alpha: 0.5).CGColor
        self.layer.borderWidth = 1
        
        setupAcceptedLabel()
        setupRejectedLabel()
        
        acceptedLabel.alpha = 0
        rejectedLabel.alpha = 0
        
        self.contentMode = UIViewContentMode.ScaleAspectFill
        
        overlayContainer = UIView(frame: CGRectZero)
        overlayContainer.backgroundColor = UIColor(white: 1, alpha: 1)
        
        profilePhoto = UIImageView(frame: CGRectZero)
        profilePhoto.layer.masksToBounds = true
        
        userName = UILabel(frame: CGRectZero)
        userName.text = "Yili Aiwazian"
        userName.font = FONT_MEDIUM_14
        
        itemDescription = UILabel(frame: CGRectZero)
        itemDescription.text = "This is the item description."
        itemDescription.font = FONT_14
        itemDescription.numberOfLines = 1
        
        conditionLabel = UILabel(frame: CGRectZero)
        conditionLabel.text = "Lightly Used"
        conditionLabel.font = FONT_12
        conditionLabel.textColor = UIColor.lightGrayColor()
        
        overlayContainer.addSubview(profilePhoto)
        overlayContainer.addSubview(userName)
        overlayContainer.addSubview(itemDescription)
        overlayContainer.addSubview(conditionLabel)

        self.addSubview(overlayContainer)
    }
    
    func setItemDetails(item: DonationItem) {
        cleanupItemDetails()
        profilePhoto.fadeInImageFromURL(NSURL(string: item.user.profilePhotoUrlString)!, border: false)
        userName.text = item.user.firstName + " " + item.user.lastName
        itemDescription.text = item.itemDescription
        conditionLabel.text = item.condition
    }
    
    func cleanupItemDetails() {
        profilePhoto.image = nil
        userName.text = ""
        itemDescription.text = ""
        conditionLabel.text = ""
    }
    override func layoutSubviews() {
        overlayContainer.frame = CGRectMake(0, self.frame.height-overlayHeight, self.frame.width, overlayHeight)
        
        let bounds = overlayContainer.bounds
        var xOffset: CGFloat = 10
        var yOffset: CGFloat = 10
        
        profilePhoto.frame = CGRectMake(xOffset, (bounds.height-40)/2, 40, 40)
        profilePhoto.layer.cornerRadius = profilePhoto.frame.width / 2
        
        xOffset += profilePhoto.frame.width + 10
        userName.frame = CGRectMake(xOffset, yOffset, bounds.width-xOffset, 20)
        
        yOffset += userName.frame.height
        itemDescription.frame = CGRectMake(xOffset, yOffset, bounds.width-xOffset-10, 20)
        //itemDescription.sizeToFit()
        
        yOffset += itemDescription.frame.height
        conditionLabel.frame = CGRectMake(xOffset, yOffset, bounds.width-xOffset-10, 16)
    }
    
    func onPanItem(sender: UIPanGestureRecognizer) {
        let xOffset = sender.translationInView(self).x
        let yOffset = sender.translationInView(self).y
        let approved = xOffset > threshold
        let rejected = xOffset < -threshold
        
        if (sender.state == UIGestureRecognizerState.Began) {
            
        } else if (sender.state == UIGestureRecognizerState.Changed){
            let angle: CGFloat = xOffset/CGFloat(180 * M_PI)/2
            self.transform = CGAffineTransformRotate(CGAffineTransformIdentity, angle)
            self.center = CGPointMake(cardInitialCenter.x + xOffset, cardInitialCenter.y)
            
            if xOffset > threshold {
                showLabel(acceptedLabel)
                rejectedLabel.alpha = 0
            }
            else if xOffset < -threshold {
                showLabel(rejectedLabel)
                acceptedLabel.alpha = 0
            }
            
        } else if (sender.state == UIGestureRecognizerState.Ended) {
            
            UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                
                if !approved && !rejected {
                    self.center = self.cardInitialCenter
                    self.transform = CGAffineTransformIdentity
                    self.acceptedLabel.alpha = 0
                    self.rejectedLabel.alpha = 0
                }
                else {
                    let direction: CGFloat = xOffset > 0 ? 1 : -1
                    let angle: CGFloat = 320/CGFloat(180 * M_PI)/2 * direction
                    self.transform = CGAffineTransformRotate(CGAffineTransformIdentity, angle)
                    self.center = CGPointMake(self.cardInitialCenter.x + 320 * direction, self.cardInitialCenter.y)
                    self.alpha = 0
                }
                }, completion: { (finished) -> Void in
                    if approved {
                        self.delegate?.onApprove()
                    }
                    else if rejected {
                        self.delegate?.onReject()
                    }
            })
        }
    }
    
    func restoreImage() {
        self.center = cardInitialCenter
        self.transform = CGAffineTransformIdentity
        self.acceptedLabel.alpha = 0
        self.rejectedLabel.alpha = 0
    }
    
    func showLabel(label: UILabel) {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            label.alpha = 1
        })
    }
    
    func setupAcceptedLabel() {
        acceptedLabel = UILabel(frame: CGRectMake(20, 40, 150, 40))
        acceptedLabel.text = "ACCEPTED"
        acceptedLabel.textAlignment = .Center
        acceptedLabel.font = UIFont(name: "AvenirNext-Medium", size: 30)
        acceptedLabel.textColor = greenHighlight
        acceptedLabel.sizeToFit()
        acceptedLabel.frame = CGRectMake(acceptedLabel.frame.origin.x, acceptedLabel.frame.origin.y, acceptedLabel.frame.width + 20, acceptedLabel.frame.height+10)
        acceptedLabel.transform = CGAffineTransformRotate(CGAffineTransformIdentity, -300/CGFloat(180 * M_PI)/2)
        acceptedLabel.layer.cornerRadius = 4
        acceptedLabel.layer.borderColor = greenHighlight.CGColor
        acceptedLabel.layer.borderWidth = 2
        acceptedLabel.layer.masksToBounds = true
        self.addSubview(acceptedLabel)
    }
    
    func setupRejectedLabel() {
        let bounds = self.bounds
        rejectedLabel = UILabel(frame: CGRectMake(bounds.width-150-20, 40, 150, 40))
        rejectedLabel.text = "REJECTED"
        rejectedLabel.textAlignment = .Center
        rejectedLabel.font = UIFont(name: "AvenirNext-Medium", size: 30)
        rejectedLabel.textColor = redHighlight
        rejectedLabel.sizeToFit()
        
        let size = rejectedLabel.frame.size
        rejectedLabel.frame = CGRectMake(bounds.width-size.width-40, rejectedLabel.frame.origin.y, rejectedLabel.frame.width + 20, rejectedLabel.frame.height+10)
        rejectedLabel.transform = CGAffineTransformRotate(CGAffineTransformIdentity, 300/CGFloat(180 * M_PI)/2)
        rejectedLabel.layer.cornerRadius = 4
        rejectedLabel.layer.borderColor = redHighlight.CGColor
        rejectedLabel.layer.borderWidth = 2
        rejectedLabel.layer.masksToBounds = true
        self.addSubview(rejectedLabel)
    }
}

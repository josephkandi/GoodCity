//
//  YASegmentedControl.swift
//  GoodCity
//
//  Created by Yili Aiwazian on 10/21/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

private let gapWidth : CGFloat = 4
private let offWhite = offWhiteColor

class YASegmentedControl: UIView {

    var selectorView: UIView!
    var selectorInitialCenter: CGPoint!
    var panGesture: UIPanGestureRecognizer!
    
    var sectionTitles = [String]()
    var sectionTitleLabels: [UILabel]!
    var selectedSegmentIndex: Int = 1

    override init() {
        super.init()
        setup()
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
        self.backgroundColor = UIColor(white: 0.1, alpha: 0.7)
        self.layer.masksToBounds = true
        
        selectorView = UIView(frame: CGRectMake(0, 0, 100, self.frame.height))
        selectorView.backgroundColor = offWhite
        selectorView.layer.masksToBounds = true
        self.addSubview(selectorView)
        
        panGesture = UIPanGestureRecognizer()
        panGesture.addTarget(self, action: "onPanSelector:")
        selectorView.addGestureRecognizer(panGesture)
        
        selectorInitialCenter = selectorView.center
        
        setSectionTitles(["New", "Lightly\nUsed", "Heavily\nUsed"])
    }
    override func layoutSubviews() {
        let bounds = self.bounds
        self.layer.cornerRadius = bounds.height / 2
        
        if (sectionTitles.count > 0) {
            let selectorWidth : CGFloat = (bounds.width - gapWidth * 2) / CGFloat(sectionTitles.count)
            // Assuming the first item is selected
            let xOffset = gapWidth + selectorWidth * CGFloat(selectedSegmentIndex)
            selectorView.frame = CGRectMake(xOffset, gapWidth, selectorWidth, bounds.height-gapWidth*2)
            selectorView.layer.cornerRadius = selectorView.frame.height/2
            
            var index = 0
            for label in sectionTitleLabels {
                let xOffset = gapWidth + selectorWidth * CGFloat(index)
                label.frame = CGRectMake(xOffset, gapWidth, selectorWidth, bounds.height-gapWidth*2)
                index += 1
            }
        }
        selectorInitialCenter = selectorView.center
    }
    func setSectionTitles(titles:[String]) {
        for title in titles {
            sectionTitles.append(title)
        }
        sectionTitleLabels = [UILabel]()
        for title in titles {
            let label = UILabel()
            label.text = title
            label.textAlignment = .Center
            label.numberOfLines = 2
            label.font = FONT_MEDIUM_14
            sectionTitleLabels.append(label)
            self.addSubview(label)
        }
        formatSectionTitles()
    }
    
    private func formatSectionTitles() {
        var index = 0
        for label in sectionTitleLabels {
            if index == selectedSegmentIndex {
                label.textColor = blueHighlight
            }
            else {
                label.textColor = UIColor.lightTextColor()
            }
            index += 1
        }

    }

    func titleForSegmentAtIndex(index : Int) -> String {
        return sectionTitles[index]
    }
    
    func onPanSelector(sender: UIPanGestureRecognizer) {
        let xPos = sender.locationInView(selectorView).x
        let yPos = sender.locationInView(selectorView).y
    
        let xOffset = sender.translationInView(selectorView).x
        let yOffset = sender.translationInView(selectorView).y
        
        if (sender.state == UIGestureRecognizerState.Began) {
        } else if (sender.state == UIGestureRecognizerState.Changed){
            selectorView.center = CGPointMake(selectorInitialCenter.x + xOffset, selectorInitialCenter.y)
        } else if (sender.state == UIGestureRecognizerState.Ended) {
            UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                    self.moveToClosestSelection(self.selectorView.center.x)
                }, completion: { (finished) -> Void in
            })
            formatSectionTitles()
        }
    }
    
    private func moveToClosestSelection(xPos: CGFloat) {
        var index = selectedSegmentIndex
        var minDistance = self.bounds.width
        
        var i = 0
        for label in sectionTitleLabels {
            let x = label.center.x
            let d = xPos - x
            let distance = abs(d)
            if distance < minDistance {
                minDistance = distance
                index = i
            }
            i += 1
        }
        selectedSegmentIndex = index
        selectorView.center = sectionTitleLabels[index].center
        selectorInitialCenter = selectorView.center
    }
}

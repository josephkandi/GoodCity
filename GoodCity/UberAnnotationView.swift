//
//  UberAnnotationView.swift
//  GoodCity
//
//  Created by Nick Aiwazian on 11/1/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import Foundation
import MapKit

class UberAnnotationView : MKAnnotationView {

    private var _rotationAngle: Double = 90
    var rotationAngle: Double {
        get {
            return _rotationAngle
        }
        set {
            _rotationAngle = newValue
            self.markerImageView?.transform = CGAffineTransformMakeRotation(CGFloat(Double.degreesToRadians(newValue)))
            self.markerImageView?.setNeedsDisplay()
        }
    }

    private var markerImageView: UIImageView?

    override init!(annotation: MKAnnotation!, reuseIdentifier: String!) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        var myFrame = self.frame
        myFrame.size.width = 22
        myFrame.size.height = 43
        self.frame = myFrame
        self.opaque = false
        self.initImage()
        
        // Offset center point based on the annotation marker
        self.centerOffset = CGPointMake(-5, 10)
    }

    func initImage() {
        let markerImage = UIImage(named: "car")
        self.markerImageView = UIImageView(image: markerImage)
        self.addSubview(markerImageView!)
        //markerImageView!.transform = CGAffineTransformMakeRotation(1.57)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
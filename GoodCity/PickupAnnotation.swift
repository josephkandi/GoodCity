//
//  PickupAnnotation.swift
//  GoodCity
//
//  Created by Yili Aiwazian on 11/8/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit
import MapKit

class PickupAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var markerText: String {
        didSet(oldItemOrNil) {
            if markerLabel != nil {
                markerLabel.text = markerText
            }
        }
    }
    var title: String
    
    private var markerLabel: UILabel!
    
    init(markerText: String, title: String, coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        self.markerText = markerText
        self.title = title
    }
    
    var annotationView: MKAnnotationView {
        let annotationView = MKAnnotationView(annotation: self, reuseIdentifier: "dropoffAnnotation")
        annotationView.enabled = true
        annotationView.canShowCallout = true
        annotationView.image = UIImage(named: "uber_pickup")
        // Offset center point based on the annotation marker
        annotationView.centerOffset = CGPointMake(18, -33)
        
        markerLabel = UILabel(frame: CGRectMake(8,6,28,20))
        markerLabel.text = markerText
        markerLabel.textAlignment = NSTextAlignment.Center
        markerLabel.baselineAdjustment = UIBaselineAdjustment.AlignCenters
        markerLabel.font = FONT_MEDIUM_12
        markerLabel.textColor = UIColor.whiteColor()
        
        let minLabel = UILabel(frame: CGRectMake(8, 16, markerLabel.frame.width,  markerLabel.frame.height))
        minLabel.text = "MIN"
        minLabel.textAlignment = .Center
        minLabel.font = FONT_8
        minLabel.textColor = UIColor.whiteColor()
        
        annotationView.addSubview(markerLabel)
        annotationView.addSubview(minLabel)
        
        return annotationView
    }
    
    func setCoordinate(newCoordinate: CLLocationCoordinate2D) {
        self.coordinate = newCoordinate
    }

}

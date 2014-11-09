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
        annotationView.image = UIImage(named: "marker")
        
        markerLabel = UILabel(frame: CGRectMake(0,0,30,22))
        markerLabel.text = markerText
        markerLabel.textAlignment = NSTextAlignment.Center
        markerLabel.baselineAdjustment = UIBaselineAdjustment.AlignCenters
        markerLabel.font = FONT_MEDIUM_14
        markerLabel.textColor = UIColor.whiteColor()
        annotationView.addSubview(markerLabel!)
        
        return annotationView
    }
    
    func setCoordinate(newCoordinate: CLLocationCoordinate2D) {
        self.coordinate = newCoordinate
    }

}

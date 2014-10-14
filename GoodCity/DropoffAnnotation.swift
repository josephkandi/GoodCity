//
//  DropoffAnnotation.swift
//  GoodCity
//
//  Created by Yili Aiwazian on 10/12/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit
import MapKit

class DropoffAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var markerText: String
    var title: String
    
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
            
        let label = UILabel(frame: CGRectMake(0,0,30,22))
        label.text = markerText
        label.textAlignment = NSTextAlignment.Center
        label.baselineAdjustment = UIBaselineAdjustment.AlignCenters
        label.font = FONT_MEDIUM_14
        label.textColor = UIColor.whiteColor()
        annotationView.addSubview(label)
            
        return annotationView
    }
    
    func setCoordinate(newCoordinate: CLLocationCoordinate2D) {
        self.coordinate = newCoordinate
    }

}
//
//  GeoWayPoint.swift
//  Pixscape
//
//  Created by bils on 30/05/2018.
//  Copyright © 2018 Scape Technologies Limited. All rights reserved.
//

import MapKit

final class GeoWayPoint: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var color = UIColor.primary
    var size = CGSize(width: 10, height: 10)
    var title: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String = "") {
        self.coordinate = coordinate
        self.title = title
    }
}

//
//  ARViewController+MapViewDelegate.swift
//  Pixscape
//
//  Created by bils on 15/10/2018.
//  Copyright © 2018 Scape Technologies Limited. All rights reserved.
//

import MapKit

extension ARViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let tileOverlay = overlay as? MKTileOverlay {
            return MKTileOverlayRenderer(tileOverlay: tileOverlay)
        } else {
            return MKOverlayRenderer(overlay: overlay)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
        
        let identifier = "annotationViewId"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        } else {
            annotationView?.annotation = annotation
        }
        
        annotationView?.canShowCallout = false
        
        let title = annotationView?.annotation?.title
        
        if( title == "GPS") {
            annotationView?.image = #imageLiteral(resourceName: "cluster_dark")
        } else {
            annotationView?.image = #imageLiteral(resourceName: "cluster")
        }
        
        return annotationView
    }
}

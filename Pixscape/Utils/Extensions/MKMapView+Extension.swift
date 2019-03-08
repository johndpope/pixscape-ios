//
//  MKMapView+Extension.swift
//  Pixscape
//
//  Created by bils on 30/04/2018.
//  Copyright © 2018 Scape Technologies Limited. All rights reserved.
//

import MapKit

typealias Latitude = Double
typealias Longitude = Double

extension MKMapView {
    func getAltitude(for camera: FlyoverCamera) -> Double {
        return camera.configuration.altitude
    }
    
    func setAltitude(for camera: FlyoverCamera, and altitude: Double) {
        camera.configuration.altitude = altitude >= 2000.0 ? 2000.0 : altitude
    }
    
    func isFlyOverOn(for camera: FlyoverCamera) -> Bool {
        return camera.state == .started ? true : false
    }
    
    func toggleFlyOver(for camera: FlyoverCamera, on latitude: Latitude, and longitude: Latitude) {
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        if(camera.state == .stopped) {
            camera.start(flyover: location)
        } else {
            camera.stop()
            centerMap(on: GeoWayPoint(coordinate: location))
        }
    }
    
    func centerMap(on geoWayPoint: GeoWayPoint) {
        
        selectAnnotation(geoWayPoint, animated: true)
        
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(geoWayPoint.coordinate,
                                                                  regionRadius * 2.0,
                                                                  regionRadius * 2.0)
        setRegion(coordinateRegion, animated: true)
    }
    
    func addWayPoint(at latitude: Latitude,
                     and longitude: Longitude,
                     with title: String = "",
                     and subtitle: String = "" ) -> GeoWayPoint  {

        let annotation = GeoWayPoint(coordinate: CLLocationCoordinate2D(latitude: latitude,
                                                                        longitude: longitude),
                                     title: title)
        //annotation.subtitle = subtitle
        addAnnotation(annotation)
        
        return annotation
    }
    
    func removeWayPoint(at latitude: Latitude, and longitude: Latitude) {
        let annotation = GeoWayPoint(coordinate: CLLocationCoordinate2D(latitude: latitude,
                                                                        longitude: longitude))
        removeAnnotation(annotation)
    }
    
    func removeAllWayPoints() {
        removeAnnotations(annotations)
    }
}

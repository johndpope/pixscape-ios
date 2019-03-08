//
//  ARViewController+Setup.swift
//  Pixscape
//
//  Created by bils on 15/10/2018.
//  Copyright © 2018 Scape Technologies Limited. All rights reserved.
//

import ScapeKit
import MapKit

extension ARViewController {
    func layoutFrames() {
        arView.frame = view.bounds
        
        mapView?.anchorInCorner(.topRight, xPad: 10, yPad: 25, width: 110, height: 110)
        
        geoButton.anchorToEdge(.bottom, padding: 10, width: 70, height: 70)
        moreButton.anchorInCorner(.bottomRight, xPad: 10, yPad: 15, width: 40, height: 40)
    }
    
    func views() {
        view.addSubview(arView)
        
        setupMapView()
        
        view.addSubview(geoButton)
        view.addSubview(moreButton)
        
        moreButton.addOverlayView(to: view)
    }
    
    func setupMapView() {
        mapView = MKMapView()
        mapView?.frame = CGRect(x: 0,y: 0, width: 110, height: 110)
        mapView?.mapType = MKMapType.standard
        mapView?.isZoomEnabled = false
        mapView?.isScrollEnabled = false
        mapView?.roundCornersWithBorder([.allCorners], radius: 55, color: .primary, width: 3)
        mapView?.delegate = self
        
        view.addSubview(mapView!)
    }
    func bindings() {
        _ = tapMap
        mapView?.addGestureRecognizer(tapMap)
        geoButton.addTarget(self, action: #selector(ARViewController.getGeoPosition), for: .touchDown)
    }
    
    func cleanUp() {
        geoButton.removeTarget(nil, action: nil, for: .allEvents)
        
        mapView?.removeGestureRecognizer(tapMap)
        mapView?.removeFromSuperview()
        mapView?.delegate = nil
        mapView = nil
        
        arSession?.stopTracking()
        
        isInit = false
    }
    
    func setupAr() {
        arSession = scapeClient.arSession?.withArView(view: arView)
        arSession!.setDebugMode(false)
        arSession!.resetTracking()
    }
    
    func setupGeo() {
        scapeSession = scapeClient.scapeSession
    }
    
    func setupGpsPosition(location: CLLocation?) {
        // First remove previous gps waypoint on the map
        if let gpsPos = gpsPosition {
            self.mapView?.removeWayPoint(at: gpsPos.coordinate.latitude,
                                         and: gpsPos.coordinate.longitude)
        }
        
        // Then assign new position
        guard let location = location else { return }
        gpsPosition = location
        guard let gpsPosition = gpsPosition else { return }
        
        // Finally add the new gps waypoint
        if let wayPoint = self.mapView?.addWayPoint(at: gpsPosition.coordinate.latitude,
                                                    and: gpsPosition.coordinate.longitude,
                                                    with: "GPS") {
            self.mapView?.centerMap(on: wayPoint)
        }
    }
    
    func setupScapePosition(location: CLLocation?) {
        // First remove previous scape waypoint on the map
        if let scapePos = scapePosition {
            self.mapView?.removeWayPoint(at: scapePos.coordinate.latitude,
                                         and: scapePos.coordinate.longitude)
        }
        
        // Then assign new position
        guard let location = location else { return }
        scapePosition = location
        guard let scapePosition = scapePosition else { return }
        
        // Finally add the new scape waypoint
        if let wayPoint = self.mapView?.addWayPoint(at: scapePosition.coordinate.latitude,
                                                    and: scapePosition.coordinate.longitude,
                                                    with: "Scape") {
            self.mapView?.centerMap(on: wayPoint)
        }
    }
    
    @objc func revealFullMap() {
        radialPushViewController(MapViewController(gpsPosition: gpsPosition, scapePosition: scapePosition))
    }
    
    @objc func getGeoPosition(_ sender: UIGestureRecognizer) {
        self.scapeState = .scanning
        
        self.geoButton.isHidden = true
        self.moreButton.isHidden = true
        
        SwiftSpinner.show("Geopositioning in progress, stay still..")
            .addTapHandler({ [weak self] in
                if let `self` = self {
                    self.scapeSession?.stopFetch()
                    self.geoButton.isHidden = false
                    self.moreButton.isHidden = false
                }
                SwiftSpinner.hide()
                },
                           subtitle: "Tap here to stop geopositioning")
        
        scapeSession?.getMeasurements(SCKGeoSourceType.rawSensorsAndScapeVisionEngine, observer: self)
    }
    
    @objc func startGeoFetch(_ sender: UIGestureRecognizer) {
        SwiftSpinner.show("Geopositioning in progress, stay still..")
        scapeSession?.startFetch(SCKGeoSourceType.rawSensorsAndScapeVisionEngine, observer: self)
    }
    
    @objc func stopGeoFetch(_ sender: UIGestureRecognizer) {
        SwiftSpinner.hide()
        scapeSession?.stopFetch()
    }
}

//
//  ARViewController+GeoSessionObserver.swift
//  Pixscape
//
//  Created by bils on 15/10/2018.
//  Copyright © 2018 Scape Technologies Limited. All rights reserved.
//

import ScapeKit

extension ARViewController: SCKScapeSessionObserver {
    
    func onScapeSessionError(_ session: SCKScapeSession?, state: SCKScapeSessionState, message: String) {
        print("Scape session error: \(message)")
        
        scapeState = .idle
        
        DispatchQueue.main.async {
            if(state == SCKScapeSessionState.lockingPositionError) {
                SwiftSpinner.sharedInstance.title = "Geoposition cannot be locked, service unavailable in this area"
            }
            else {
                SwiftSpinner.sharedInstance.title = "Geoposition cannot be locked, try\nagain"
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4)) { [weak self] in
            guard let `self` = self else {
                return
            }
            
            SwiftSpinner.hide()
            self.geoButton.isHidden = false
            self.moreButton.isHidden = false
        }
    }
    
    func onDeviceLocationMeasurementsUpdated(_ session: SCKScapeSession?, measurements: SCKLocationMeasurements?) {
        if measurements == nil {
            return
        }
        
        let coordinates = "\(measurements?.coordinates?.latitude ?? 0.0) \(measurements?.coordinates?.longitude ?? 0.0) \(measurements?.altitude ?? 0.0) "
        print("Retrieving GPS coordinates: \(coordinates)")
        
        gpsPosition = CLLocation(latitude: measurements?.coordinates?.latitude ?? 0.0, longitude: measurements!.coordinates?.longitude ?? 0.0)
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else {
                return
            }
            
            self.setupGpsPosition(location: self.gpsPosition)
        }
    }
    
    func onScapeMeasurementsUpdated(_ session: SCKScapeSession?, measurements: SCKScapeMeasurements?) {
        if measurements?.measurementsStatus != SCKScapeMeasurementsStatus.resultsFound {
            return
        }
        
        let coordinates = "\(measurements?.coordinates?.latitude ?? 0.0) \(measurements?.coordinates?.longitude ?? 0.0) "
        print("Retrieving Scape Coordinates: \(coordinates)")
        
        scapeState = .idle
        
        scapePosition = CLLocation(latitude: measurements?.coordinates?.latitude ?? 0.0, longitude: measurements?.coordinates?.longitude ?? 0.0)
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else {
                return
            }
            
            vibrate()
            SwiftSpinner.sharedInstance.title = "Geoposition locked !"
            
            self.setupScapePosition(location: self.scapePosition)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1500)) { [weak self] in
            guard let `self` = self else {
                return
            }
            
            self.geoButton.isHidden = false
            self.moreButton.isHidden = false
            SwiftSpinner.hide()
        }
    }
    
    func onDeviceMotionMeasurementsUpdated(_ session: SCKScapeSession?, measurements: SCKMotionMeasurements?) {
    }
    
    func onCameraTransformUpdated(_ session: SCKScapeSession?, transform: [NSNumber]?) {
    }
    
}

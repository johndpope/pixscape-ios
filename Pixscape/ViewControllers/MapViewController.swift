//
//  MapViewController.swift
//  Pixscape
//
//  Created by bils on 30/04/2018.
//  Copyright © 2018 Scape Technologies Limited. All rights reserved.
//

import UIKit
import MapKit

final class MapViewController: UICircularViewController {
    
    private lazy var segmentedControl: BetterSegmentedControl = {
        let control = BetterSegmentedControl(
            frame: CGRect(x: 0.0, y: 0.0, width: 220, height: 44.0),
            titles: ["Standard", "Satellite", "Hybrid"],
            index: 1,
            options: [.backgroundColor(.primary),
                      .titleColor(.white),
                      .indicatorViewBackgroundColor(UIColor.primary.darken(percent: 0.2)),
                      .selectedTitleColor(.black),
                      .titleFont(UIFont(name: "AvenirNext-DemiBold", size: 14.0)!),
                      .selectedTitleFont(UIFont(name: "AvenirNext-Bold", size: 14.0)!),
                      .cornerRadius(20)])
        try? control.setIndex(0)
        return control
    }()
    
    private lazy var flyOverButton: JJFloatingActionButton = {
        let button = JJFloatingActionButton()
        button.buttonImage = imageWith(name: "360")
        button.buttonColor = .primary
        button.buttonImageColor = UIColor.secondary
        button.frame = CGRect.init(x: 0, y: 0, width: 40, height: 40)
        return button
    }()
    
    private lazy var closeButton: JJFloatingActionButton = {
        let button = JJFloatingActionButton()
        button.buttonImage = #imageLiteral(resourceName: "ic_close_white")
        button.buttonColor = .primary
        button.buttonImageColor = UIColor.secondary
        button.frame = CGRect.init(x: 0, y: 0, width: 40, height: 40)
        return button
    }()
    
    private lazy var mapView: MKMapView? = {
        let mappView = MKMapView()
        mappView.frame = UIScreen.main.bounds
        mappView.mapType = MKMapType.standard
        mappView.isZoomEnabled = true
        mappView.isScrollEnabled = true
        
        // Or, if needed, we can position map in the center of the view
        // mappView.center = view.center
        
        return mappView
    }()
    
    private lazy var legendContainer: UIView = {
        let view = UIView.init()
        view.backgroundColor = .secondary
        return view
    }()
    
    private lazy var gpsAnnotationView: UIImageView = {
        let view = UIImageView.init(image: #imageLiteral(resourceName: "cluster_dark"))
        return view
    }()
    
    private lazy var scapeAnnotationView: UIImageView = {
        let view = UIImageView.init(image: #imageLiteral(resourceName: "cluster"))
       
        return view
    }()
    
    private lazy var gpsAnnotationLabel: UILabel = {
       let label = UILabel.init()
        label.text = "GPS"
        label.font = UIFont.init(name: "AvenirNext-Regular", size: 12)
        return label
    }()
    
    private lazy var scapeAnnotationLabel: UILabel = {
        let label = UILabel.init()
        label.text = "Scape"
        label.font = UIFont.init(name: "AvenirNext-Regular", size: 12)
        return label
    }()
    
    private var flyoverCamera: FlyoverCamera?
    private var gpsPosition: CLLocation?
    private var scapePosition: CLLocation?
    
    private var isInit = false
    
    init(gpsPosition: CLLocation?, scapePosition: CLLocation?) {
        super.init(nibName: nil, bundle: nil)
        
        self.gpsPosition = gpsPosition
        self.scapePosition = scapePosition
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if(!isInit) {
            views()
            
            mapView?.delegate = self
            
            flyoverCamera = FlyoverCamera(mapView: self.mapView!)
            
            setupGpsPosition()
            setupScapePosition()
            
            isInit = true
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        cleanUp()
        
        super.viewDidDisappear(animated)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        layoutFrames()
    }
    
    private func layoutFrames() {
        let width: CGFloat = (Device.model == .iPhone5s || Device.model == .iPhoneSE) ? 200 : 220
        segmentedControl.anchorToEdge(.bottom, padding: 22, width: width, height: 44)
        
        flyOverButton.anchorInCorner(.bottomLeft, xPad: 10, yPad: 22, width: 40, height: 40)
        closeButton.anchorInCorner(.bottomRight, xPad: 10, yPad: 22, width: 40, height: 40)
        
        legendContainer.anchorInCorner(.topLeft, xPad: 10, yPad: 20, width: 100, height: 80)
        legendContainer.roundCornersWithBorder([.allCorners], radius: 20, color: .primary, width: 4)
        
        gpsAnnotationLabel.anchorInCorner(.topLeft, xPad: 10, yPad: 2, width: 60, height: 30)
        scapeAnnotationLabel.anchorInCorner(.bottomLeft, xPad: 10, yPad: 2, width: 60, height: 30)
        
        gpsAnnotationView.anchorInCorner(.topRight, xPad: 10, yPad: 3, width: 26, height: 33)
        scapeAnnotationView.anchorInCorner(.bottomRight, xPad: 10, yPad: 3, width: 26, height: 33)
    }
}

private extension MapViewController {
    func views() {
        if let mapView = mapView {
            view.addSubview(mapView)
            mapView.addSubview(segmentedControl)
            mapView.addSubview(flyOverButton)
            mapView.addSubview(closeButton)
            mapView.addSubview(legendContainer)
            
            legendContainer.addSubview(self.gpsAnnotationView)
            legendContainer.addSubview(self.scapeAnnotationView)
            legendContainer.addSubview(self.scapeAnnotationLabel)
            legendContainer.addSubview(self.gpsAnnotationLabel)
            
            segmentedControl.addTarget(self, action: #selector(MapViewController.controlValueChanged(_:)), for: .valueChanged)
            
            let flyTap = UITapGestureRecognizer(target: self, action: #selector(MapViewController.toggleFlyOver))
            flyOverButton.addGestureRecognizer(flyTap)
            
            let closeTap = UITapGestureRecognizer(target: self, action: #selector(UICircularViewController.radialPopViewController))
            closeButton.addGestureRecognizer(closeTap)
        }
    }
    
    func cleanUp() {
        flyoverCamera = nil
        
        mapView?.removeAllWayPoints()
        mapView?.delegate = nil
        mapView?.removeFromSuperview()
        mapView = nil
        
        isInit = false
    }
    
    func setupGpsPosition() {
        guard let `gpsPosition` = gpsPosition else { return }
        
        mapView?.removeWayPoint(at: gpsPosition.coordinate.latitude,
                                and: gpsPosition.coordinate.longitude)
        if let wayPoint = mapView?.addWayPoint(at: gpsPosition.coordinate.latitude,
                             and: gpsPosition.coordinate.longitude,
                             with: "GPS") {
             mapView?.centerMap(on: wayPoint)
        }
       
    }
    
    func setupScapePosition() {
        guard let scapePosition = scapePosition else { return }
        
        mapView?.removeWayPoint(at: scapePosition.coordinate.latitude,
                                and: scapePosition.coordinate.longitude)
        if let wayPoint = mapView?.addWayPoint(at: scapePosition.coordinate.latitude,
                             and: scapePosition.coordinate.longitude,
                             with: "Scape") {
            mapView?.centerMap(on: wayPoint)
        }
    }
}

extension MapViewController {
    @objc func toggleFlyOver() {
        guard let gpsPosition = gpsPosition else { return }
        
        try? segmentedControl.setIndex(0)
        
        guard let mapView = self.mapView else { return }
        
        mapView.toggleFlyOver(for: flyoverCamera!, on: gpsPosition.coordinate.latitude, and: gpsPosition.coordinate.longitude)
    }
    
    @objc func controlValueChanged(_ sender: Any) {
        guard let control = sender as? BetterSegmentedControl else { return }
        
        guard let mapView = self.mapView else { return }
        
        switch control.index {
        case 0:
            mapView.mapType = MKMapType.standard
        case 1:
            mapView.mapType = mapView.isFlyOverOn(for: flyoverCamera!) ? MKMapType.satelliteFlyover : MKMapType.satellite
        case 2:
            mapView.mapType = mapView.isFlyOverOn(for: flyoverCamera!) ? MKMapType.hybridFlyover : MKMapType.hybrid
        default:
            mapView.mapType = MKMapType.standard
        }
    }
}

extension MapViewController: MKMapViewDelegate {
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
        
        if(annotationView?.annotation?.title == "GPS") {
            annotationView?.image = #imageLiteral(resourceName: "cluster_dark")
        } else {
            annotationView?.image = #imageLiteral(resourceName: "cluster")
        }
        
        return annotationView
    }
}

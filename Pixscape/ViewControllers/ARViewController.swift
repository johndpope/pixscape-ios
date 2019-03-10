//
//  ViewController.swift
//  pixscape
//
//  Created by bils on 02/03/2018.
//  Copyright © 2018 Scape Technologies Limited. All rights reserved.
//

import ScapeKit
import MapKit

final class ARViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    lazy var arView: SCKArView = {
        return SCKArView()
    }()
    
    lazy var geoButton: JJFloatingActionButton = {
        let button = JJFloatingActionButton()
        button.buttonImage = #imageLiteral(resourceName: "ic_my_location_white")
        button.buttonColor = .primary
        button.buttonImageColor = UIColor.secondary
        return button
    }()
    
    lazy var moreButton: JJFloatingActionButton = {
        let button = JJFloatingActionButton()
        button.buttonImage = #imageLiteral(resourceName: "cm_more_horiz_white")
        button.buttonColor = .primary
        button.buttonImageColor = UIColor.secondary
        
        let settingsItem = button.addItem(title: "Settings", image: #imageLiteral(resourceName: "ic_settings_white"))
        settingsItem.buttonColor = UIColor.primary
        settingsItem.buttonImageColor = .secondary
        settingsItem.action = { [weak self] item in
            guard let `self` = self else { return }
            
            self.radialPushViewController(PermissionsViewController(scapeClient: self.scapeClient))
        }
        
        let privacyItem = button.addItem(title: "Terms & Privacy", image: #imageLiteral(resourceName: "ic_vpn_key_white"))
        privacyItem.buttonColor = UIColor.primary
        privacyItem.buttonImageColor = .secondary
        privacyItem.action = { [weak self] item in
            self?.radialPushViewController(TermsViewController())
        }
        
        return button
    }()
    
    lazy var tapMap: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(ARViewController.revealFullMap))
        tap.delegate = self
        return tap
    }()
    
    var mapView: MKMapView?
    
    var arSession: SCKArSession?
    var scapeSession: SCKScapeSession?
    
    var gpsPosition: CLLocation?
    var scapePosition: CLLocation?
    
    var isInit = false
    let network: NetworkManager = NetworkManager.sharedInstance
    var scapeState: ScapeState = .idle
    var scapeMeasurementsStatus: SCKScapeMeasurementsStatus = SCKScapeMeasurementsStatus.noResults
    
    var scapeClient: SCKScapeClient
    
    init(scapeClient: SCKScapeClient) {
        self.scapeClient = scapeClient
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)

        NetworkManager.isUnreachable(completed: { [weak self] _ in
            self?.scapeState = .offline
            SwiftSpinnerBlurred.show("You're offline, please enable your internet connection")
        })
        
        network.reachability.whenReachable = { [weak self] _ in
            if(self?.scapeState != .scanning) {
                SwiftSpinnerBlurred.hide()
            }
        }
        
        network.reachability.whenUnreachable = { [weak self] _ in
            self?.scapeState = .offline
            SwiftSpinnerBlurred.show("You're offline, please enable your internet connection")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.setHidesBackButton(true, animated: true)
        
        if(!isInit) {
            views()
            
            setupGpsPosition(location: gpsPosition)
            setupScapePosition(location: scapePosition)
            
            setupAr()
            setupGeo()
            
            bindings()
            
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
    
    @objc func didBecomeActive() {
        arSession?.resetTracking()
    }
    
    @objc func willEnterForeground() {
        
    }
}

extension ARViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // Allow subviews of a specific view to send touch events to the view's gesture recognizers.
        if let touchedView = touch.view, let gestureView = gestureRecognizer.view, touchedView.isDescendant(of: gestureView), touchedView !== gestureView {
            return true
        }
        return false
    }
}


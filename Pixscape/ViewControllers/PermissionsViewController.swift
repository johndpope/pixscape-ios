//
//  SettingsViewController.swift
//  Pixscape
//
//  Created by bils on 30/05/2018.
//  Copyright © 2018 Scape Technologies Limited. All rights reserved.
//

import UIKit
import ScapeKit

final class PermissionsViewController: PAPermissionsViewController {

    let locationCheck = PALocationPermissionsCheck()
    let cameraCheck = PACameraPermissionsCheck()
    
    private var scapeClient: SCKScapeClient
    
    init(scapeClient: SCKScapeClient) {
        self.scapeClient = scapeClient
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
        let permissions = [PAPermissionsItem.itemForType(.location, reason: PAPermissionDefaultReason)!,
                           PAPermissionsItem.itemForType(.camera, reason: PAPermissionDefaultReason)!]
        
        let handlers = [
            PAPermissionsType.location.rawValue: self.locationCheck,
            PAPermissionsType.camera.rawValue: self.cameraCheck]
        
        self.setupData(permissions, handlers: handlers)
        
        self.tintColor = UIColor.black
        self.backgroundImage = UIImage(color: .white, size: self.view.frame.size)
        self.useBlurBackground = false
        self.titleText = ""
        self.detailsText = "Pixscape needs the following permissions: "
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.setHidesBackButton(true, animated: true)
    }
}

extension PermissionsViewController : PAPermissionsViewControllerDelegate {
    func permissionsViewControllerDidContinue(_ viewController: PAPermissionsViewController) {
        if(isLocationEnabled() && isCameraEnabled()) {
            radialPushViewController(ARViewController(scapeClient: scapeClient))
        } else {
            UIAlertController.show(in: self, with: "Please enable all permissions before continuing")
        }
    }
}

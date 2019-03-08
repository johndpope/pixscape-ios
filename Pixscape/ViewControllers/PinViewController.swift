//
//  PinViewController.swift
//  Pixscape
//
//  Created by bils on 05/06/2018.
//  Copyright © 2018 Scape Technologies Limited. All rights reserved.
//

import UIKit
import ScapeKit

final class PinViewController: UIViewController {
    
    private lazy var pinCodeField: PinCodeField = {
       return PinCodeField()
    }()
    
    private lazy var enterPinLabel: UILabel = {
        let label = UILabel.init()
        label.text = "Enter the provided PIN below:"
        label.font = UIFont.init(name: "AvenirNext-DemiBold", size: 20)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
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
        
        view.backgroundColor = .white
        
        view.addSubview(enterPinLabel)
        view.addSubview(pinCodeField)
        
        pinCodeField.addTarget(self,
                               action: #selector(textFieldEditingDidChange(_:)),
                               for: UIControlEvents.editingChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        pinCodeField.becomeFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        layoutFrames()
    }
    
    private func layoutFrames() {
        pinCodeField.anchorInCenter(width: pinCodeField.intrinsicContentSize.width,
                                    height: pinCodeField.intrinsicContentSize.height)
        enterPinLabel.alignAndFill(align: .aboveCentered, relativeTo: pinCodeField, padding: 10)
    }
    
    @objc func textFieldEditingDidChange(_ sender: Any) {
        guard let pinCodeField = sender as? PinCodeField else { return }
        
        print("Pin code changed: " + pinCodeField.text)
        
        if pinCodeField.isFilled && pinCodeField.text != "4976" {
            vibrate()
            pinCodeField.shake()
            pinCodeField.text = ""
        }
        
        if pinCodeField.isFilled && pinCodeField.text == "4976" {
            pinCodeField.resignFirstResponder()
            
            print("Pin code entered.")
            
            var firstVC: UIViewController = PermissionsViewController(scapeClient: scapeClient)
            
            if isAppAlreadyLaunchedOnce() {
                if(isCameraEnabled() && isLocationEnabled()) {
                    firstVC = ARViewController(scapeClient: scapeClient)
                }
            }
            
            radialPushViewController(firstVC)
        }
    }
    
}

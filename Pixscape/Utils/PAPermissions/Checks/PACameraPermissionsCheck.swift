//
//  PACameraPermissionsCheck.swift
//  PAPermissionsApp
//
//  Created by Pasquale Ambrosini on 06/09/16.
//  Copyright © 2016 Pasquale Ambrosini. All rights reserved.
//

import AVFoundation
import UIKit

func isCameraEnabled() -> Bool {
    let defaults = UserDefaults.standard
    let isEmpty = defaults.string(forKey: "isCameraEnabled")?.isEmpty ?? true
    if isEmpty {
        return false
    } else {
        return true
    }
}

public class PACameraPermissionsCheck: PAPermissionsCheck {
    
	var mediaType = AVMediaType.video
	
	public override func checkStatus() {
		let currentStatus = self.status

		if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
			let authStatus = AVCaptureDevice.authorizationStatus(for: mediaType)
			switch authStatus {
			
			case .authorized:
				self.status = .enabled
                UserDefaults.standard.set(true, forKey: "isCameraEnabled")
			case .denied:
				self.status = .disabled
			case .notDetermined:
				self.status = .disabled
                UserDefaults.standard.set(false, forKey: "isCameraEnabled")
			default:
				self.status = .unavailable
			}
		}else{
			self.status = .unavailable
		}
		
		if self.status != currentStatus {
			self.updateStatus()
		}
	}
	
	public override func defaultAction() {
		if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
			
			if #available(iOS 8.0, *) {
				let authStatus = AVCaptureDevice.authorizationStatus(for: mediaType)
				if authStatus == .denied {
					self.openSettings()
				}else{
					AVCaptureDevice.requestAccess(for: mediaType, completionHandler: { (result) in
						if result {
							self.status = .enabled
						}else{
							self.status = .disabled
						}
					})
					self.updateStatus();
				}
			}else{
				//Camera access should be always active on iOS 7
			}
		}
		
		
	}
}

//
//  AppUtils.swift
//  Pixscape
//
//  Created by bils on 05/06/2018.
//  Copyright © 2018 Scape Technologies Limited. All rights reserved.
//

import AudioToolbox
import UIKit

func vibrate() {
    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
}

func imageWith(name: String) -> UIImage? {
    let frame = CGRect(x: 0, y: 0, width: 50, height: 50)
    let nameLabel = UILabel(frame: frame)
    nameLabel.textAlignment = .center
    nameLabel.backgroundColor = .primary
    nameLabel.textColor = .white
    nameLabel.font = UIFont.boldSystemFont(ofSize: 20)

    nameLabel.text = name
    UIGraphicsBeginImageContext(frame.size)
    if let currentContext = UIGraphicsGetCurrentContext() {
        nameLabel.layer.render(in: currentContext)
        let nameImage = UIGraphicsGetImageFromCurrentImageContext()
        return nameImage
    }
    return nil
}

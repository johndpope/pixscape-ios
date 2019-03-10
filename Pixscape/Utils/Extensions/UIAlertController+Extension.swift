//
//  UIAlertController+Extension.swift
//  Pixscape
//
//  Created by bils on 31/05/2018.
//  Copyright © 2018 Scape Technologies Limited. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    class func show(in viewController: UIViewController, with message: String) {
        
        let alert: UIAlertController = self.init(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK",
                                      style: UIAlertAction.Style.default,
                                     handler: { (alert: UIAlertAction!) in print("OK") }))
        
        DispatchQueue.main.async {
            viewController.present(alert, animated: true, completion: nil)
        }
    }
}

//
//  UIColor+Extension.swift
//  Pixscape
//
//  Created by bils on 30/04/2018.
//  Copyright © 2018 Scape Technologies Limited. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(_ hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    
    class var primary: UIColor {
        get {
            return UIColor("#00ffae")
        }
    }
    
    class var secondary: UIColor {
        get {
            return .white
        }
    }
    
    class var ternary: UIColor {
        get {
            return UIColor("#3d3c3a")
        }
    }
    
    /**
     Returns a lighter color by the provided percentage
     
     :param: lighting percent percentage
     :returns: lighter UIColor
     */
    func lighten(percent : Double) -> UIColor {
        return colorWithBrightnessFactor(factor: CGFloat(1 + percent));
    }
    
    /**
     Returns a darker color by the provided percentage
     
     :param: darking percent percentage
     :returns: darker UIColor
     */
    func darken(percent : Double) -> UIColor {
        return colorWithBrightnessFactor(factor: CGFloat(1 - percent));
    }
    
    /**
     Return a modified color using the brightness factor provided
     
     :param: factor brightness factor
     :returns: modified color
     */
    func colorWithBrightnessFactor(factor: CGFloat) -> UIColor {
        var hue : CGFloat = 0
        var saturation : CGFloat = 0
        var brightness : CGFloat = 0
        var alpha : CGFloat = 0
        
        if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            return UIColor(hue: hue, saturation: saturation, brightness: brightness * factor, alpha: alpha)
        } else {
            return self
        }
    }
    
    func toImage(size: CGSize, scale: CGFloat = 0) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        setFill()
        UIBezierPath(ovalIn: CGRect(origin: .zero, size: size)).fill()
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}


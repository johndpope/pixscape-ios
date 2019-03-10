//
//  UIView+Extension.swift
//  Pixscape
//
//  Created by bils on 30/05/2018.
//  Copyright © 2018 Scape Technologies Limited. All rights reserved.
//

import UIKit

extension UIView {
    
    enum ShakeDirection {
        case horizontal
        case vertical
    }
    
    enum ShakeAnimationType {
        case linear
        case easeIn
        case easeOut
        case easeInOut
    }
    
    func shake(direction: ShakeDirection = .horizontal, duration: TimeInterval = 1, animationType: ShakeAnimationType = .easeOut, completion:(() -> Void)? = nil) {
        
        CATransaction.begin()
        let animation: CAKeyframeAnimation
        switch direction {
        case .horizontal:
            animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        case .vertical:
            animation = CAKeyframeAnimation(keyPath: "transform.translation.y")
        }
        switch animationType {
        case .linear:
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        case .easeIn:
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        case .easeOut:
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        case .easeInOut:
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        }
        CATransaction.setCompletionBlock(completion)
        animation.duration = duration
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        layer.add(animation, forKey: "shake")
        CATransaction.commit()
    }
    
    public func addShadow(ofColor color: UIColor = .black,
                          radius: CGFloat = 5,
                          offset: CGSize = CGSize(width: 1, height: 1),
                          opacity: Float = 0.5) {
        layer.shadowColor = color.cgColor
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.masksToBounds = true
    }
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath

        self.layer.mask = mask
    }
    
    func roundCornersWithBorder(_ corners: UIRectCorner, radius: CGFloat, color: UIColor, width: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        
        self.layer.mask = mask
        
        let frameLayer = CAShapeLayer()
        frameLayer.frame = bounds
        frameLayer.path = path.cgPath
        frameLayer.strokeColor = color.cgColor
        frameLayer.fillColor = UIColor.clear.cgColor
        frameLayer.lineWidth = width
        
        //shadow for now
        frameLayer.masksToBounds = false
        frameLayer.shadowRadius = 2.0
        frameLayer.shadowOpacity = 0.2
        
        self.layer.addSublayer(frameLayer)
    }
    
    func blur(style: UIBlurEffect.Style) {
        var blurEffectView = UIVisualEffectView()
        let blurEffect = UIBlurEffect(style: style)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = bounds
        addSubview(blurEffectView)
        
        let vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
        addSubview(vibrancyView)
    }
    
    func removeBlur() {
        for view in self.subviews {
            if let view = view as? UIVisualEffectView {
                view.removeFromSuperview()
            }
        }
    }
}

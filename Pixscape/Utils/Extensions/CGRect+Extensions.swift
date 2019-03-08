//
//  CGRect+Extensions.swift
//  Compass
//

import CoreGraphics.CGBase

extension CGRect {
	public var center: CGPoint {
		return CGPoint(x: midX, y: midY)
	}
}

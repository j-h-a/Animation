//
//  Interpolation.swift
//  Animation
//
//  Created by Jay on 2016-09-16.
//  Copyright © 2016 Jay Abbott. All rights reserved.
//

import UIKit

public protocol Interpolatable {
	static func * (lhs: Self, rhs: Double) -> Self
	static func + (lhs: Self, rhs: Self) -> Self
}

extension Double: Interpolatable {}
extension CGPoint: Interpolatable {
	public static func *(lhs: CGPoint, rhs: Double) -> CGPoint {
		return CGPoint(x: lhs.x * CGFloat(rhs), y: lhs.y * CGFloat(rhs))
	}
	public static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
		return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
	}
}
extension UIColor: Interpolatable {
	public static func *(lhs: UIColor, rhs: Double) -> Self {
		var r = CGFloat(0), g = CGFloat(0), b = CGFloat(0), a = CGFloat(0)
		let t = CGFloat(rhs)
		lhs.getRed(&r, green: &g, blue: &b, alpha: &a)
		return self.init(red: r * t, green: g * t, blue: b * t, alpha: a * t)
	}
	public static func +(lhs: UIColor, rhs: UIColor) -> Self {
		var lhsR = CGFloat(0), lhsG = CGFloat(0), lhsB = CGFloat(0), lhsA = CGFloat(0)
		var rhsR = CGFloat(0), rhsG = CGFloat(0), rhsB = CGFloat(0), rhsA = CGFloat(0)
		lhs.getRed(&lhsR, green: &lhsG, blue: &lhsB, alpha: &lhsA)
		rhs.getRed(&rhsR, green: &rhsG, blue: &rhsB, alpha: &rhsA)
		return self.init(red: lhsR + rhsR, green: lhsG + rhsG, blue: lhsB + rhsB, alpha: lhsA + rhsA)
	}
}

public func lerp<T: Interpolatable>(from: T, to: T, alpha: Double) -> T {
	return (to * alpha) + (from * (1 - alpha))
}

precedencegroup InterpolationPrecedence {
	associativity: left
	higherThan: RangeFormationPrecedence
}
infix operator --> : InterpolationPrecedence

public func --> <T: Interpolatable>(from: T, alpha: Double) -> (T, Double) {
	return (from, alpha)
}

public func --> <T: Interpolatable>(lhs: (T, Double), rhs: T) -> T {
	return lerp(from: lhs.0, to: rhs, alpha: lhs.1)
}

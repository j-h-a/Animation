//
//  Curve.swift
//  Animation
//
//  Created by Jay on 2016-09-16.
//  Copyright © 2016 Jay Abbott. All rights reserved.
//

import Foundation

public typealias ParametricFunction = (Double) -> Double

public protocol Parametric {
	subscript(t: Double) -> Double { get }
}

private func curveEaseInEaseOut(_ t: Double) -> Double {
	switch t {
	case _ where t <= 0.0: return 0.0
	case _ where t >= 1.0: return 1.0
	default:
		// Equivalent to hermite curve with gradientIn and gradientOut both equal to zero
		// This is exactly the same as the internal 'h2' value from the hermite curve
		let t2 =  t * t
		let t3 = t2 * t
		return (3 * t2) - (2 * t3)
	}
}
private func curveEaseIn(_ t: Double) -> Double {
	switch t {
	case _ where t <= 0.0: return 0.0
	case _ where t >= 1.0: return t
	default:
		// Equivalent to hermite curve with gradientIn = 0 and gradientOut = 1
		// That is: h2 + h4
		let t2 =  t * t
		let t3 = t2 * t
		return	((3 * t2) - (2 * t3)) + (t3 - t2)
	}
}
private func curveEaseOut(_ t: Double) -> Double {
	switch t {
	case _ where t <= 0.0: return t
	case _ where t >= 1.0: return 1.0
	default:
		// Equivalent to hermite curve with gradientIn = 1 and gradientOut = 0
		// That is: h2 + h3
		let t2 =  t * t
		let t3 = t2 * t
		return ((3 * t2) - (2 * t3)) + (t3 - (2 * t2) + t)
	}
}
private func curveBell(_ t: Double) -> Double {
	switch t {
	case _ where t <= 0.0: return 0.0
	case _ where t >= 1.0: return 0.0
	case _ where t <= 0.5: return curveEaseInEaseOut(2 * t) // From 0.0 to 0.5 same as a full ease-in ease-out
	default: return curveEaseInEaseOut(2 - (2 * t)) // A reversed ease-in ease-out from 0.5 to 1.0
	}
}
private func curveParabolicAcceleration(_ t: Double) -> Double {
	switch t {
	case _ where t <= 0.0: return 0.0
	default: return t * t // Simple t-squared.
	}
}
private func curveParabolicDeceleration(_ t: Double) -> Double {
	switch t {
	case _ where t >= 1.0: return 1.0
	default: // Simple 1 - (1 - t)^2
		let oneMinusT = 1.0 - t
		return 1.0 - (oneMinusT * oneMinusT)
	}
}
private func curveParabolicPeak(_ t: Double) -> Double {
	switch t {
	case _ where t <= 0.5: return curveParabolicDeceleration(2 * t) // From 0.0 to 0.5 same as a full parabolic deceleration
	default: return curveParabolicDeceleration(2 - (2 * t)) // A reversed parabolic deceleration from 0.5 to 1.0
	}
}
private func curveParabolicBounce(_ t: Double) -> Double {
	switch t {
	case _ where t <= 0.0: return 0.0
	case _ where t >= 1.0: return 0.0
	case _ where t <= 0.5: return curveParabolicAcceleration(2 * t) // From 0.0 to 0.5 same as a full parabolic acceleration
	default: return curveParabolicAcceleration(2 - (2 * t)) // A reversed parabolic acceleration from 0.5 to 1.0
	}
}

open class Curve: Parametric {

	open static let zero                  = Curve(parametricFunction: {_ in return 0.0}) as Parametric
	open static let one                   = Curve(parametricFunction: {_ in return 1.0}) as Parametric
	open static let linear                = Curve(parametricFunction: {t in return t}) as Parametric
	open static let easeInEaseOut         = Curve(parametricFunction: curveEaseInEaseOut) as Parametric
	open static let easeIn                = Curve(parametricFunction: curveEaseIn) as Parametric
	open static let easeOut               = Curve(parametricFunction: curveEaseOut) as Parametric
	open static let bell                  = Curve(parametricFunction: curveBell) as Parametric
	open static let parabolicAcceleration = Curve(parametricFunction: curveParabolicAcceleration) as Parametric
	open static let parabolicDeceleration = Curve(parametricFunction: curveParabolicDeceleration) as Parametric
	open static let parabolicPeak         = Curve(parametricFunction: curveParabolicPeak) as Parametric
	open static let parabolicBounce       = Curve(parametricFunction: curveParabolicBounce) as Parametric

	fileprivate let pFunc: (Double) -> Double

	public init(parametricFunction: @escaping (Double) -> Double) {
		self.pFunc = parametricFunction
	}

	open subscript(t: Double) -> Double {
		return pFunc(t)
	}
}

open class HermiteCurve: Parametric {

	var gradientIn: Double
	var gradientOut: Double

	public init(gradientIn: Double, gradientOut: Double) {
		self.gradientIn = gradientIn
		self.gradientOut = gradientOut
	}

	public subscript(t: Double) -> Double {
		switch t {
		case _ where t <= 0.0: return t * gradientIn
		case _ where t >= 1.0: return ((t - 1.0) * gradientOut) + 1.0
		default:
			// Calculate the hermite functions h1-h4.
			// h1 is multiplied by zero at the end, so is ommitted but left in comments for clarity
			let _t2  =    t * t
			let _t3  =  _t2 * t
			let _3t2 =    3 * _t2
			let _2t3 =    2 * _t3
			//let h1 = _2t3 - _3t2      + 1
			let h2   = _3t2 - _2t3
			let h3   =  _t3 - (2 * _t2) + t
			let h4   =  _t3 - _t2
			return /* (h1 * 0) + */ (h2 * 1) + (h3 * gradientIn) + (h4 * gradientOut)
		}
	}
}

open class CompositeCurve: Parametric {
	public subscript(t: Double) -> Double {
		// TODO
		return 0
	}
}

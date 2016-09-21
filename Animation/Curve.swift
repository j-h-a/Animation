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

	private let startValue: Double
	private let segments: [Segment]

	private struct Segment {
		let endPoint: Double
		let endValue: Double
		let curve: Parametric
	}

	private class func add(segment: Segment, to segments: inout [Segment]) throws {

		let previousEndPoint = segments.last != nil ? segments.last!.endPoint : 0.0

		guard previousEndPoint < 1.0 else {
			throw ParseError.additionalCurveSegmentsBeyondOne
		}
		guard (segment.endPoint > 0.0) && (segment.endPoint <= 1.0) else {
			throw ParseError.endPointOutOfRange(message: "End point \(segment.endPoint) is outside the valid range: 0.0 < endPoint <= 1.0.")
		}
		guard segment.endPoint > previousEndPoint else {
			throw ParseError.endPointsNotIncreasing(message: "End point \(segment.endPoint), must be bigger than the previous end point \(previousEndPoint)")
		}

		segments.append(segment)
	}

	private class func internalInit(format: String, args: [Any]) throws -> (startValue: Double, segments: [Segment]) {

		guard format.characters.count == args.count else {
			throw ParseError.invalidNumberOfParameters
		}

		var specifiedStartValue: Double? = nil
		var tmpSegments = [Segment]()

		var idx: Int = 0
		for char in format.characters {
			switch char {
			case "S": // StartValue
				guard idx == 0 else {
					throw ParseError.startValueNotFirst(message: "If present, 'S' must be the first character of the format string. Found at index \(idx).")
				}
				guard let inputSV = args[idx] as? Double else {
					throw ParseError.invalidArgumentType(message: "The parameter for 'S' must be a Double.")
				}
				specifiedStartValue = inputSV
			case "L": // Linear
				guard let input = args[idx] as? (endPoint: Double, endValue: Double) else {
					throw ParseError.invalidArgumentType(message: "The parameter for 'L' must be (endPoint: Double, endValue: Double)")
				}
				try CompositeCurve.add(segment: Segment(endPoint: input.endPoint, endValue: input.endValue, curve: Curve.linear), to: &tmpSegments)
			case "E": // EaseInEaseOut
				guard let input = args[idx] as? (endPoint: Double, endValue: Double) else {
					throw ParseError.invalidArgumentType(message: "The parameter for 'E' must be (endPoint: Double, endValue: Double)")
				}
				try CompositeCurve.add(segment: Segment(endPoint: input.endPoint, endValue: input.endValue, curve: Curve.easeInEaseOut), to: &tmpSegments)
			case "I": // EaseIn
				guard let input = args[idx] as? (endPoint: Double, endValue: Double) else {
					throw ParseError.invalidArgumentType(message: "The parameter for 'I' must be (endPoint: Double, endValue: Double)")
				}
				try CompositeCurve.add(segment: Segment(endPoint: input.endPoint, endValue: input.endValue, curve: Curve.easeIn), to: &tmpSegments)
			case "O": // EaseOut
				guard let input = args[idx] as? (endPoint: Double, endValue: Double) else {
					throw ParseError.invalidArgumentType(message: "The parameter for 'O' must be (endPoint: Double, endValue: Double)")
				}
				try CompositeCurve.add(segment: Segment(endPoint: input.endPoint, endValue: input.endValue, curve: Curve.easeOut), to: &tmpSegments)
			case "H": // Hermite
				guard let input = args[idx] as? (endPoint: Double, endValue: Double, gradientIn: Double, gradientOut: Double) else {
					throw ParseError.invalidArgumentType(message: "The parameter for 'H' must be (endPoint: Double, endValue: Double, gradientIn: Double, gradientOut: Double)")
				}
				let hermite = HermiteCurve(gradientIn: input.gradientIn, gradientOut: input.gradientOut)
				try CompositeCurve.add(segment: Segment(endPoint: input.endPoint, endValue: input.endValue, curve: hermite), to: &tmpSegments)
			case "C": // Curve
				guard let input = args[idx] as? (endPoint: Double, endValue: Double, curve: Parametric) else {
					throw ParseError.invalidArgumentType(message: "The parameter for 'H' must be (endPoint: Double, endValue: Double, gradientIn: Double, gradientOut: Double)")
				}
				try CompositeCurve.add(segment: Segment(endPoint: input.endPoint, endValue: input.endValue, curve: input.curve), to: &tmpSegments)
			default:
				throw ParseError.invalidFormatCharacter(message: "'\(char)' is not a valid format character.")
			}

			idx += 1
		}

		guard tmpSegments.count > 0 else {
			throw ParseError.noCurveSegments
		}
		guard tmpSegments.last?.endPoint == 1.0 else {
			throw ParseError.finalEndPointNotOne
		}

		return (startValue: specifiedStartValue ?? 0.0, segments: tmpSegments)
	}



	// MARK: - Public interface



	public enum ParseError: Error {
		case invalidNumberOfParameters
		case invalidFormatCharacter(message: String)
		case invalidArgumentType(message: String)
		case startValueNotFirst(message: String)
		case endPointsNotIncreasing(message: String)
		case endPointOutOfRange(message: String)
		case additionalCurveSegmentsBeyondOne
		case finalEndPointNotOne
		case noCurveSegments
	}

	/** Creates a composite curve from a format string with parameters.

	The composite curve is made up from other curve segments, and parameterised
	from 0 - 1 across all segments. Just like with other curve types, the value
	of the curve at any point is obtained through Parametric interface.

	The first curve segment starts at 0.0 and ends at a	user-defined 'endPoint'
	where 0.0 < endPoint <= 1.0. Each subsequent segment starts at the end-point
	of the previous segment and continues until its own end-point (which must be
	greater than its start-point). The end-point of the last curve segment must be 1.0.

	Each segment also has a startValue and endValue, these determine the output value
	of the curve. The startValue is taken implicitly from the endValue for the previous
	curve segment, except for the first curve segment where it is specified separately
	(or defaults to 0.0), and each curve segment has an explicit endValue. This is the
	value of the curve at the end of the segment (i.e. when the input parameter is
	equal to the endPoint of this segment).

	Typically, if the output value of the curve is to be used for interpolation, then
	it should be between 0 and 1. For example if the output value is used as the input
	to another curve, or for a linear interpolation (LERP) done outside of the curve
	calculation. However, interpolation values outside the range 0 - 1 are still valid
	and result in extrapolated values, so startValue and endValue for each segment can
	be increasing, or decreasing, and can be greater than 1 or less than 0, these just
	determine the output value of the curve.

	A composite curve is constructed from a format string. Each character in the format
	string represents a segment of the curve (except for 'S' which represents the
	start-value of the first curve segment), the curve type is determined by the format
	character and its parameters are passed in as a tuple of values. So for each
	character in the format string there should be exactly one parameter passed in.
	The valid format characters and expected parameter types are listed below:

	````
	Format Character | Parameter Type
	-----------------+-------------------------------------------------------------
	S (StartValue)   | Double
	L (Linear)       | (endPoint: Double, endValue: Double)
	E (EaseInEaseOut)| (endPoint: Double, endValue: Double)
	I (EaseIn)       | (endPoint: Double, endValue: Double)
	O (EaseOut)      | (endPoint: Double, endValue: Double)
	H (Hermite)      | (endPoint: Double, endValue: Double, gradientIn: Double, gradientOut: Double)
	C (Curve)        | (endPoint: Double, endValue: Double, curve: Parametric)
	````

	If the start-value for the first curve segment is specified with 'S', it must be the
	first item in the format string and must only appear once. It defaults to 0.0 if not
	specified.
	
	Any violations of the requirements will result in a CompoundCurve.ParseError being thrown.

	- parameters:
	  - format: The format string for creating the curve
	  - args: The parameters for each character in the format string
	*/
	public init(format: String, _ args: Any...) throws {
		let initData = try CompositeCurve.internalInit(format: format, args: args)
		startValue = initData.startValue
		segments = initData.segments
	}

	/** Creates a composite curve from a format string with an array of parameters.

	Provides a way to initialise a composite curve from a programatically generated array
	of parameters. The parameters in the array should be the same types and in the same
	order as the parameters passed to the variadic version of this initialiser.

	- parameters:
	  - format: The format string for creating the curve
	  - args: An array containing one parameter for each character in the format string

	- seealso: init(format: String, args: Any...) throws
	*/
	public init(format: String, _ args: [Any]) throws {
		let initData = try CompositeCurve.internalInit(format: format, args: args)
		startValue = initData.startValue
		segments = initData.segments
	}

	public subscript(t: Double) -> Double {

		// guard segments.count > 0 else { return t } // Segment count cannot be 0

		var activeSegment: Segment
		var activeSegmentStartValue: Double
		var localT: Double

		switch t {
		case _ where segments.count == 1:
			// Use the only curve segment with a 1:1 mapping for t
			activeSegment = segments[0]
			activeSegmentStartValue = startValue
			localT = t
			// All other cases have at least 2 segments
		case _ where t <= 0.0:
			// Use the first curve segment with t extrapolated downwards
			activeSegment = segments[0]
			activeSegmentStartValue = startValue
			localT = t / activeSegment.endPoint
		case _ where t >= 1.0:
			// Use the last curve segment with t expanded to 0.0 - 1.0 between start point and end point
			let previousSegment = segments[segments.count - 2]
			let	startPoint = previousSegment.endPoint
			activeSegment = segments[segments.count - 1]
			activeSegmentStartValue = previousSegment.endValue;
			localT = (t - startPoint) / (activeSegment.endPoint - startPoint)
		default:
			// Binary search to find the active segment; where previousSegment.endPoint < t <= activeSegment.endPoint
			var minIdx: Int = 0
			var maxIdx: Int = segments.count - 1
			var startPoint: Double
			var endPoint: Double
			while(minIdx < maxIdx)
			{
				let midIdx = (minIdx + maxIdx) / 2
				startPoint = (midIdx == 0) ? 0.0 : segments[midIdx - 1].endPoint
				endPoint = segments[midIdx].endPoint
				// Check to see if t is between start/end or if we should keep searching
				if(t <= startPoint) {
					maxIdx = midIdx - 1 // Search lower
				} else if(t > endPoint) {
					minIdx = midIdx + 1 // Search higher
				} else {
					minIdx = midIdx; maxIdx = midIdx // We found our match
				}
			}

			let activeIdx = minIdx

			// Use the active curve segment with t expanded to 0.0 - 1.0 between start point and end point
			activeSegment = segments[activeIdx]
			activeSegmentStartValue = (activeIdx == 0) ? startValue : segments[activeIdx - 1].endValue
			startPoint              = (activeIdx == 0) ? 0.0        : segments[activeIdx - 1].endPoint
			localT = (t - startPoint) / (activeSegment.endPoint - startPoint)
		}

		return activeSegmentStartValue <~~ activeSegment.curve[localT] ~~> activeSegment.endValue
	}
}

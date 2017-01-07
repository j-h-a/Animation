//
//  CurveTests.swift
//  Animation
//
//  Created by Jay on 2016-09-18.
//  Copyright © 2016 Jay Abbott. All rights reserved.
//

import XCTest
import Animation

func sameSize(arrays: [[Any]]) -> Bool {
	if let first = arrays.first {
		let firstCount = first.count
		return !arrays.map({$0.count}).contains(where: {$0 != firstCount})
	}
	return true
}

let gradientLength = 0.00001
let gradientAccuracy = 0.0006

class CurveTests: XCTestCase {

	func doCurveTests(on curve: Parametric, inputs: [Double], expectedOutputs: [Double], expectedGradients: [Double]) {
		guard sameSize(arrays: [inputs, expectedOutputs, expectedGradients]) else {
			XCTFail("input arrays should be the same size")
			return
		}

		for i in 0..<inputs.count {
			let output = curve[inputs[i]]
			let bef = curve[inputs[i] - (gradientLength / 2)]
			let aft = curve[inputs[i] + (gradientLength / 2)]
			let gradient = (aft - bef) / gradientLength
			XCTAssertEqualWithAccuracy(output, expectedOutputs[i], accuracy: Double(FLT_EPSILON), "output for \(inputs[i]) should be \(expectedOutputs[i])")
			XCTAssertEqualWithAccuracy(gradient, expectedGradients[i], accuracy: gradientAccuracy, "gradient for \(inputs[i]) should be \(expectedGradients[i])")
		}
	}

	func testCurveOne() {
		doCurveTests(on: Curve.one,
		             inputs:            [-2.1, 0.0, 0.2, 0.5, 0.8, 1.0, 2.3],
		             expectedOutputs:   [ 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0],
		             expectedGradients: [ 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0])
	}

	func testCurveZero() {
		doCurveTests(on: Curve.zero,
		             inputs:            [-2.1, 0.0, 0.2, 0.5, 0.8, 1.0, 2.3],
		             expectedOutputs:   [ 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
		             expectedGradients: [ 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0])
	}

	func testCurveLinear() {
		doCurveTests(on: Curve.linear,
		             inputs:            [-1.1, 0.0, 0.2, 0.4, 0.6, 0.8, 1.0, 1.5],
		             expectedOutputs:   [-1.1, 0.0, 0.2, 0.4, 0.6, 0.8, 1.0, 1.5],
		             expectedGradients: [ 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0])
	}

	func testCurveEaseInEaseOut() {
		doCurveTests(on: Curve.easeInEaseOut,
		             inputs:            [-1.6, 0.0, 0.2  , 0.5, 0.8  , 1.0, 2.3],
		             expectedOutputs:   [ 0.0, 0.0, 0.104, 0.5, 0.896, 1.0, 1.0],
		             expectedGradients: [ 0.0, 0.0, 0.96 , 1.5, 0.96 , 0.0, 0.0])
	}

	func testCurveEaseIn() {
		doCurveTests(on: Curve.easeIn,
		             inputs:            [-2.1, 0.0, 0.2  , 0.5  , 0.8  , 1.0, 2.3],
		             expectedOutputs:   [ 0.0, 0.0, 0.072, 0.375, 0.768, 1.0, 2.3],
		             expectedGradients: [ 0.0, 0.0, 0.68 , 1.25 , 1.28 , 1.0, 1.0])
	}

	func testCurveEaseOut() {
		doCurveTests(on: Curve.easeOut,
		             inputs:            [-2.7, 0.0, 0.2  , 0.5  , 0.8  , 1.0, 2.2],
		             expectedOutputs:   [-2.7, 0.0, 0.232, 0.625, 0.928, 1.0, 1.0],
		             expectedGradients: [ 1.0, 1.0, 1.28 , 1.25 , 0.68 , 0.0, 0.0])
	}

	func testCurveBell() {
		doCurveTests(on: Curve.bell,
		             inputs:            [-1.3, 0.0, 0.1  , 0.4  , 0.5, 0.6  , 0.9  , 1.0, 1.7],
		             expectedOutputs:   [ 0.0, 0.0, 0.104, 0.896, 1.0, 0.896, 0.104, 0.0, 0.0],
		             expectedGradients: [ 0.0, 0.0, 1.92 , 1.92 , 0.0,-1.92 ,-1.92 , 0.0, 0.0])
	}

	func testCurveParabolicAcceleration() {
		doCurveTests(on: Curve.parabolicAcceleration,
		             inputs:            [-1.4, 0.0, 0.2 , 0.5 , 0.8 , 1.0, 1.9 ],
		             expectedOutputs:   [ 0.0, 0.0, 0.04, 0.25, 0.64, 1.0, 3.61],
		             expectedGradients: [ 0.0, 0.0, 0.4 , 1.0 , 1.6 , 2.0, 3.8 ])
	}

	func testCurveParabolicDeceleration() {
		doCurveTests(on: Curve.parabolicDeceleration,
		             inputs:            [-1.2 , 0.0, 0.2 , 0.5 , 0.8 , 1.0, 1.1],
		             expectedOutputs:   [-3.84, 0.0, 0.36, 0.75, 0.96, 1.0, 1.0],
		             expectedGradients: [ 4.4 , 2.0, 1.6 , 1.0 , 0.4 , 0.0, 0.0])
	}

	func testCurveParabolicPeak() {
		doCurveTests(on: Curve.parabolicPeak,
		             inputs:            [-0.3 , 0.0, 0.2 , 0.4 , 0.5, 0.6 , 0.8, 1.0, 1.4  ],
		             expectedOutputs:   [-1.56, 0.0, 0.64, 0.96, 1.0, 0.96, 0.64, 0.0,-2.24],
		             expectedGradients: [ 6.4 , 4.0, 2.4 , 0.8 , 0.0,-0.8 ,-2.4 ,-4.0,-7.2 ])
	}

	func testCurveParabolicBounce() {
		doCurveTests(on: Curve.parabolicBounce,
		             inputs:            [-1.5, 0.0, 0.2 , 0.3 , 0.5, 0.7 , 0.8 , 1.0, 2.5],
		             expectedOutputs:   [ 0.0, 0.0, 0.16, 0.36, 1.0, 0.36, 0.16, 0.0, 0.0],
		             expectedGradients: [ 0.0, 0.0, 1.6 , 2.4 , 0.0,-2.4 ,-1.6 , 0.0, 0.0])
	}

	func testHermiteCurve() {
		doCurveTests(on: HermiteCurve(gradientIn: 2, gradientOut: 1),
		             inputs:            [-1.0, 0.0, 0.2  , 0.5  , 0.8  , 1.0, 2.0],
		             expectedOutputs:   [-2.0, 0.0, 0.328, 0.625, 0.832, 1.0, 2.0],
		             expectedGradients: [ 2.0, 2.0, 1.32 , 0.75 , 0.72 , 1.0, 1.0])
		doCurveTests(on: HermiteCurve(gradientIn: 0.5, gradientOut: 3),
		             inputs:            [-1.0, 0.0, 0.2  , 0.5   , 0.8  , 1.0, 2.0],
		             expectedOutputs:   [-0.5, 0.0, 0.072, 0.1875, 0.528, 1.0, 4.0],
		             expectedGradients: [ 0.5, 0.5, 0.28 , 0.625 , 1.78 , 3.0, 3.0])
		doCurveTests(on: HermiteCurve(gradientIn: 4, gradientOut: 4),
		             inputs:            [-1.0, 0.0, 0.2  , 0.5, 0.8  , 1.0, 2.0],
		             expectedOutputs:   [-4.0, 0.0, 0.488, 0.5, 0.512, 1.0, 5.0],
		             expectedGradients: [ 4.0, 4.0, 1.12 ,-0.5, 1.12 , 4.0, 4.0])
		doCurveTests(on: HermiteCurve(gradientIn: -1, gradientOut: -1),
		             inputs:            [-1.0, 0.0, 0.1  , 0.2  , 0.5, 0.8  , 0.9  , 1.0, 2.0],
		             expectedOutputs:   [ 1.0, 0.0,-0.044, 0.008, 0.5, 0.992, 1.044, 1.0, 0.0],
		             expectedGradients: [-1.0,-1.0, 0.08 , 0.92 , 2.0, 0.92 , 0.08 ,-1.0,-1.0])
	}

	func testCompositeCurveThrowsInvalidNumberOfParameters() {
		let testData: [(fmt: String, args: [Any])] = [
			(fmt: "SL", args: [ 1.0, (endPoint: 1.0, endValue: 0.0),  3.0 ]),
			(fmt: "SL", args: [ 1.0,                                      ]),
			]
		for data in testData {
			do {
				try _ = CompositeCurve(format: data.fmt, data.args)
				XCTFail("CompositeCurve init should have thrown invalidNumberOfParameters with format string '\(data.fmt)' and \(data.args.count) parameters")
			} catch CompositeCurve.ParseError.invalidNumberOfParameters {
				// Expected error!
			} catch {
				XCTFail("Unexpected error: \(error)")
			}
		}

	}

	func testCompositeCurveThrowsParameterTypeErrors() {
		for char in "SLEIOADHC".characters {
			do {
				try _ = CompositeCurve(format: String(char), "string type not expected")
				XCTFail("CompositeCurve init should have thrown invalidArgumentType for \(char)")
			} catch CompositeCurve.ParseError.invalidArgumentType(_) {
				// Expected error!
			} catch {
				XCTFail("Unexpected error: \(error)")
			}
		}
	}

	func testCompositeCurveThrowsOnInvalidStartValue() {
		let testData: [(fmt: String, args: [Any])] = [
			(fmt: "SLS", args: [ 1.0,                             (endPoint: 1.0, endValue: 0.0),  3.0                            ]),
			(fmt: "LS" , args: [ (endPoint: 1.0, endValue: 0.0),  1.0                                                             ]),
			(fmt: "LSL", args: [ (endPoint: 0.5, endValue: 1.0),  0.0,                             (endPoint: 1.0, endValue: 0.0) ]),
			]
		for data in testData {
			do {
				try _ = CompositeCurve(format: data.fmt, data.args)
				XCTFail("CompositeCurve init should have thrown startValueNotFirst with format string '\(data.fmt)'")
			} catch CompositeCurve.ParseError.startValueNotFirst(_) {
				// Expected error!
			} catch {
				XCTFail("Unexpected error: \(error)")
			}
		}
	}

	func testCompositeCurveThrowsInvalidFormatCharacter() {
		let testData: [(fmt: String, args: [Any])] = [
			(fmt: "SLx", args: [ 1.0,                             (endPoint: 1.0, endValue: 0.0),  3.0                            ]),
			(fmt: "LLy", args: [ (endPoint: 0.5, endValue: 1.0),  (endPoint: 1.0, endValue: 0.0),  1.0                            ]),
			]
		for data in testData {
			do {
				try _ = CompositeCurve(format: data.fmt, data.args)
				XCTFail("CompositeCurve init should have thrown invalidFormatCharacter with format string '\(data.fmt)'")
			} catch CompositeCurve.ParseError.invalidFormatCharacter(_) {
				// Expected error!
			} catch {
				XCTFail("Unexpected error: \(error)")
			}
		}
	}

	func testCompositeCurveThrowsNoCurveSegments() {
		let testData: [(fmt: String, args: [Any])] = [
			(fmt: "",  args: [     ]),
			(fmt: "S", args: [ 1.0 ]),
			]
		for data in testData {
			do {
				try _ = CompositeCurve(format: data.fmt, data.args)
				XCTFail("CompositeCurve init should have thrown noCurveSegments with format string '\(data.fmt)'")
			} catch CompositeCurve.ParseError.noCurveSegments {
				// Expected error!
			} catch {
				XCTFail("Unexpected error: \(error)")
			}
		}
	}

	func testCompositeCurveThrowsFinalEndPointNotOne() {
		let testData: [(fmt: String, args: [Any])] = [
			(fmt: "SL",  args: [ 1.0,                             (endPoint: 0.5,  endValue: 0.0)                                    ]),
			(fmt: "LL" , args: [ (endPoint: 0.5, endValue: 0.1),  (endPoint: 0.99, endValue: 1.0)                                    ]),
			(fmt: "LLL", args: [ (endPoint: 0.5, endValue: 1.0),  (endPoint: 0.75, endValue: 0.0),  (endPoint: 0.999, endValue: 0.5) ]),
			]
		for data in testData {
			do {
				try _ = CompositeCurve(format: data.fmt, data.args)
				XCTFail("CompositeCurve init should have thrown finalEndPointNotOne")
			} catch CompositeCurve.ParseError.finalEndPointNotOne {
				// Expected error!
			} catch {
				XCTFail("Unexpected error: \(error)")
			}
		}
	}

	func testCompositeCurveThrowsAdditionalCurveSegmentsBeyondOne() {
		let testData: [(fmt: String, args: [Any])] = [
			(fmt: "LL" , args: [ (endPoint: 1.0, endValue: 0.5),  (endPoint: 1.0, endValue: 1.0)                                  ]),
			(fmt: "LLL", args: [ (endPoint: 0.5, endValue: 1.0),  (endPoint: 1.0, endValue: 0.0),  (endPoint: 0.3, endValue: 0.5) ]),
			]
		for data in testData {
			do {
				try _ = CompositeCurve(format: data.fmt, data.args)
				XCTFail("CompositeCurve init should have thrown additionalCurveSegmentsBeyondOne")
			} catch CompositeCurve.ParseError.additionalCurveSegmentsBeyondOne {
				// Expected error!
			} catch {
				XCTFail("Unexpected error: \(error)")
			}
		}
	}

	func testCompositeCurveThrowsEndPointsNotIncreasing() {
		let testData: [(fmt: String, args: [Any])] = [
			(fmt: "LL" , args: [ (endPoint: 0.5, endValue: 0.1),  (endPoint: 0.4, endValue: 1.0)                                  ]),
			(fmt: "LLL", args: [ (endPoint: 0.5, endValue: 1.0),  (endPoint: 0.6, endValue: 0.0),  (endPoint: 0.6, endValue: 0.5) ]),
			]
		for data in testData {
			do {
				try _ = CompositeCurve(format: data.fmt, data.args)
				XCTFail("CompositeCurve init should have thrown endPointsNotIncreasing")
			} catch CompositeCurve.ParseError.endPointsNotIncreasing(_) {
				// Expected error!
			} catch {
				XCTFail("Unexpected error: \(error)")
			}
		}
	}

	func testCompositeCurveThrowsEndPointOutOfRange() {
		let testData: [(fmt: String, args: [Any])] = [
			(fmt: "LL" , args: [ (endPoint: -0.5, endValue: 0.1),  (endPoint: 1.0, endValue: 1.0)                                  ]),
			(fmt: "LLL", args: [ (endPoint:  0.0, endValue: 1.0),  (endPoint: 0.5, endValue: 0.0),  (endPoint: 1.0, endValue: 0.5) ]),
			(fmt: "LLL", args: [ (endPoint:  0.1, endValue: 1.0),  (endPoint: 1.1, endValue: 0.0),  (endPoint: 1.0, endValue: 0.5) ]),
			]
		for data in testData {
			do {
				try _ = CompositeCurve(format: data.fmt, data.args)
				XCTFail("CompositeCurve init should have thrown endPointOutOfRange")
			} catch CompositeCurve.ParseError.endPointOutOfRange(_) {
				// Expected error!
			} catch {
				XCTFail("Unexpected error: \(error)")
			}
		}
	}

	func testCompositeCurve() {
		let testData: [(fmt: String, args: [Any], i: [Double], eO: [Double], eG: [Double])] = [
			(fmt: "H"    , args: [ (endPoint: 1.0, endValue: 1.0, gradientIn: 1.0, gradientOut: 1.0) ],
				i:  [-0.5, 0.0, 0.2, 0.5, 0.8, 1.0, 1.5],
				eO: [-0.5, 0.0, 0.2, 0.5, 0.8, 1.0, 1.5],
				eG: [ 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]),
			(fmt: "SEEE" , args: [ 0.5,
			                       (endPoint: 0.333333333333, endValue: 1.0),
			                       (endPoint: 0.666666666667, endValue: 0.0),
			                       (endPoint: 1.0           , endValue: 0.5) ],
				i:  [-0.5, 0.0, 0.166666666667, 0.333333333333, 0.5, 0.666666666667, 0.833333333333, 1.0, 1.5],
				eO: [ 0.5, 0.5, 0.75          , 1.0           , 0.5, 0.0           , 0.25          , 0.5, 0.5],
				eG: [ 0.0, 0.0, 2.25          , 0.0           ,-4.5, 0.0           , 2.25          , 0.0, 0.0]),
			(fmt: "CL"   , args: [ (endPoint: 0.5, endValue: 1.0, curve: Curve.parabolicAcceleration),
			                       (endPoint: 1.0, endValue: 0.75) ],
				i:  [-0.5, 0.0, 0.25, 0.49999, 0.75 , 1.0 , 1.5],
				eO: [ 0.0, 0.0, 0.25, 0.99996, 0.875, 0.75, 0.5],
				eG: [ 0.0, 0.0, 2.0 , 3.99999,-0.5  ,-0.5 ,-0.5]),
			(fmt: "IO"   , args: [ (endPoint: 0.5, endValue: 1.0),
			                       (endPoint: 1.0, endValue: 0.0) ],
				i:  [-0.5, 0.0, 0.25 , 0.49999, 0.75 , 1.0, 1.5],
				eO: [ 0.0, 0.0, 0.375, 0.99998, 0.375, 0.0, 0.0],
				eG: [ 0.0, 0.0, 2.5  , 2.0    ,-2.5  , 0.0, 0.0]),
			(fmt: "AD"   , args: [ (endPoint: 0.5, endValue: 1.0),
			                       (endPoint: 1.0, endValue: 0.0) ],
				i:  [-0.5, 0.0, 0.25, 0.49999, 0.75, 1.0, 1.5],
				eO: [ 0.0, 0.0, 0.25, 0.99996, 0.25, 0.0, 0.0],
				eG: [ 0.0, 0.0, 2.0 , 3.99999,-2.0 , 0.0, 0.0]),
			]
		for data in testData {
			do {
				let cCurve = try CompositeCurve(format: data.fmt, data.args)
				doCurveTests(on: cCurve, inputs: data.i, expectedOutputs: data.eO, expectedGradients: data.eG)
			} catch {
				XCTFail("Unexpected error: \(error)")
			}
		}
	}
}

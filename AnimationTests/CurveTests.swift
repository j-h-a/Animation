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

let gradientLength = 0.0002

class CurveTests: XCTestCase {

	func performTests(on curve: Parametric, inputs: [Double], expectedOutputs: [Double], expectedGradients: [Double]) {
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
			XCTAssertEqualWithAccuracy(gradient, expectedGradients[i], accuracy: 3 * gradientLength, "gradient for \(inputs[i]) should be \(expectedGradients[i])")
		}
	}

	func testCurveOne() {
		performTests(on: Curve.one,
		             inputs:            [-2.1, 0.0, 0.2, 0.5, 0.8, 1.0, 2.3],
		             expectedOutputs:   [ 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0],
		             expectedGradients: [ 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0])
	}
	func testCurveZero() {
		performTests(on: Curve.zero,
		             inputs:            [-2.1, 0.0, 0.2, 0.5, 0.8, 1.0, 2.3],
		             expectedOutputs:   [ 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
		             expectedGradients: [ 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0])
	}
	func testCurveLinear() {
		performTests(on: Curve.linear,
		             inputs:            [-1.1, 0.0, 0.2, 0.4, 0.6, 0.8, 1.0, 1.5],
		             expectedOutputs:   [-1.1, 0.0, 0.2, 0.4, 0.6, 0.8, 1.0, 1.5],
		             expectedGradients: [ 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0])
	}
	func testCurveEaseInEaseOut() {
		performTests(on: Curve.easeInEaseOut,
		             inputs:            [-1.6, 0.0, 0.2  , 0.5, 0.8  , 1.0, 2.3],
		             expectedOutputs:   [ 0.0, 0.0, 0.104, 0.5, 0.896, 1.0, 1.0],
		             expectedGradients: [ 0.0, 0.0, 0.96 , 1.5, 0.96 , 0.0, 0.0])
	}
	func testCurveEaseIn() {
		performTests(on: Curve.easeIn,
		             inputs:            [-2.1, 0.0, 0.2  , 0.5  , 0.8  , 1.0, 2.3],
		             expectedOutputs:   [ 0.0, 0.0, 0.072, 0.375, 0.768, 1.0, 2.3],
		             expectedGradients: [ 0.0, 0.0, 0.68 , 1.25 , 1.28 , 1.0, 1.0])
	}
	func testCurveEaseOut() {
		performTests(on: Curve.easeOut,
		             inputs:            [-2.7, 0.0, 0.2  , 0.5  , 0.8  , 1.0, 2.2],
		             expectedOutputs:   [-2.7, 0.0, 0.232, 0.625, 0.928, 1.0, 1.0],
		             expectedGradients: [ 1.0, 1.0, 1.28 , 1.25 , 0.68 , 0.0, 0.0])
	}
	func testCurveBell() {
		performTests(on: Curve.bell,
		             inputs:            [-1.3, 0.0, 0.1  , 0.4  , 0.5, 0.6  , 0.9  , 1.0, 1.7],
		             expectedOutputs:   [ 0.0, 0.0, 0.104, 0.896, 1.0, 0.896, 0.104, 0.0, 0.0],
		             expectedGradients: [ 0.0, 0.0, 1.92 , 1.92 , 0.0,-1.92 ,-1.92 , 0.0, 0.0])
	}
	func testCurveParabolicAcceleration() {
		performTests(on: Curve.parabolicAcceleration,
		             inputs:            [-1.4, 0.0, 0.2 , 0.5 , 0.8 , 1.0, 1.9 ],
		             expectedOutputs:   [ 0.0, 0.0, 0.04, 0.25, 0.64, 1.0, 3.61],
		             expectedGradients: [ 0.0, 0.0, 0.4 , 1.0 , 1.6 , 2.0, 3.8 ])
	}
	func testCurveParabolicDeceleration() {
		performTests(on: Curve.parabolicDeceleration,
		             inputs:            [-1.2 , 0.0, 0.2 , 0.5 , 0.8 , 1.0, 1.1],
		             expectedOutputs:   [-3.84, 0.0, 0.36, 0.75, 0.96, 1.0, 1.0],
		             expectedGradients: [ 4.4 , 2.0, 1.6 , 1.0 , 0.4 , 0.0, 0.0])
	}
	func testCurveParabolicPeak() {
		performTests(on: Curve.parabolicPeak,
		             inputs:            [-0.3 , 0.0, 0.2 , 0.4 , 0.5, 0.6 , 0.8, 1.0, 1.4  ],
		             expectedOutputs:   [-1.56, 0.0, 0.64, 0.96, 1.0, 0.96, 0.64, 0.0,-2.24],
		             expectedGradients: [ 6.4 , 4.0, 2.4 , 0.8 , 0.0,-0.8 ,-2.4 ,-4.0,-7.2 ])
	}
	func testCurveParabolicBounce() {
		performTests(on: Curve.parabolicBounce,
		             inputs:            [-1.5, 0.0, 0.2 , 0.3 , 0.5, 0.7 , 0.8 , 1.0, 2.5],
		             expectedOutputs:   [ 0.0, 0.0, 0.16, 0.36, 1.0, 0.36, 0.16, 0.0, 0.0],
		             expectedGradients: [ 0.0, 0.0, 1.6 , 2.4 , 0.0,-2.4 ,-1.6 , 0.0, 0.0])
	}

	func testHermiteCurve() {
		
		performTests(on: HermiteCurve(gradientIn: 2, gradientOut: 1),
		             inputs:            [-1.0, 0.0, 0.2  , 0.5  , 0.8  , 1.0, 2.0],
		             expectedOutputs:   [-2.0, 0.0, 0.328, 0.625, 0.832, 1.0, 2.0],
		             expectedGradients: [ 2.0, 2.0, 1.32 , 0.75 , 0.72 , 1.0, 1.0])
		performTests(on: HermiteCurve(gradientIn: 0.5, gradientOut: 3),
		             inputs:            [-1.0, 0.0, 0.2  , 0.5   , 0.8  , 1.0, 2.0],
		             expectedOutputs:   [-0.5, 0.0, 0.072, 0.1875, 0.528, 1.0, 4.0],
		             expectedGradients: [ 0.5, 0.5, 0.28 , 0.625 , 1.78 , 3.0, 3.0])
		performTests(on: HermiteCurve(gradientIn: 4, gradientOut: 4),
		             inputs:            [-1.0, 0.0, 0.2  , 0.5, 0.8  , 1.0, 2.0],
		             expectedOutputs:   [-4.0, 0.0, 0.488, 0.5, 0.512, 1.0, 5.0],
		             expectedGradients: [ 4.0, 4.0, 1.12 ,-0.5, 1.12 , 4.0, 4.0])
		performTests(on: HermiteCurve(gradientIn: -1, gradientOut: -1),
		             inputs:            [-1.0, 0.0, 0.1  , 0.2  , 0.5, 0.8  , 0.9  , 1.0, 2.0],
		             expectedOutputs:   [ 1.0, 0.0,-0.044, 0.008, 0.5, 0.992, 1.044, 1.0, 0.0],
		             expectedGradients: [-1.0,-1.0, 0.08 , 0.92 , 2.0, 0.92 , 0.08 ,-1.0,-1.0])
	}
}

//
//  InterpolationTests.swift
//  Animation
//
//  Created by Jay on 2016-09-17.
//  Copyright © 2016 Jay Abbott. All rights reserved.
//

import XCTest
@testable import Animation

class InterpolationTests: XCTestCase {

	func testInterpolationCGPoint() {

		let pA = CGPoint(x: -2, y: 20)
		let pB = CGPoint(x: 90, y: 20)
		let pC = CGPoint(x: 90, y: -2)
		let testData: [(p1: CGPoint, p2: CGPoint, alpha: Double, eX: CGFloat, eY: CGFloat)] = [
			//p1,p2,alpha,    eX,    eY
			(pA, pB, -0.5, -48.0,  20.0),
			(pA, pB,  0.0,  -2.0,  20.0),
			(pA, pB,  0.5,  44.0,  20.0),
			(pA, pB,  1.0,  90.0,  20.0),
			(pA, pB,  1.5, 136.0,  20.0),
			(pC, pA, -0.1,  99.2,  -4.2),
			(pC, pA,  0.0,  90.0,  -2.0),
			(pC, pA,  0.5,  44.0,   9.0),
			(pC, pA,  1.0,  -2.0,  20.0),
			(pC, pA,  1.1, -11.2,  22.2),
			]

		for data in testData {
			let result = data.p1 <~~ data.alpha ~~> data.p2
			XCTAssertEqualWithAccuracy(result.x, data.eX, accuracy: CGFloat(FLT_EPSILON))
			XCTAssertEqualWithAccuracy(result.y, data.eY, accuracy: CGFloat(FLT_EPSILON))
		}
	}

	func testInterpolationCGRect() {

		let rA = CGRect(x: 10, y: 20, width: 20, height: 40)
		let rB = CGRect(x: 90, y: 20, width: 30, height: 40)
		let rC = CGRect(x: 90, y: 80, width: 30, height: 50)
		let testData: [(r1: CGRect, r2: CGRect, alpha: Double, eX: CGFloat, eY: CGFloat, eW: CGFloat, eH: CGFloat)] = [
			//r1,r2,alpha,    eX,    eY,    eW,    eH
			(rA, rB, -0.5, -30.0,  20.0,  15.0,  40.0),
			(rA, rB,  0.0,  10.0,  20.0,  20.0,  40.0),
			(rA, rB,  0.5,  50.0,  20.0,  25.0,  40.0),
			(rA, rB,  1.0,  90.0,  20.0,  30.0,  40.0),
			(rA, rB,  1.5, 130.0,  20.0,  35.0,  40.0),
			(rC, rA, -0.1,  98.0,  86.0,  31.0,  51.0),
			(rC, rA,  0.0,  90.0,  80.0,  30.0,  50.0),
			(rC, rA,  0.5,  50.0,  50.0,  25.0,  45.0),
			(rC, rA,  1.0,  10.0,  20.0,  20.0,  40.0),
			(rC, rA,  1.1,   2.0,  14.0,  19.0,  39.0),
			]

		for data in testData {
			let result = data.r1 <~~ data.alpha ~~> data.r2
			XCTAssertEqualWithAccuracy(result.origin.x, data.eX, accuracy: CGFloat(FLT_EPSILON))
			XCTAssertEqualWithAccuracy(result.origin.y, data.eY, accuracy: CGFloat(FLT_EPSILON))
			XCTAssertEqualWithAccuracy(result.size.width, data.eW, accuracy: CGFloat(FLT_EPSILON))
			XCTAssertEqualWithAccuracy(result.size.height, data.eH, accuracy: CGFloat(FLT_EPSILON))
		}
	}

	func testInterpolationUIColor() {

		let cA = UIColor(red: 0.2, green: 0.8, blue: 0.5, alpha: 0.5)
		let cB = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
		let cC = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
		let testData: [(c1: UIColor, c2: UIColor, alpha: Double, eR: CGFloat, eG: CGFloat, eB: CGFloat, eA: CGFloat)] = [
			//c1,c2,alpha,   eR,   eG,   eB,   eA
			(cA, cB,  0.0, 0.20, 0.80, 0.50, 0.50),
			(cA, cB,  0.5, 0.10, 0.40, 0.25, 0.25),
			(cA, cB,  1.0, 0.00, 0.00, 0.00, 0.00),
			(cC, cA,  0.0, 1.00, 1.00, 1.00, 1.00),
			(cC, cA,  0.5, 0.60, 0.90, 0.75, 0.75),
			(cC, cA,  1.0, 0.20, 0.80, 0.50, 0.50),
			]

		for data in testData {
			let result = data.c1 <~~ data.alpha ~~> data.c2
			var resultR = CGFloat(0), resultG = CGFloat(0), resultB = CGFloat(0), resultA = CGFloat(0)
			result.getRed(&resultR, green: &resultG, blue: &resultB, alpha: &resultA)
			XCTAssertEqualWithAccuracy(resultR, data.eR, accuracy: CGFloat(FLT_EPSILON))
			XCTAssertEqualWithAccuracy(resultG, data.eG, accuracy: CGFloat(FLT_EPSILON))
			XCTAssertEqualWithAccuracy(resultB, data.eB, accuracy: CGFloat(FLT_EPSILON))
			XCTAssertEqualWithAccuracy(resultA, data.eA, accuracy: CGFloat(FLT_EPSILON))
		}
	}
}

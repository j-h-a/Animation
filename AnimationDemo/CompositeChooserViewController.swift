//
//  CompositeChooserViewController.swift
//  AnimationDemo
//
//  Created by Jay on 2017-01-07.
//  Copyright © 2017 Jay Abbott. All rights reserved.
//

import UIKit
import Animation

class CompositeChooserViewController: UIViewController {
	private typealias `Self` = CompositeChooserViewController

	var onApply: ((Parametric) -> Void)?

	public static func bouncing() -> Parametric {
		let optCurve = try? CompositeCurve(
			format: "CCCCCCCCC",
			(0.40, 1.00, Curve.parabolicAcceleration),
			(0.56, 0.68, Curve.parabolicDeceleration),
			(0.72, 1.00, Curve.parabolicAcceleration),
			(0.80, 0.84, Curve.parabolicDeceleration),
			(0.88, 1.00, Curve.parabolicAcceleration),
			(0.92, 0.92, Curve.parabolicDeceleration),
			(0.96, 1.00, Curve.parabolicAcceleration),
			(0.98, 0.96, Curve.parabolicDeceleration),
			(1.00, 1.00, Curve.parabolicAcceleration))
		guard let curve = optCurve else {
			return Curve.zero
		}
		return curve
	}
	public static func sproing() -> Parametric {
		let optCurve = try? CompositeCurve(
			format: "CCEEEEEEEEEEEEEEEEEEEI",
			(0.18, 1.00, Curve.parabolicAcceleration),
			(0.20, 1.10, Curve.parabolicDeceleration),
			(0.24, 0.90),
			(0.28, 1.09),
			(0.32, 0.91),
			(0.36, 1.08),
			(0.40, 0.92),
			(0.44, 1.07),
			(0.48, 0.93),
			(0.52, 1.06),
			(0.56, 0.94),
			(0.60, 1.05),
			(0.64, 0.95),
			(0.68, 1.04),
			(0.72, 0.96),
			(0.76, 1.03),
			(0.80, 0.97),
			(0.84, 1.02),
			(0.88, 0.98),
			(0.92, 1.01),
			(0.96, 0.99),
			(1.00, 1.00))
		guard let curve = optCurve else {
			return Curve.zero
		}
		return curve
	}
	public static func inflate() -> Parametric {
		let optCurve = try? CompositeCurve(
			format: "LLLLLLLLLL",
			(0.17, -0.1),
			(0.2, 0.2),
			(0.37, 0.1),
			(0.4, 0.4),
			(0.57, 0.3),
			(0.6, 0.6),
			(0.77, 0.5),
			(0.8, 0.8),
			(0.97, 0.7),
			(1.0, 1.00))
		guard let curve = optCurve else {
			return Curve.zero
		}
		return curve
	}
	public static func heartBeat() -> Parametric {
		let optCurve = try? CompositeCurve(
			format: "SLOEEHO", (0.5),
			(0.2, 0.5),
			(0.3, 1.0),
			(0.4, 0.6),
			(0.5, 0.95),
			(0.6, 0.6, 0.0, 0.025),
			(1.0, 0.5))
		guard let curve = optCurve else {
			return Curve.zero
		}
		return curve
	}

	private func apply(curve: Parametric) {
		onApply?(curve)
		self.dismiss(animated: true)
	}

	@IBAction func bouncingButtonPressed() {
		apply(curve: Self.bouncing())
	}

	@IBAction func sproingButtonPressed() {
		apply(curve: Self.sproing())
	}

	@IBAction func inflateButtonPressed() {
		apply(curve: Self.inflate())
	}

	@IBAction func heartBeatButtonPressed() {
		apply(curve: Self.heartBeat())
	}
}

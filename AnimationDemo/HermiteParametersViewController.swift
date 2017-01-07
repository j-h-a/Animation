//
//  HermiteParametersViewController.swift
//  AnimationDemo
//
//  Created by Jay on 2017-01-07.
//  Copyright © 2017 Jay Abbott. All rights reserved.
//

import UIKit

class HermiteParametersViewController: UIViewController {

	@IBOutlet var gradientInSlider: UISlider?
	@IBOutlet var gradientOutSlider: UISlider?
	@IBOutlet var gradientInField: UITextField?
	@IBOutlet var gradientOutField: UITextField?

	@IBAction func gradientInSliderChanged() {
		let gIn = Double(gradientInSlider!.value)
		gradientIn = round(gIn * 100) / 100.0
		gradientInField!.text = "\(gradientIn)"
	}

	@IBAction func gradientOutSliderChanged() {
		let gOut = Double(gradientOutSlider!.value)
		gradientOut = round(gOut * 100) / 100.0
		gradientOutField!.text = "\(gradientOut)"
	}

	@IBAction func applybuttonPressed() {
		onApply?(gradientIn, gradientOut)
		self.dismiss(animated: true)
	}

	var gradientIn = 0.0
	var gradientOut = 0.0

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		gradientInSlider?.value = Float(gradientIn)
		gradientOutSlider?.value = Float(gradientOut)
		gradientInSliderChanged()
		gradientOutSliderChanged()
	}

	func setGradients(in gIn: Double, out: Double) {
		gradientIn = gIn
		gradientOut = out
	}

	var onApply: ((Double, Double) -> Void)?
}

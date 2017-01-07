//
//  CurveViewController.swift
//  AnimationDemo
//
//  Created by Jay on 2017-01-07.
//  Copyright © 2017 Jay Abbott. All rights reserved.
//

import UIKit
import Animation

private let curveLeft: CGFloat = 0.1
private let curveWidth: CGFloat = 0.8
private let curveTop: CGFloat = 0.2
private let curveHeight: CGFloat = 0.3
private let demoLeft: CGFloat = curveLeft
private let demoWidth: CGFloat = curveWidth
private let demoTop: CGFloat = 0.5
private let demoHeight: CGFloat = 0.2
private let demoBoxSize = CGSize(width: 25, height: 25)
private let uiLeft: CGFloat = curveLeft
private let uiWidth: CGFloat = curveWidth
private let uiTop: CGFloat = 0.7
private let uiHeight: CGFloat = 0.2

class CurveViewController: UIViewController {

	@IBOutlet var changeHermiteButton: UIButton?
	@IBOutlet var changeCompositeButton: UIButton?

	var presetCurves = [
		"linear"                : Curve.linear,
		"easeInEaseOut"         : Curve.easeInEaseOut,
		"easeIn"                : Curve.easeIn,
		"easeOut"               : Curve.easeOut,
		"bell"                  : Curve.bell,
		"parabolicAcceleration" : Curve.parabolicAcceleration,
		"parabolicDeceleration" : Curve.parabolicDeceleration,
		"parabolicPeak"         : Curve.parabolicPeak,
		"parabolicBounce"       : Curve.parabolicBounce,
		] as [String : Parametric]

	var currentCurve: Parametric? {
		didSet {
			// Update the view.
			self.configureView(animated: true)
		}
	}

	private struct HermiteParameters {
		var gradientIn: Double
		var gradientOut: Double
	}
	private var hermiteParams = HermiteParameters(gradientIn: -2, gradientOut: -2)

	func setCurrentCurve(_ name: String) {
		switch name {
		case "hermite":
			self.currentCurve = HermiteCurve(gradientIn: hermiteParams.gradientIn, gradientOut: hermiteParams.gradientOut)
		case "composite":
			self.currentCurve = CompositeChooserViewController.bouncing()
		default:
			self.currentCurve = presetCurves[name]
		}
	}

	let numPoints = 71
	var points = [UIView]()
	let timerLine = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 100))
	let demoBox = UIView(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
	let demoImage1 = UIImageView(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
	let demoImage2 = UIImageView(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
	let demoImage3 = UIImageView(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
	let demoImage4 = UIImageView(frame: CGRect(x: 0, y: 0, width: 25, height: 25))

	private func installPointViews() {
		let curveRect = self.curveArea

		// Add the point views if required
		while(points.count < numPoints) {
			let newPoint = UIView(frame: CGRect(x: 0, y: 0, width: 3, height: 3))
			let (pos, col) = curveData(for: points.count, in: curveRect)
			newPoint.center = pos
			newPoint.backgroundColor = col
			self.view.addSubview(newPoint)
			points.append(newPoint)
		}

		// Add the timer line and demo box
		timerLine.backgroundColor = UIColor.red
		demoBox.backgroundColor = UIColor.green <~~ 0.5 ~~> UIColor.black
		self.view.addSubview(timerLine)
		self.view.addSubview(demoBox)
		self.view.sendSubview(toBack: timerLine)

		// Add the image views
		let image = UIImage(named: "BoxStar")
		demoImage1.image = image
		demoImage2.image = image
		demoImage3.image = image
		demoImage4.image = image
		self.view.addSubview(demoImage1)
		self.view.addSubview(demoImage2)
		self.view.addSubview(demoImage3)
		self.view.addSubview(demoImage4)
	}

	private var curveArea: CGRect {
		get {
			let viewSize = self.view.frame.size
			return CGRect(x: viewSize.width * curveLeft,
			              y: viewSize.height * curveTop,
			              width: viewSize.width * curveWidth,
			              height: viewSize.height * curveHeight)
		}
	}
	private var demoArea: CGRect {
		get {
			let viewSize = self.view.frame.size
			return CGRect(x: viewSize.width * demoLeft,
			              y: viewSize.height * demoTop,
			              width: viewSize.width * demoWidth,
			              height: viewSize.height * demoHeight)
		}
	}
	private var uiArea: CGRect {
		get {
			let viewSize = self.view.frame.size
			return CGRect(x: viewSize.width * uiLeft,
			              y: viewSize.height * uiTop,
			              width: viewSize.width * uiWidth,
			              height: viewSize.height * uiHeight)
		}
	}

	private func curveData(for point: Int, in rect: CGRect) -> (position: CGPoint, color: UIColor) {
		let curve = currentCurve ?? Curve.zero
		let xParam = Double(point) / Double(numPoints - 1)
		let yValue = curve[xParam]
		let pos = CGPoint(x: rect.origin.x + (rect.size.width * CGFloat(xParam)),
		                  y: rect.origin.y + (rect.size.height * CGFloat(1 - yValue)))
		let col = UIColor.blue <~~ yValue ~~> UIColor.black
		return (pos, col)
	}

	private func configureView(animated: Bool) {

		let curveRect = self.curveArea

		// Position each point in the curve
		for i in 0 ..< points.count {
			let pointView = points[i]
			let startPos = pointView.center
			let startCol = pointView.backgroundColor!
			let (endPos, endCol) = curveData(for: i, in: curveRect)

			switch(animated)
			{
			case true:
				Animation.animate(identifier: "point-\(i)", duration: 0.5, update: {
					(progress) -> Bool in
					pointView.center = startPos <~~ Curve.easeInEaseOut[progress] ~~> endPos
					pointView.backgroundColor = startCol <~~ progress ~~> endCol
					return true
				})
			case false:
				pointView.center = endPos
			}
		}

		// Position the image demos
		let demoArea = self.demoArea
		let left = Double(demoArea.minX)
		let right = Double(demoArea.maxX)
		let bottom = Double(demoArea.maxY - (demoBoxSize.height / 2))
		demoImage1.center = CGPoint(x: left <~~ 0.2 ~~> right, y: bottom)
		demoImage2.center = CGPoint(x: left <~~ 0.4 ~~> right, y: bottom)
		demoImage3.center = CGPoint(x: left <~~ 0.6 ~~> right, y: bottom)
		demoImage4.center = CGPoint(x: left <~~ 0.8 ~~> right, y: bottom)

		// Position any other UI elements
		changeCompositeButton?.isHidden = true
		changeHermiteButton?.isHidden = true
		let button =
			(currentCurve is HermiteCurve) ? changeHermiteButton :
				(currentCurve is CompositeCurve) ? changeCompositeButton : nil
		if let uiButton = button {
			let uiRect = self.uiArea
			let uiMiddle = CGPoint(x: uiRect.midX, y: uiRect.midY)
			let start = uiButton.center
			uiButton.isHidden = false
			Animation.animate(identifier: "uiElements", duration: 0.3, update: {
				(progress) -> Bool in
				uiButton.center = start <~~ Curve.easeInEaseOut[progress] ~~> uiMiddle
				return true
			})
		}

		// Animate the timer-line and demo box
		startDemoAnimation()
	}

	private func startDemoAnimation() {
		var lineRect = self.curveArea
		var lineEnd = lineRect
		lineEnd.origin.x = lineRect.origin.x + lineRect.width
		lineRect.size.width = 1
		lineEnd.size.width = 1

		var boxRect = self.demoArea
		boxRect.origin.y = boxRect.origin.y + (boxRect.height / 2) - (demoBoxSize.height / 2)
		var boxEnd = boxRect
		boxEnd.origin.x = boxRect.origin.x + boxRect.width - demoBoxSize.width
		boxRect.size = demoBoxSize
		boxEnd.size = demoBoxSize

		let curve = currentCurve ?? Curve.zero

		Animation.animate(identifier: "demoAnimation", duration: 3, update: {
			(progress) -> Bool in
			let curveVal = curve[progress]
			let maxAngle = Double.pi / 2.0
			// Timer-line animation (linear with progress)
			self.timerLine.frame = lineRect <~~ progress ~~> lineEnd
			// Demo box animation (left-to-right using curve value)
			self.demoBox.frame = boxRect <~~ curveVal ~~> boxEnd
			// Demo image animations (scale, inverse scale, rotation, inverse rotation)
			self.demoImage1.transform = CGAffineTransform(rotationAngle: CGFloat(0.0 <~~ curveVal ~~> maxAngle))
			self.demoImage2.transform = CGAffineTransform(scaleX: CGFloat(curveVal), y: CGFloat(curveVal))
			self.demoImage3.transform = CGAffineTransform(rotationAngle: CGFloat(maxAngle <~~ curveVal ~~> 0.0))
			self.demoImage4.transform = CGAffineTransform(scaleX: CGFloat(1.0 + curveVal), y: CGFloat(1.0 + curveVal))
			return true
			}, completion: {
				(_) in
				self.startDemoAnimation()
		})
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		self.installPointViews()
	}

	override func viewWillAppear(_ animated: Bool) {
		self.configureView(animated: false)
	}

	override func viewDidLayoutSubviews() {
		self.configureView(animated: true)
	}

	//: MARK - Segues

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if (segue.identifier == "showPopover") {
			switch segue.destination {
			case let hermiteVC as HermiteParametersViewController:
				hermiteVC.setGradients(in: hermiteParams.gradientIn, out: hermiteParams.gradientOut)
				hermiteVC.onApply = {
					[unowned self] (gIn, gOut) in
					self.hermiteParams.gradientIn = gIn
					self.hermiteParams.gradientOut = gOut
					self.setCurrentCurve("hermite")
				}
			case let compositeVC as CompositeChooserViewController:
				compositeVC.onApply = {
					[weak self] (curve) in
					self?.currentCurve = curve
				}
			default:
				break
			}
			return
		}
	}
}

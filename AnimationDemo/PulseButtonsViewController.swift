//
//  PulseButtonsViewController.swift
//  AnimationDemo
//
//  Created by Jay on 2017-01-12.
//  Copyright © 2017 Jay Abbott. All rights reserved.
//

import UIKit
import Animation

class PulseButtonsViewController: UIViewController, Animatable {

	@IBOutlet var b1: UIButton?
	@IBOutlet var b2: UIButton?

	let pulseCurve = try! CompositeCurve(
		format: "SEE",
		(     0.8),
		(0.5, 1.2),
		(1.0, 0.8))
	var para = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
		Animation.add(animatable: self)
		b1?.layer.cornerRadius = 8.0
		b2?.layer.cornerRadius = 8.0
    }

	public func update(by timeInterval: Double) {
		para += timeInterval * 0.6
		let a = CGFloat(pulseCurve[Curve.loop[para]]);
		let b = CGFloat(pulseCurve[Curve.loop[para + 0.5]]);
		b1?.transform = CGAffineTransform(scaleX: a, y: b)
		b2?.transform = CGAffineTransform(scaleX: b, y: a)
	}

	@IBAction func explodePressed(sender: UIButton) {
		let rect = sender.bounds
		let mid = sender.center
		// Create explosion animation
		for x in stride(from: mid.x - rect.size.width / 2, through: mid.x + rect.size.width / 2, by: 5) {
			for y in stride(from: mid.y - rect.size.height / 2, through: mid.y + rect.size.height / 2, by: 5) {
				let p = CGPoint(x: x, y: y) + CGPoint(x: CGFloat(arc4random_uniform(10)) - 5, y: CGFloat(arc4random_uniform(10)) - 5)
				let dp = p + (p - mid) * (1.0 + Double(arc4random_uniform(300)) / 100.0) + CGPoint(x: CGFloat(arc4random_uniform(30)) - 15, y: CGFloat(arc4random_uniform(30)) - 15)
				let v = UIView(frame: CGRect(x: p.x, y: p.y, width: 5, height: 5))
				v.backgroundColor = sender.backgroundColor
				v.center = p
				self.view.addSubview(v)
				let len = 3.0 + Double(arc4random_uniform(100)) / 50.0
				Animation.animateToEnd(identifier: "\(ObjectIdentifier(v))", duration: len, update: { progress in
					v.alpha = CGFloat(1.0 - progress)
					v.center = p <~~ Curve.parabolicDeceleration[progress * 0.6] ~~> dp
				}, completion: { _ in
					v.removeFromSuperview()
				})
			}
		}
		// Disable and animate the re-enabling of the button
		sender.isEnabled = false
		sender.alpha = 0.0
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(4)) {
			Animation.animateToEnd(identifier: "\(ObjectIdentifier(sender))", duration: 0.25, update: { progress in
				sender.alpha = CGFloat(progress)
			}, completion: { _ in
				sender.isEnabled = true;
			})
		}
	}
}

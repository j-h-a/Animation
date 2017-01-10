//
//  FoodHuntersViewController.swift
//  AnimationDemo
//
//  Created by Jay on 2017-01-08.
//  Copyright © 2017 Jay Abbott. All rights reserved.
//

import UIKit
import SpriteKit
import Animation

class FoodHuntersViewController: UIViewController {

	private class Food : SKSpriteNode, Animatable {

		private let frames: [SKTexture]

		private var pulsate = 0.0
		private var pulsateSpeed = 1.0
		private var moveSpeed = CGPoint.zero
		private let hunters: [Hunter]
		private var dying = false

		init(frames: [SKTexture], hunters: [Hunter]) {
			self.frames = frames
			pulsateSpeed = 1.0 + (Double(arc4random_uniform(1000)) / 1000.0)
			self.hunters = hunters
			super.init(texture: frames[0], color: UIColor.white, size: CGSize(width: 10.0, height: 10.0))
			blendMode = SKBlendMode.add

			// Kick off an animation to ramp the move speed down to 0 and make the object grow
			let initialMoveSpeed = CGPoint(x: CGFloat(arc4random_uniform(UInt32(21))) - 11, y: CGFloat(arc4random_uniform(UInt32(21))) - 11)
			Animation.animate(identifier: "\(ObjectIdentifier(self))-spread", duration: 5.0) { [weak self] progress in
				guard let sself = self else { return false }
				sself.moveSpeed = initialMoveSpeed <~~ Curve.parabolicDeceleration[progress] ~~> CGPoint.zero
				let growth = 8.0 <~~ progress ~~> 15.0
				sself.size = CGSize(width: growth, height: growth)
				return true
			}
		}
		required init?(coder aDecoder: NSCoder) {
			return nil
		}

		public func update(by timeInterval: Double) {
			// Pulsate
			pulsate += timeInterval * pulsateSpeed
			while pulsate > 1.0 {
				pulsate -= 1.0
			}
			self.texture = frames[Int(0.5 <~~ Curve.bell[pulsate] ~~> 5.5)]
			// Move
			self.position = self.position + (moveSpeed * timeInterval)
			// Send out a scent to the hunters
			if !dying {
				for hunter in hunters {
					hunter.smell(food: self)
				}
			}
		}

		public func remove() {
			dying = true
			Animation.animate(identifier: "\(ObjectIdentifier(self))-die", duration: 0.3, update: { [weak self] progress in
				guard let sself = self else { return false }
				sself.alpha = CGFloat(1.0 - progress)
				return true
			}, completion: { [weak self] finished in
				guard let sself = self else { return }
				sself.removeFromParent()
			})
		}
	}

	private class Hunter : SKSpriteNode, Animatable {

		private struct Limits {
			public let min: Double
			public let max: Double
		}
		private struct Constants {
			public static let radius = Limits(min: 5.0, max: 64.0)
			public static let speed = Limits(min: 1.0, max: 100.0)
			public static let rotationSpeed = Limits(min: 1.0, max: 8.0)
		}

		private let frames: [SKTexture]

		private var angle = 0.0
		private var chomp = 0.0
		private var radius = Constants.radius.min
		private weak var nearestFood: Food?
		private var nearestDist2 = Double.infinity
		private let others: [Hunter]

		init(frames: [SKTexture], color: UIColor, others: [Hunter]) {
			self.frames = frames
			self.others = others
			super.init(texture: frames[0], color: color, size: CGSize(width: radius * 2, height: radius * 2))
			self.colorBlendFactor = 1.0
		}
		required init?(coder aDecoder: NSCoder) {
			return nil
		}

		public func update(by timeInterval: Double) {
			let speedFactor = 1.0 - ((radius - Constants.radius.min) / (Constants.radius.max - Constants.radius.min))
			// Chomp
			chomp += (1.0 + speedFactor) * timeInterval
			while chomp > 1.0 {
				chomp -= 1.0
			}
			self.texture = frames[Int(0.5 <~~ Curve.bell[chomp] ~~> 8.5)]
			// Shrink
			if radius > Constants.radius.min {
				radius = max(radius - (1.0 * timeInterval), Constants.radius.min)
				self.size = CGSize(width: radius * 2, height: radius * 2)
			}
			// Rotate
			var rotSpeed: Double
			var targetPoint: CGPoint
			if let food = nearestFood {
				rotSpeed = Constants.rotationSpeed.min <~~ speedFactor ~~> Constants.rotationSpeed.max
				targetPoint = food.position
			} else {
				let sz = scene?.frame.size ?? CGSize.zero
				targetPoint = CGPoint(x: sz.width * 0.5, y: sz.height * 0.5)
				let ratio = (targetPoint - self.position).lengthSquared / Double(sz.width * sz.height * 0.35)
				rotSpeed = 0.1 <~~ Curve.easeInEaseOut[ratio] ~~> 5.0
			}
			angle += self.position.turnDirection(to: targetPoint, fromAngle: angle) * timeInterval * rotSpeed
			while angle < 0.0 {
				angle += Double.pi * 2.0
			}
			while angle > Double.pi * 2.0 {
				angle -= Double.pi * 2.0
			}
			self.zRotation = CGFloat(angle)
			// Move
			let forwardSpeed = Constants.speed.min <~~ Curve.parabolicDeceleration[speedFactor] ~~> Constants.speed.max
			self.position = self.position + (CGPoint(x: cos(angle), y: sin(angle)) * forwardSpeed * timeInterval)
			// Eat
			if let food = nearestFood {
				let toFood = food.position - self.position
				if toFood.lengthSquared < (radius * radius) {
					eat(food)
				}
			} else {
				nearestDist2 = Double.infinity
			}
			// Collide
			for other in others {
				let toThem = other.position - self.position
				let dist2 = toThem.lengthSquared
				let minSep2 = (radius + other.radius) * (radius + other.radius)
				if dist2 < minSep2 {
					let dist = sqrt(dist2)
					let minSep = sqrt(minSep2)
					let unit = toThem * (1.0 / dist)
					let pushBack = unit * (minSep - dist) * 0.5
					self.position = self.position - pushBack
					other.position = other.position + pushBack
				}
			}
		}

		private func eat(_ food: Food) {
			// Eat
			food.remove()
			nearestFood = nil
			nearestDist2 = Double.infinity
			// Grow
			radius = min(radius + 0.1, Constants.radius.max)
			self.size = CGSize(width: radius * 2, height: radius * 2)
		}

		public func smell(food: Food) {
			let distToFood2 = (food.position - self.position).lengthSquared
			if food === nearestFood {
				// Always update the distance if hunter thinks this is the nearest one, in case it is moving away from it
				nearestDist2 = distToFood2
			}
			if distToFood2 < (radius * radius) {
				eat(food)
			} else if distToFood2 < nearestDist2 {
				nearestFood = food
				nearestDist2 = distToFood2
			}
		}
	}

	private var hunters = [Hunter]()

	override func loadView() {
		let skView = SKView()
		skView.showsFPS = true
		skView.showsNodeCount = true
		skView.ignoresSiblingOrder = true
		self.view = skView
	}

	private var scene = SKScene()
	private var starball = [SKTexture]()
	private var muncher = [SKTexture]()

	override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

		let size = view.bounds.size
		let skView = view as! SKView
		scene = SKScene(size: size)
		scene.scaleMode = .resizeFill
		scene.backgroundColor = UIColor.black <~~ 0.2 ~~> UIColor.white
		skView.presentScene(scene)

		let starballAtlas = SKTextureAtlas(named: "starball")
		for name in starballAtlas.textureNames.sorted() {
			starball.append(starballAtlas.textureNamed(name))
		}
		let muncherAtlas = SKTextureAtlas(named: "muncher")
		for name in muncherAtlas.textureNames.sorted() {
			muncher.append(muncherAtlas.textureNamed(name))
		}

		for hunterCol in [UIColor.blue, UIColor.red, UIColor.green, UIColor.orange, UIColor.yellow] {
			let hunter = Hunter(frames: muncher, color: hunterCol, others: hunters)
			hunter.position = CGPoint(x: CGFloat(arc4random_uniform(UInt32(size.width))), y: CGFloat(arc4random_uniform(UInt32(size.height))))
			scene.addChild(hunter)
			Animation.add(animatable: hunter)
			hunters.append(hunter)
		}
    }

	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		for touch in touches {
			let food = Food(frames: starball, hunters: hunters)
			food.position = touch.location(in: scene)
			scene.addChild(food)
			Animation.add(animatable: food)
		}
	}
}


extension CGPoint {
	public static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
		return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
	}
	public var lengthSquared: Double {
		return Double((x * x) + (y * y))
	}
	public func angle(to: CGPoint) -> Double {
		return atan2(Double(to.y - y), Double(to.x - x))
	}
	public func turnDirection(to: CGPoint, fromAngle: Double) -> Double {
		let toAngle = self.angle(to: to)
		var diff = toAngle - fromAngle
		while diff < 0.0 {
			diff += Double.pi * 2
		}
		if diff < Double.pi {
			return 1.0
		}
		return -1.0
	}
}

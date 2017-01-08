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

		public let frames: [SKTexture]

		private var pulsate = 0.0
		private var pulsateSpeed = 0.0
		private var moveSpeed = CGPoint.zero

		init(frames: [SKTexture]) {
			self.frames = frames
			pulsateSpeed = 1.0 + (Double(arc4random_uniform(1000)) / 1000.0)
			super.init(texture: frames[0], color: UIColor.white, size: CGSize(width: 10.0, height: 10.0))
			blendMode = SKBlendMode.add

			// Kick off an animation to ramp the move speed down to 0 and make the object grow
			let initialMoveSpeed = CGPoint(x: CGFloat(arc4random_uniform(UInt32(21))) - 11, y: CGFloat(arc4random_uniform(UInt32(21))) - 11)
			Animation.animate(identifier: "\(ObjectIdentifier(self))", duration: 5.0) { [weak self] progress in
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
			let i = Int(0.5 <~~ Curve.bell[pulsate] ~~> 5.5)
			self.texture = frames[i]
			// Move
			self.position = self.position + (moveSpeed * timeInterval)
		}
	}

	override func loadView() {
		let skView = SKView()
		skView.showsFPS = true
		skView.showsNodeCount = true
		skView.ignoresSiblingOrder = true
		self.view = skView
	}

	private var scene = SKScene()
	private var atlas = SKTextureAtlas()
	private var starball = [SKTexture]()

	override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

		let size = view.bounds.size
		let skView = view as! SKView
		scene = SKScene(size: size)
		scene.scaleMode = .resizeFill
		scene.backgroundColor = UIColor.black
		skView.presentScene(scene)

		atlas = SKTextureAtlas(named: "starball")
		for name in atlas.textureNames.sorted() {
			starball.append(atlas.textureNamed(name))
		}
    }

	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		for touch in touches {
			let food = Food(frames: starball)
			food.position = touch.location(in: scene)
			scene.addChild(food)
			Animation.add(animatable: food)
		}
	}
}

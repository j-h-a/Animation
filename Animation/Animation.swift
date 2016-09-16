//
//  Animation.swift
//  Animation
//
//  Created by Jay on 2016-09-16.
//  Copyright © 2016 Jay Abbott. All rights reserved.
//

import Foundation
import QuartzCore

public typealias AnimationUpdate = (Double) -> Bool
public typealias AnimationCompletion = (Bool) -> Void

public protocol Animatable {
	func update(by timeInterval: Double) -> Void
}

private class AnimationItem
{
	open var time: Double
	open let endTime: Double
	open let update: AnimationUpdate
	open let completion: AnimationCompletion?

	init(duration: Double, update: @escaping AnimationUpdate, completion: AnimationCompletion? = nil) {
		self.time = 0
		self.endTime = duration
		self.update = update
		self.completion = completion
	}
}

open class Animation
{
	fileprivate static var sharedInstance = Animation()

	fileprivate var animationItems = [String : AnimationItem]()
	fileprivate let displayLink: CADisplayLink?
	fileprivate var toAdd = [Animatable]()
	fileprivate var toRemove = [Animatable]()
	fileprivate var animatables = [Animatable]()

	fileprivate class Updater
	{
		var animationInstance: Animation?

		@objc open func displayLinkUpdate(_ link: CADisplayLink) -> Void {
			animationInstance?.update(link)
		}
	}

	fileprivate init() {
		let updater = Updater()
		displayLink = CADisplayLink(target: updater, selector: #selector(Updater.displayLinkUpdate(_:)))
		displayLink?.isPaused = true
		displayLink?.frameInterval = 1
		displayLink?.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
		updater.animationInstance = self
	}

	func update(_ link: CADisplayLink) -> Void {
		// Calculate the time delta
		let timeDelta = link.duration * Double(link.frameInterval)

		// Update the active animations
		updateAnimationItems(timeDelta)

		// Update the registered animatables
		updateAnimatableItems(timeDelta)

		// Stop the animation updates if there are no current animations
		if((toAdd.count + animatables.count + animationItems.count) == 0) {
			displayLink?.isPaused = true
		}
	}

	fileprivate func updateAnimationItems(_ timeDelta: Double) {
		// The dictionary might be modified by the animation
		// blocks so enumerate in a way that allows mutation
		for key in animationItems.keys {
			// Get the item and check if it is still present
			guard let item = animationItems[key] else { continue }

			var animComplete = false
			var animContinue = false

			// Increment the time
			item.time += timeDelta

			// Call the update block with the current progress of the animation
			if(item.time >= item.endTime)
			{
				item.update(1.0)
				animComplete = true
			}
			else
			{
				animContinue = item.update(item.time / item.endTime)
			}
			// If the animation is finished...
			if(animComplete || !animContinue)
			{
				// Call the completion block
				if let completion = item.completion {
					completion(animComplete)
				}
				// Remove the animation
				animationItems.removeValue(forKey: key)
			}
		}
	}

	fileprivate func updateAnimatableItems(_ timeDelta: Double) {
		// TODO: replace pseuo-code with some real code

		// Remove any empty objects or items removed since the last iteration
		//animatables.remove all objects in toRemove
		//toRemove.remove all objects
		// Add any new items added during or since the previous iteration
		//animatables.add all objects in toAdd
		//toAdd.remove all objects

		// Iterate through the animatables
		//for each 'animatable' in animatables
		//{
		//	// Check for "gone-away" animatables and add them to toRemove
		//	if animatable has gone away
		//	toRemove.addObject(animatable)
		//}
		//else
		//{
		//	// Update the animatable
		//	animatable.update by timeDelta
		//}
		//}
	}

	open static func animate(identifier: String,
	                         duration: Double,
	                         update: @escaping AnimationUpdate,
	                         completion: AnimationCompletion? = nil) {
		// Cancel any existing animation for this identifier
		cancelAnimation(identifier: identifier)

		// Call the update block for the first time (with zero progress)
		let animContinue = update(0.0)
		if(!animContinue)
		{
			completion?(false)
			return
		}

		// Add the new animation item
		let item = AnimationItem(duration: duration, update: update, completion: completion)
		sharedInstance.animationItems[identifier] = item
		sharedInstance.displayLink?.isPaused = false
	}

	open static func cancelAnimation(identifier: String) -> Void {
		let existingItem = sharedInstance.animationItems.removeValue(forKey: identifier)
		if let completion = existingItem?.completion
		{
			completion(false)
		}
	}
}

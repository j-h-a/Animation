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

public protocol Animatable: class {
	func update(by timeInterval: Double) -> Void
}

open class Animation
{
	private static var sharedInstance = Animation()

	private var animationItems = [String : AnimationItem]()
	private let displayLink: CADisplayLink?
	private var animatables = [AnimatableProxy]()

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

	private class Updater
	{
		var animationInstance: Animation?

		@objc public func displayLinkUpdate(_ link: CADisplayLink) -> Void {
			animationInstance?.update(link)
		}
	}

	private class AnimatableProxy
	{
		weak var target: Animatable?
		init(target: Animatable) {
			self.target = target
		}
	}

	private init() {
		let updater = Updater()
		displayLink = CADisplayLink(target: updater, selector: #selector(Updater.displayLinkUpdate(_:)))
		displayLink?.isPaused = true
		displayLink?.frameInterval = 1
		displayLink?.add(to: RunLoop.main, forMode: RunLoopMode.commonModes)
		updater.animationInstance = self
	}

	private func update(_ link: CADisplayLink) -> Void {
		// Calculate the time delta
		let timeDelta = link.duration * Double(link.frameInterval)

		// Update the active animations
		updateAnimationItems(by: timeDelta)

		// Update the registered animatables
		updateAnimatableItems(by: timeDelta)

		// Stop the animation updates if there are no current animations
		if((animatables.count + animationItems.count) == 0) {
			displayLink?.isPaused = true
		}
	}

	private func updateAnimationItems(by timeDelta: Double) {

		for (key, item) in animationItems {
			// It's possible that the item may have been removed or replaced during
			// this iteration. The behaviour we want is that removals are instantaneous
			// so they won't get processed during the same iteration (their completion
			// handler was already called when the animation was cancelled), while
			// additions are not processed until the next iteration.
			guard item === animationItems[key] else { continue }

			var animComplete = false
			var animContinue = false

			// Increment the time
			item.time += timeDelta

			// Call the update closure with the current progress of the animation
			if(item.time >= item.endTime)
			{
				_ = item.update(1.0)
				animComplete = true
			}
			else
			{
				animContinue = item.update(item.time / item.endTime)
			}
			// If the animation is finished...
			if(animComplete || !animContinue)
			{
				// Remove the animation
				animationItems.removeValue(forKey: key)
				// Call the completion closure
				if let completion = item.completion {
					completion(animComplete)
				}
			}
		}
	}

	private func updateAnimatableItems(by timeDelta: Double) {
		animatables = animatables.filter { $0.target != nil }
		for proxy in animatables {
			if let animatable = proxy.target {
				animatable.update(by: timeDelta)
			}
		}
	}

	// MARK: - Public Interface



	/** Adds an animatable object to be updated every tick.

	Adding an object causes it to start receiving updates through the Animatable interface.
	Updates will continue in sync with the display-update until the object is removed.
	If added from another Animatable object's update method, updates will not commence until
	the next display update. The animatable object is not retained, if it is deinited it
	will be removed automatically.

	- parameters:
	  - animatable: The animatable to add.
	*/
	open static func add(animatable: Animatable) {
		remove(animatable: animatable)
		sharedInstance.animatables.append(AnimatableProxy(target: animatable))
		sharedInstance.displayLink?.isPaused = false
	}

	/** Removes an animatable object.
	
	Removing an Animatable immediately stops it from receiving updates.
	It is safe for an Animatable to remove itself from within its own update method.

	- parameters:
	  - animatable: The animatable to remove.
	*/
	open static func remove(animatable: Animatable) {
		for proxy in sharedInstance.animatables {
			if proxy.target === animatable {
				proxy.target = nil
			}
		}
	}

	/** Triggers an animation with an update closure and a completion closure.

	The update closure will always get called at least once with progress 0.0, and will then be called
	repeatedly with increasing values of progress up to 1.0, when the animation has ended.
	If the animation completes, it will be called with progress 1.0 before the completion closure is called.
	Return true from the update closure to let the animation continue.
	Returning false will cause the animation to be cancelled and the completion closure will be called immediately
	with the finished flag set to false.
	Note that when progress is 1.0 and the animation has actually completed, the completion closure will be called with
	the finished flag set to true even if the update closure returns false.

	- parameters:
	  - identifier: A unique identifier for the animation.
	  - duration: The duration of the animation in seconds.
	  - update: The update closure.
	  - completion: The optional completion closure, can be omitted.
	*/
	open static func animate(identifier: String,
	                         duration: Double,
	                         update: @escaping AnimationUpdate,
	                         completion: AnimationCompletion? = nil) {
		// Cancel any existing animation for this identifier
		cancelAnimation(identifier: identifier)

		// Call the update closure for the first time (with zero progress)
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

	/** Cancels an animation that was triggered with the animate method.
	
	The animation is immediately cancelled and its completion block is called.

	- parameters:
	  - identifier: The identifier used to trigger the animation.
	*/
	open static func cancelAnimation(identifier: String) -> Void {
		let existingItem = sharedInstance.animationItems.removeValue(forKey: identifier)
		if let completion = existingItem?.completion
		{
			completion(false)
		}
	}
}

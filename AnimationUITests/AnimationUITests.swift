//
//  AnimationUITests.swift
//  AnimationUITests
//
//  Created by Jay on 2016-09-18.
//  Copyright © 2016 Jay Abbott. All rights reserved.
//

import XCTest
import Animation

class AnimationUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
		if #available(iOS 9.0, *) {
			XCUIApplication().launch()
		} else {
			// Fallback on earlier versions
		}
    }

	enum AnimationStateProgression {
		case notStarted
		case updatedWith0
		case updatedWithGT0LT1
		case updatedWith1
		case completion
	}

	class AnimatableTest: Animatable {

		private(set) var updateCount: Int = 0
		private var waitForCount: Int = 0
		private var actionToTake: (() -> Void)? = nil

		func take(action: @escaping () -> Void, after: Int) {
			updateCount = 0
			waitForCount = after
			actionToTake = action
		}

		func update(by timeInterval: Double) {

			updateCount += 1
			if(updateCount == waitForCount) {
				if let action = actionToTake {
					action()
				}
			}
		}
	}

	func testAnimationStateProgressionComplete() {

		let animationDone = expectation(description: "animation completed ok")

		var state = AnimationStateProgression.notStarted

		Animation.animate(identifier: "testAnimationStateProgressionComplete", duration: 0.1,
			update: { progress in

				switch state {

				case .notStarted:
					XCTAssertEqual(progress, 0, "progress should be 0.0 on the first update")
					state = AnimationStateProgression.updatedWith0

				case .updatedWith0:
					XCTAssertLessThan(progress, 1, "there should be at least one intermediate update")
					state = AnimationStateProgression.updatedWithGT0LT1
					fallthrough
				case .updatedWithGT0LT1:
					if(progress == 1) {
						state = AnimationStateProgression.updatedWith1
					} else {
						XCTAssertGreaterThan(progress, 0, "progress should be 0.0 < progress < 1.0 for intermediate updates")
						XCTAssertLessThan(progress, 1, "progress should be 0.0 < progress < 1.0 for intermediate updates")
					}

				case .updatedWith1:
					XCTFail("update should not be called again, after update with 1.0")

				case .completion:
					XCTFail("update should not be called after completion")
				}

				return true
			},
			completion: { finished in
				XCTAssertTrue(finished, "finished should be true in this completion")
				XCTAssertEqual(state, AnimationStateProgression.updatedWith1, "completion should not be called before update with 1.0")
				state = AnimationStateProgression.completion
				animationDone.fulfill()
			})

		waitForExpectations(timeout: 5)
		XCTAssertEqual(state, AnimationStateProgression.completion, "completion should have been called")
	}

	func testAnimationStateProgressionInstantStop() {

		let animationDone = expectation(description: "animation completed ok")

		var state = AnimationStateProgression.notStarted

		Animation.animate(identifier: "testAnimationStateProgressionInstantStop", duration: 0.1,
			update: { progress in

				switch state {

				case .notStarted:
					XCTAssertEqual(progress, 0, "progress should be 0.0 on the first update")
					state = AnimationStateProgression.updatedWith0

				default:
					XCTFail("update should not be called after it returned false")
				}

				return false
			},
			completion: { finished in
				XCTAssertFalse(finished, "finished should be false in this completion")
				XCTAssertEqual(state, AnimationStateProgression.updatedWith0, "completion should be called after update returns false to terminate animation")
				state = AnimationStateProgression.completion
				animationDone.fulfill()
			})

		waitForExpectations(timeout: 5)
		XCTAssertEqual(state, AnimationStateProgression.completion, "completion should have been called")
	}

	func testAnimationStateProgressionPrematureStop() {

		let animationDone = expectation(description: "animation completed ok")

		var state = AnimationStateProgression.notStarted

		Animation.animate(identifier: "testAnimationStateProgressionPrematureStop", duration: 0.1,
			update: { progress in

				switch state {

				case .notStarted:
					XCTAssertEqual(progress, 0, "progress should be 0.0 on the first update")
					state = AnimationStateProgression.updatedWith0

				case .updatedWith0:
					XCTAssertLessThan(progress, 1, "there should be at least one intermediate update")
					fallthrough
				case .updatedWithGT0LT1:
					XCTAssertGreaterThan(progress, 0, "progress should be 0.0 < progress < 1.0 for intermediate updates")
					XCTAssertLessThan(progress, 1, "progress should be 0.0 < progress < 1.0 for intermediate updates")
					XCTAssertEqual(state, AnimationStateProgression.updatedWith0, "update should not be called after it returned false")
					state = AnimationStateProgression.updatedWithGT0LT1
					return false

				default:
					XCTFail("update should not be called after it returned false")
				}

				return true
			},
			completion: { finished in
				XCTAssertFalse(finished, "finished should be false in this completion")
				XCTAssertEqual(state, AnimationStateProgression.updatedWithGT0LT1, "completion should be called after update returns false to terminate animation")
				state = AnimationStateProgression.completion
				animationDone.fulfill()
			})

		waitForExpectations(timeout: 5)
		XCTAssertEqual(state, AnimationStateProgression.completion, "completion should have been called")
	}

	func testAnimationStateProgressionStopAtOne() {

		let animationDone = expectation(description: "animation completed ok")

		var state = AnimationStateProgression.notStarted

		Animation.animate(identifier: "testAnimationStateProgressionStopAtOne", duration: 0.1,
			update: { progress in

				switch state {

				case .notStarted:
					XCTAssertEqual(progress, 0, "progress should be 0.0 on the first update")
					state = AnimationStateProgression.updatedWith0

				case .updatedWith0:
					XCTAssertLessThan(progress, 1, "there should be at least one intermediate update")
					state = AnimationStateProgression.updatedWithGT0LT1
					fallthrough
				case .updatedWithGT0LT1:
					if(progress == 1) {
						state = AnimationStateProgression.updatedWith1
						return false
					} else {
						XCTAssertGreaterThan(progress, 0, "progress should be 0.0 < progress < 1.0 for intermediate updates")
						XCTAssertLessThan(progress, 1, "progress should be 0.0 < progress < 1.0 for intermediate updates")
					}

				case .updatedWith1:
					XCTFail("update should not be called again, after update with 1.0")

				case .completion:
					XCTFail("update should not be called after completion")
				}

				return true
			},
			completion: { finished in
				XCTAssertTrue(finished, "finished should be true in this completion even though update returned false")
				XCTAssertEqual(state, AnimationStateProgression.updatedWith1, "completion should be called after update with 1.0")
				state = AnimationStateProgression.completion
				animationDone.fulfill()
			})

		waitForExpectations(timeout: 5)
		XCTAssertEqual(state, AnimationStateProgression.completion, "completion should have been called")
	}

	func testAnimationRemovedDuringUpdateCycle() {

		let firstCompleted = expectation(description: "first animation completed")
		let secondCompleted = expectation(description: "second animation completed")

		var otherRemoved = false
		var finishedCount = 0

		Animation.animate(identifier: "first", duration: 0.1,
			update: { progress in
				if progress > 0.5 && !otherRemoved {
					Animation.cancelAnimation(identifier: "second")
					otherRemoved = true
				}
				return true
			},
			completion: { finished in
				finishedCount += finished ? 1 : 0
				firstCompleted.fulfill()
			})
		Animation.animate(identifier: "second", duration: 0.1,
			update: { progress in
				if progress > 0.5 && !otherRemoved {
					Animation.cancelAnimation(identifier: "first")
					otherRemoved = true
				}
				return true
			},
			completion: { finished in
				finishedCount += finished ? 1 : 0
				secondCompleted.fulfill()
			})

		waitForExpectations(timeout: 5)
		XCTAssertEqual(finishedCount, 1, "exactly one of the animations should have finished")
	}

	func testAnimationRetriggerItself() {

		var a1UpdateCount = 0
		var a1CompletedCount = 0
		var a2UpdateCount = 0
		var a2CompletedCount = 0
		let a2Completed = expectation(description: "retriggered animation completed")

		Animation.animate(identifier: "x", duration: 0.1,
			update: { progress in

				a1UpdateCount += 1

				return progress > 0.0 ? false : true
			},
			completion: { finished in

				a1CompletedCount += 1

				// Re-trigger animation with the same identifier
				Animation.animate(identifier: "x", duration: 0.1,
					update: { progress in

						a2UpdateCount += 1

						return progress > 0.0 ? false : true
					},
					completion: { finished in

						a2CompletedCount += 1
						a2Completed.fulfill()
					})
			})

		waitForExpectations(timeout: 5)
		XCTAssertEqual(a1UpdateCount, 2, "first iteration should have updated exactly twice")
		XCTAssertEqual(a2UpdateCount, 2, "retriggered iteration should have updated exactly twice")
		XCTAssertEqual(a1CompletedCount, 1, "first iteration should have completion called exactly once")
		XCTAssertEqual(a2CompletedCount, 1, "retriggered iteration should have completion called exactly once")
	}

	func testAnimatableAddMultiple() {

		let a1 = AnimatableTest()
		let a2 = AnimatableTest()
		let a3 = AnimatableTest()
		let e1 = expectation(description: "animatable 1 being updated")
		let e2 = expectation(description: "animatable 2 being updated")
		let e3 = expectation(description: "animatable 3 being updated")

		a1.take(action: { e1.fulfill() }, after: 5)
		a2.take(action: { e2.fulfill() }, after: 10)
		a3.take(action: { e3.fulfill() }, after: 15)
		Animation.add(animatable: a1)
		Animation.add(animatable: a2)
		Animation.add(animatable: a3)

		waitForExpectations(timeout: 5)
	}

	func testAnimatableRemove() {

		let a1 = AnimatableTest()
		let e1 = expectation(description: "animatable being updated")

		a1.take(action: { e1.fulfill() }, after: 5)
		Animation.add(animatable: a1)
		waitForExpectations(timeout: 5)

		// a1 still running - cause failure unless removed
		a1.take(action: { XCTFail("animation a1 was not removed") }, after: 5)

		let a2 = AnimatableTest()
		let e2 = expectation(description: "animatable removed")
		a2.take(
			action: {
				Animation.remove(animatable: a1)
				a2.take(action: { e2.fulfill() }, after: 5)
			}, after: 2)
		Animation.add(animatable: a2)

		waitForExpectations(timeout: 5)
	}

	func testAnimatableAddingOthers() {

		let a1 = AnimatableTest()
		let a2 = AnimatableTest()
		let e1 = expectation(description: "animatable added other one")

		a1.take(action: { Animation.add(animatable: a2) }, after: 5)
		a2.take(action: { e1.fulfill() }, after: 5)
		Animation.add(animatable: a1)

		waitForExpectations(timeout: 5)
	}

	func testAnimatableRemovingOthers() {

		let a1 = AnimatableTest()
		let a2 = AnimatableTest()
		let a3 = AnimatableTest()
		let e1 = expectation(description: "animatable removed other one")

		a1.take(action: { XCTFail() }, after: 10)
		a2.take(action: { Animation.remove(animatable: a1) }, after: 5)
		a3.take(action: { e1.fulfill() }, after: 20)
		Animation.add(animatable: a1)
		Animation.add(animatable: a2)
		Animation.add(animatable: a3)

		waitForExpectations(timeout: 5)
	}

	func testAnimatableRemovingSelf() {

		let a1 = AnimatableTest()
		let a2 = AnimatableTest()
		let e1 = expectation(description: "animatable removed self")

		a1.take(action: { Animation.remove(animatable: a1); e1.fulfill() }, after: 5)
		Animation.add(animatable: a1)
		waitForExpectations(timeout: 5)

		a1.take(action: { XCTFail("animation not removed") }, after: 5)

		let e2 = expectation(description: "fail didn't happen before expectation met")
		a2.take(action: { e2.fulfill() }, after: 10)
		Animation.add(animatable: a2)
		waitForExpectations(timeout: 5)
	}

	func testAnimatableAddingExisting() {

		let a1 = AnimatableTest()
		let a2 = AnimatableTest()
		let e1 = expectation(description: "animatable was updated")

		a2.take(action: { e1.fulfill() }, after: 25)

		Animation.add(animatable: a1)
		Animation.add(animatable: a2)

		Animation.add(animatable: a1)
		Animation.add(animatable: a1)
		Animation.add(animatable: a1)
		Animation.add(animatable: a1)

		waitForExpectations(timeout: 5)

		Animation.remove(animatable: a2)
		Animation.remove(animatable: a1)

		XCTAssertEqual(a1.updateCount, a2.updateCount, "both animations should have the same update count")
	}
}

# Animation

A framework for performing animations on any properties using custom curves.

Requires: Xcode 8, Swift 3.0

## Overview

 - Trigger animations that call a closure repeatedly (in sync with the display refresh)
   for a dspecified duration, from which you can update on-screen objects.
 - Cancel/overwrite triggered animations by their identifier.
 - Add/remove instances conforming to the `Animatable` protocol to a list so they will
   receive an `update` call in sync with the display refresh.
 - Use the convenient interpolation operators and `Curve` classes to simplify your code.
 - Make your own curves using `CompositeCurve` or by implementing the `Parametric` protocol.

## Getting Started

You can install and use this Framework with Cocoapods, or by manually adding the
`Animation` project into your workspace and updating the build settings.

### Installation (Cocoapods)

Requires: Cocoapods 1.1.0 or higher

Add the dependency to your `Podfile`:

```
pod 'Animation', '~> 1.0'
```

Tell Cocoapods to retrieve the dependencies and include them into your workspace:

```
pod install
```

### Installation (Manually managed)

 1. Clone the animation repository as a submodule of your project repository, or otherwise
    get the code and include it in your project.
 2. Include the `Animation.xcproject` project into your Workspace.
 3. Embed/link the `Animation.framework` with your targets in the target/build settings.


### Using Animations

Import the module:

``` swift
import Animation
```

Perform fire-and-forget animations:

``` swift
let startPoint = CGPoint(x: 10, y: 10)
let endPoint = CGPoint(x: 100, y: 100)
let startColor = UIColor.black
let endColor = UIColor.red

Animation.animate(identifier: "example", duration: 0.5,
    update: { (progress) -> Bool in
        myView.center = startPoint <~~ Curve.easeInEaseOut[progress] ~~> endPoint
        myView.backgroundColor = startColor <~~ progress ~~> endColor
        return true
    })
```

What's going on:

The `Animation.animate(identifier:duration:update:completion:)` function starts an animation
immediately, calling your update code repeatedly (in sync with the display refresh) for the
specified duration. Within the update closure, a `UIView` instance is updated by changing its
`center` and `backgroundColor` properties. You can perform any calculations, and update
whatever properties you like, including ones that aren't normally animatable using `UIKit`
animnations. The interpolation operators are used to get an interpolated value between the
start and end values, for example `10.0 <~~ 0.1 ~~> 20.0` would return a value 0.1 of the way
from 10.0 to 20.0, i.e. 11.0. The `progress` parameter is used to perform linear interpolation
of the `backgroundColor` and the `Curve.easeInEaseOut` object is used to convert the linear
`progress` into an ease-in-ease-out curve to animate the position.

### Using Animatables

Import the module:

``` swift
import Animation
```

Adopt the `Animatable` protocol:

``` swift
class MyAnimatableClass: Animatable {
```

Conform to the `Animatable` protocol:

``` swift
func update(by timeInterval: Double) {
    // Do whatever you want, using timeInterval to calculate the new position of things
}
```

Add your instance to receive updates:

``` swift
Animation.add(animatable: self)
```

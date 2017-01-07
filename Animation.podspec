Pod::Spec.new do |s|

  s.name         = "Animation"
  s.version      = "1.0.0"

  s.summary      = "A Swift 3 framework for performing animations on any properties using custom curves"
  s.description  = <<-DESC
		This Animation framework allows you to have more control over on-screen animations,
		or indeed anything you want to change the value of over time. For each animation
		you provide a closure which is called repeatedly with a progress value, and from here
		you can set whatever properties you want. You're not restricted to the 'animatable'
		properties, and you can use the helper curve classes and interpolation operators to
		make your code very small, clear, and concise. With the curve classes, you can
		construct custom curves and use them to control the motion of your animations as a
		single fire-and-forget call to trigger the animation, instead of chaining together
		secondary and tiertary animations from the completion blocks.

		In addition to the triggerable animations, you can adopt the Animatable protocol in
		any of your classes, and add them to start receiving updates. This allows you to get
		constant callbacks in sync with the screen refresh, so that you can apply any motion
		effects you want. You can remove your Animatable so that it no longer receives
		updates at any time, but if you forget to remove it don't worry - the Animation
		framework only keeps a weak reference to it, and will automatically remove it when
		your instance goes away.
                   DESC

  s.homepage     = "https://github.com/j-h-a/Animation"
  s.license      = { :type => "MIT", :file => "LICENSE.md" }
  s.author       = "Jay Abbott"

  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/j-h-a/Animation.git",
                     :tag => s.version.to_s }

  s.source_files  = "Animation"
end

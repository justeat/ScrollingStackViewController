![ScrollingStackViewController Banner](./img/banner.png)

# ScrollingStackViewController

[![Build Status](https://travis-ci.org/justeat/ScrollingStackViewController.svg?branch=master)](https://travis-ci.org/justeat/ScrollingStackViewController)
[![Version](https://img.shields.io/cocoapods/v/ScrollingStackViewController.svg?style=flat)](http://cocoapods.org/pods/ScrollingStackViewController)
[![License](https://img.shields.io/cocoapods/l/ScrollingStackViewController.svg?style=flat)](http://cocoapods.org/pods/ScrollingStackViewController)
[![Platform](https://img.shields.io/cocoapods/p/ScrollingStackViewController.svg?style=flat)](http://cocoapods.org/pods/ScrollingStackViewController)

`ScrollingStackViewController` is a convenient replacement for the `UITableViewController` more suitable in situations when you're building a scrolling controller with a limited number or dynamic and rich "cells".

## Motivation

`UITableViewController` is great for situations when we want to display an arbitrary (possibly large) number of relatively simple cells. Sometimes however you just want to partition your view controller into vertically laid out segments. The segments are probably highly heterogenous, complex, their number is well defined, but you still want to be able to show and hide them depending on the situation. You can achieve that with a `UITableViewController`, but it gets a litte awkward:

- The Data Source pattern is an overkill here. You might as well just add your segments directly and hide/show them without having to go through `cellForRow:at:`, table view updates, etc. Juggling indexes when you want to show and hide different cells tends to be bug and crash prone and sometimes difficult to animate nicely. You probably don't care for cell reuse in this case, so the advantages of delegation are missing here.
- It's difficult to partition the code well. `UITableViewCell` belongs in the View layer, so you either have to keep the Controller parts in your containing view controller in which case you haven't partioned the Controller layer, or you have to pervert `UITableViewCell` and stick Controller code there. In either case--not a win.

The solution to the above that `ScrollingStackViewController` provides is to use child view controllers that can honestly keep their own Controller code while using `UIStackView` to deal with the layout and `UIScrollView` for scrolling. It's a simple class that provides all of the scaffolding and aims to deal with all of the UIKit quirks that it likes to throw at you.

<p><img src="https://github.com/justeat/ScrollingStackViewController/blob/master/img/demo.gif?raw=true" alt="ScrollingStackViewController Demo" width="350"/></p>

We invite you to check the Order Details page in the Just Eat UK app where each segment is a child view controller, making the such page a perfect use case for using `ScrollingStackViewController`.
The containing view controller only needs to know how to instantiate, initialise, and add the child controllers.

## Usage

Inherit from `ScrollingStackViewController`. Instantiate and add your child view controllers. **Make sure your child view controllers have constraints to self-size vertically.**

```swift
class ViewController: ScrollingStackViewController {
    
    var viewController1: UIViewController!
    var viewController2: UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
        viewController1 = storyboard.instantiateViewController(withIdentifier: "ChildController1") as! ChildController1
        viewController2 = storyboard.instantiateViewController(withIdentifier: "ChildController2") as! ChildController2
        
        add(viewController: viewController1)
        add(viewController: viewController2)            
    }
}
```

Insert a child view controller at position.

```swift
insert(viewController: viewController3, at: .index(1))
```

Insert a child view controller with padding (child view is added to a container view). NB: When a child view is added to a padding container view, the show/hide functions should be used.
```swift
insert(viewController: viewController4,
           edgeInsets: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8),
                   at: .after(viewController3))
```

Remove a child view controller. NB: Might be easier to just add all VCs you were planning to use and then just show and hide them as needed. See below.

```swift
remove(viewController: viewController3)
```

Show and hide the view controllers using `show(viewController:)` and `hide(viewController:)`. The transition animates.

```swift
show(viewController: viewController1)
```

The default is a spring animation with 0.5 duration and 1 damping. You can override the default animation closure.

```swift
animate = { animations, completion in
    UIView.animate(withDuration: 1, animations: animations, completion: completion)
}
```

Add spacing.

```swift
spacingColor = UIColor.lightGray
stackView.spacing = 0.5
```

Add border.

```swift
borderColor = UIColor.darkGray
borderWidth = 1
```

Programatically scroll to child view controller.

```swift
scrollTo(viewController: viewController2, action: { print("Done scrolling!") })
```

Override scroll animation.

```swift
scrollAnimate = { animations, completion in
    UIView.animate(withDuration: 1, animations: animations, completion: completion)
}
```

You still have access to the stack view, scroll view, and the background view that back the view controller if you need to do something that's not covered quickly.

```swift
scrollView.alwaysBounceVertical = false
stackView.spacing = 1
stackViewBackgroundView.alpha = 0
```

## Requirements

ScrollingStackViewController requires iOS 9 or higher. Swift 4, XCode 9 supported.

## License

ScrollingStackViewController is available under the Apache License Version 2.0, January 2004. See the LICENSE file for more info.

- Just Eat iOS team

# SwiftyToolTip

![SwiftyToolTip example video](https://thumbs.gfycat.com/SlightBriefCanary-size_restricted.gif)

[![CI Status](https://img.shields.io/travis/BobDeKort/SwiftyToolTip.svg?style=flat)](https://travis-ci.org/BobDeKort/SwiftyToolTip)
[![Version](https://img.shields.io/cocoapods/v/SwiftyToolTip.svg?style=flat)](https://cocoapods.org/pods/SwiftyToolTip)
[![License](https://img.shields.io/cocoapods/l/SwiftyToolTip.svg?style=flat)](https://cocoapods.org/pods/SwiftyToolTip)
[![Platform](https://img.shields.io/cocoapods/p/SwiftyToolTip.svg?style=flat)](https://cocoapods.org/pods/SwiftyToolTip)

SwiftyToolTip is a tooltip library written in swift, giving developers an easy way of adding tooltips and descriptions to any UI element:

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.


## Installation

### Cocoapods
[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```ruby
$ gem install cocoapods
```

To integrate SwiftyToolTip into your Xcode project using CocoaPods, specify it in your Podfile:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'SwiftyToolTip'
end
```

Then, run the following command:

```ruby
$ pod install
```

## Usage

SwiftyToolTip can be used on almost all UI elements available in Swift, below you can see some examples on how to implement the tooltips. Don't worry, you just need 1 line!

### UIView
Adding a tooltip to a UIView, or any of its subclasses is extremely easy, have a look:

```swift
view.addToolTip(description: "This is the text displayed in the tooltip")
view.addToolTip(description: "Look below in Tips and Tricks for a suggesting on structuring your tooltips", gesture: .longPress, isEnabled: true)
```

### UIBarButtonItem

Adding a tooltip to a UIBarbuttonItem, or any subclass is as well quite easy, just watch out where you put the code.
As the view has to be presented on the screen we have to add the tooltip in the ```viewDidAppear()``` function


```swift
override func viewDidAppear(_ animated: Bool) {
    // Adding a tool tip to a UIBarButtonItem has to happen in the viewDidAppear
    barButtonItem.addToolTip(description: "Add a new item to some list")
    barButtonItem.addToolTip(description: Description.BarButtonItems.addButton, gesture: .longPress)
}
```

### UITabBar

Adding a tooltip to a UITabBar or one of its buttons, needs a little more thought but once again you can do it in one line.
Always think about what gesture you add to what tooltip, as they can override already existing gestures.

Adding tooltips to individual tabbarbuttons

```swift
// Double tap does not work on tabbarButtons (Not sure why, yet!)
tabBarController?.tabBar.addToolTip(at: 0, description: Description.tabBar.storyboardViewController, gesture: .longPress, isEnabled: true)
tabBarController?.tabBar.addToolTip(at: 1, description: Description.tabBar.otherViewcontroller, gesture: .longPress, isEnabled: true)
```
 
Adding tooltip to the whole tabbar, using the UIView implementation
 
```swift
tabBarController?.tabBar.addToolTip(description: Description.tabBar.tabbar, gesture: .doubleTap)
```

### Tips, Tricks and extra info

- Think when adding tooltips, you could override an existing gesture without you knowing
- When adding tooltips to a UIView that has subviews with tooltips, make sure to use a different gesture for the superview.
- Currently supported gestures are: DoubleTap and LongPress.
- isEnabled adds the tooltip but will not display. 


- Use nested structs to keep your descriptions clean and in one place, you could also use other structures, such as json. This is just a suggestion, I'm sure there are better ways to store this data. Example:


```swift
struct Description {
    struct Label {
        static let defaultLabel = "This is a Label, a Label displays text"
        static let otherLabel = "This is another label, this label can also display text"
    }
    
    struct OtherUIElements {
        static let segmentedControl = "A segmented control gives you 2 or more option to select from"
        static let slider = "Adjust a slider to change a give range of numbers"
        static let progressView = "The progress view shows you the progress of a certain task"
    }
    
    struct BarButtonItems {
        static let backButton = "Go back to the previous view controller without doing anything"
        static let cancelButton = "Go back to previous view controller and cancel all tasks or information given"
        static let saveButton = "Saves the new data and continues to the next step"
        static let addButton = "Opens a new screen where you can create a new thing for your app"
    }
    
    struct tabBar {
        static let tabbar = "Here you can switch between different sections of the app"
        static let storyboardViewController = "Here we display a tableview with some tooltips."
        static let otherViewcontroller = "Here we display other stuff"
    }
}
```

## Author

BobDeKort, dekortbob@hotmail.com

## License

SwiftyToolTip is available under the MIT license. See the LICENSE file for more info.

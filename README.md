# AirbnbDatePicker

[![CI Status](http://img.shields.io/travis/mrfour0004@outlook.com/AirbnbDatePicker.svg?style=flat)](https://travis-ci.org/mrfour0004@outlook.com/AirbnbDatePicker)
[![Version](https://img.shields.io/cocoapods/v/AirbnbDatePicker.svg?style=flat)](http://cocoapods.org/pods/AirbnbDatePicker)
[![License](https://img.shields.io/cocoapods/l/AirbnbDatePicker.svg?style=flat)](http://cocoapods.org/pods/AirbnbDatePicker)
[![Platform](https://img.shields.io/cocoapods/p/AirbnbDatePicker.svg?style=flat)](http://cocoapods.org/pods/AirbnbDatePicker)

**AirbnbDatePicker** is a library for picking date (range) on iOS devices. It is also an self-taught project to learn how to make some of great designed views.  The user-interface is inspired by Airbnb, which is always one of my favorite apps.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

- iOS 10.0+
- Xcode 9.0
- Swift 4.0

## Installation

AirbnbDatePicker is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'AirbnbDatePicker'
```

## Usage

In your `UIViewController` subclass, import `AirbnbDatePicker`.

```swift 
// MyViewController.swift

import AirbnbDatePicker
```

### Present `AirbnbDatePicker`

```swift
// setup selectable dateInterval
let dateInterval = DateInterval(start: Date(), duration: 86400*365)

// use provided convenience function to present `AirbnbDatePickerViewController`
//
// if `selectedDateInterval` is provided, the `AirbnbDatePickerViewController` will 
// select them and scroll to the selected dates automatically.
dp.presentDatePickerViewController(dateInterval: dateInterval, selectedDateInterval: selectedDateInterval, delegate: self)
```

### Delegation of `AirbnbDatePicker`

`AirbnbDatePicker` uses the delegate pattern to handle the selected dates
```swift
extension MyViewController: AirbnbDatePickerViewControllerDelegate {
    func datePickerController(_ picker: AirbnbDatePickerViewController, didFinishPicking dateInterval: DateInterval?) {
        // do whatever you want to selected dates
        selectedDateInterval = dateInterval
    }
}
```

## License

AirbnbDatePicker is available under the MIT license. See the LICENSE file for more info.

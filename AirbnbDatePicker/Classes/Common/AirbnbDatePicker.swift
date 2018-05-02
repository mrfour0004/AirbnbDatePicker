//
//  AirbnbDatePicker.swift
//  AirbnbDatePicker
//
//  Created by mrfour on 2018/5/2.
//

import Foundation

public protocol AirbnbDatePickerCompatible {
    associatedtype CompatibleType
    var dp: DatePicker<CompatibleType> { get }
}

public extension AirbnbDatePickerCompatible {
    public var dp: DatePicker<Self> {
        return DatePicker(self)
    }
}

public struct DatePicker<Base> {
    public let base: Base
    fileprivate init(_ base: Base) {
        self.base = base
    }
}


extension UIViewController: AirbnbDatePickerCompatible {}

public extension DatePicker where Base: UIViewController {
    public func presentDatePickerViewController(dateInterval: DateInterval, selectedDateInterval: DateInterval?, delegate: AirbnbDatePickerViewControllerDelegate?, calendar: Calendar = .current) {
        let datePickerViewController = AirbnbDatePickerViewController(dateInterval: dateInterval, selectedDateInterval: selectedDateInterval)
        datePickerViewController.delegate = delegate

        let presentationController = AirbnbPresentationController(presentedViewController: datePickerViewController, presenting: base)
        datePickerViewController.transitioningDelegate = presentationController

        base.present(datePickerViewController, animated: true, completion: nil)
    }
}

//
//  ViewController.swift
//  AirbnbDatePicker
//
//  Created by mrfour0004@outlook.com on 04/10/2018.
//  Copyright (c) 2018 mrfour0004@outlook.com. All rights reserved.
//

import UIKit
import AirbnbDatePicker

class ViewController: UIViewController {

    // MARK: - Properties

    private var selectedDateInterval: DateInterval? {
        didSet {
            label.text = String(describing: selectedDateInterval)
        }
    }

    // MARK: - IBOutlets

    @IBOutlet private weak var label: UILabel!

    // MARK: - IBActions

    @IBAction func presentDatePicker(_ sender: Any) {
        let dateInterval = DateInterval(start: Date(), duration: 86400*365)
        let datePickerViewController = AirbnbDatePickerViewController(dateInterval: dateInterval, selectedDateInterval: selectedDateInterval)
        datePickerViewController.delegate = self

        let presentationController = AirbnbPresentationController(presentedViewController: datePickerViewController, presenting: self)
        datePickerViewController.transitioningDelegate = presentationController

        present(datePickerViewController, animated: true, completion: nil)
    }
}

extension ViewController: AirbnbDatePickerViewControllerDelegate {
    func datePickerController(_ picker: AirbnbDatePickerViewController, didFinishPicking dateInterval: DateInterval) {
        selectedDateInterval = dateInterval
    }
}

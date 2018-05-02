//
//  ViewController.swift
//  AirbnbDatePicker
//
//  Created by mrfour0004@outlook.com on 04/10/2018.
//  Copyright (c) 2018 mrfour0004@outlook.com. All rights reserved.
//

import AirbnbDatePicker

class ViewController: UIViewController {

    // MARK: - Properties

    private lazy var datePickerTheme: ThemeManager = {
        var theme = ThemeManager()
        theme.mainColor = UIColor(red: 241/255, green: 107/255, blue: 111/255, alpha: 1)
        return theme
    }()

    private var selectedDateInterval: DateInterval? {
        didSet {
            guard let dateInterval = selectedDateInterval else {
                label.text = "No selected dates"
                return
            }

            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            let start = dateFormatter.string(from: dateInterval.start)
            let end = dateFormatter.string(from: dateInterval.end)
            label.text = String(describing: "Start: \(start)\nEnd: \(end)")
        }
    }

    // MARK: - IBOutlets

    @IBOutlet private weak var label: UILabel!

    // MARK: - IBActions

    @IBAction func presentDatePicker(_ sender: Any) {
        // Change ThemeManager.current to customize color.
        AirbnbDatePicker.ThemeManager.current = datePickerTheme

        let dateInterval = DateInterval(start: Date(), duration: 86400*365)

        dp.presentDatePickerViewController(dateInterval: dateInterval, selectedDateInterval: selectedDateInterval, delegate: self)
    }    
}

extension ViewController: AirbnbDatePickerViewControllerDelegate {
    func datePickerController(_ picker: AirbnbDatePickerViewController, didFinishPicking dateInterval: DateInterval?) {
        selectedDateInterval = dateInterval
    }
}

//
//  Date+String.swift
//  AirbnbDatePicker
//
//  Created by mrfour on 2018/4/16.
//

import Foundation

extension Date {
    var shortDateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd"

        return dateFormatter.string(from: self)
    }
}

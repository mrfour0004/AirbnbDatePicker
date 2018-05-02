//
//  AirbnbDatePickerViewModel.swift
//  AirbnbDatePicker
//
//  Created by mrfour on 13/11/2017.
//  Copyright © 2017 mrfour. All rights reserved.
//

import UIKit

public class AirbnbDatePickerViewModel: NSObject {
    typealias Days = (days: Int, prepend: Int, append: Int)
    typealias Months = (month: DateComponents, days: Days)
    
    // MARK: - Properties
    
    private var calendar: Calendar
    private let today = Date()
    
    var months: [Month]
    
    /// The span of time between the minimum and maximum selectable dates.
    private let dateInterval: DateInterval
    
    private var indexPathForSelectedStartDate: IndexPath?
    private var indexPathForSelectedEndDate: IndexPath?
    
    // MARK: - Life cycle
    
    /// Initializes a view model for a `AirbnbDatePicker` with the specified date interval.
    ///
    /// - Parameters:
    ///   - dateInterval: The span of time between the minimum and maximum selectable dates.
    ///   - selectedDateInterval: The default selected `dateInterval`.
    ///   - calendar: The calendar to be used.
    init(dateInterval: DateInterval, selectedDateInterval: DateInterval?, calendar: Calendar) {
        let start = calendar.startOfDay(for: dateInterval.start)
        // I use `Calendar.enumerateDates` function to get all dates with DateComponents(day: 1, hour: 0).
        // However, the endDate does not match when its day is 1, so I add 1 hour to the endDate so that its components can match.
        let end = calendar.date(byAdding: .hour, value: 1, to: calendar.startOfDay(for: dateInterval.end))!
        
        self.dateInterval = DateInterval(start: start, end: end)
        self.calendar = calendar
        
        var months: [Month] = []
        calendar.enumerateDates(startingAfter: end, matching: DateComponents(day: 1, hour: 0), matchingPolicy: .strict, direction: .backward) { (date, match, stop) in
            guard let date = date, date >= calendar.dateInterval(of: .month, for: dateInterval.start)!.start else {
                stop = true
                return
            }
            
            months.append(Month(date: date, using: calendar))
            
        }
        self.months = months.reversed()
        
        super.init()
        
        if let selectedDateInterval = selectedDateInterval {
            indexPathForSelectedStartDate = indexPath(for: selectedDateInterval.start)
            indexPathForSelectedEndDate = indexPath(for: selectedDateInterval.end)
        }
    }
}

// MARK: - Functions

extension AirbnbDatePickerViewModel {
    
    /// Returns an index path representing the row and section of a given date.
    ///
    /// - Parameter date: A date of the presented calender.
    /// - Returns: An index path representing the row and section of a given date, or `nil` if the index path is invalid.
    func indexPath(for date: Date) -> IndexPath? {
        for (index, month) in months.enumerated() where month.start..<month.end ~= date {
            let day = calendar.component(.day, from: date)
            return IndexPath(row: month.index(for: day), section: index)
        }
        return nil
    }
    
    /// Return currently selected date interval. Return `nil` if either `indexPathForSelectedStartDate` or `indexPathForSelectedEndDate` is `nil`.
    var selectedDateInterval: DateInterval? {
        guard let start = selectedStartDate, let end = selectedEndDate else { return nil }
        return DateInterval(start: start, end: end)
    }

    var selectedStartDate: Date? {
        guard let indexPath = indexPathForSelectedStartDate else { return nil }
        return day(at: indexPath).date
    }

    var selectedEndDate: Date? {
        guard let indexPath = indexPathForSelectedEndDate else { return nil }
        return day(at: indexPath).date
    }
    
    /// Select a day at the specified index path.
    ///
    /// - Parameter indexPath: An index path that identifies a day in the calendar.
    func selectDay(at indexPath: IndexPath) {
        let day = self.day(at: indexPath)
        
        guard day.options.intersection([.empty, .unselectable]) == [] else {
            return
        }
        
        switch (indexPathForSelectedStartDate, indexPathForSelectedEndDate) {
        case (_?, _?):
            indexPathForSelectedStartDate = indexPath
            indexPathForSelectedEndDate = nil
        case (nil, _):
            indexPathForSelectedStartDate = indexPath
        case (let start?, nil) where indexPath > start:
            indexPathForSelectedEndDate = indexPath
        case (let start?, nil) where indexPath <= start:
            indexPathForSelectedStartDate = indexPath
        default: break
        }
    }


    func clear() {
        indexPathForSelectedStartDate = nil
        indexPathForSelectedEndDate = nil
    }
}

// MARK: - Private functions

fileprivate extension AirbnbDatePickerViewModel {
    func selectDate(_ date: Date) {
        guard let indexPath = indexPath(for: date) else { return }
        indexPathForSelectedStartDate = indexPath
        indexPathForSelectedEndDate = indexPath
    }
    
    func day(at indexPath: IndexPath) -> Day {
        let month = months[indexPath.section]
        var day = month.day(at: indexPath.row)
        
        let date = day.date
        
        if !(month.start..<month.end ~= date) {
            day.options.insert(.empty)
        }
        
        if !(dateInterval.start..<dateInterval.end ~= date) {
            day.options.insert(.unselectable)
        }

        if date == calendar.startOfDay(for: today) && month.start..<month.end ~= date {
            day.options.insert(.today)
        }
        
        if let startIndex = indexPathForSelectedStartDate, startIndex == indexPath {
            day.options.insert(.selectedStart)
            day.options.insert(.selected)

            if indexPathForSelectedEndDate == nil {
                day.options.insert(.selectedEnd)
            }
        }

        if let endIndexPath = indexPathForSelectedEndDate, endIndexPath == indexPath {
            day.options.insert(.selectedEnd)
        }

        if let startIndexPath = indexPathForSelectedStartDate, let endIndexPath = indexPathForSelectedEndDate, startIndexPath...endIndexPath ~= indexPath {
            day.options.insert(.selected)
        }
        
        return day
    }
    
}

// MARK: - Collection data source

extension AirbnbDatePickerViewModel: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let month = months[indexPath.section]
        
        if kind == UICollectionElementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: AirbnbDatePickerHeaderView.className, for: indexPath) as! AirbnbDatePickerHeaderView
            headerView.label.text = month.title
            return headerView
        }
        
        return UICollectionReusableView()
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return months.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let month = months[section]
        return month.numberOfDaysInMonthGird
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let day = self.day(at: indexPath)
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AirbnbDatePickerCollectionViewCell.className, for: indexPath) as! AirbnbDatePickerCollectionViewCell
        cell.day = day
        
        return cell
    }
}

// MARK: - AirbnbDatePickerViewModel.Month

extension AirbnbDatePickerViewModel {
    struct Month {
        
        // MARK: - Private properties
        
        /// The span of time between this month's first day and last day.
        private let dateInterval: DateInterval
        
        private let calendar: Calendar
        
        // MARK: - Properties
        
        var start: Date {
            return dateInterval.start
        }
        
        var end: Date {
            return dateInterval.end
        }
        
        let numberOfDays: Int
        let numberOfPrefixDays: Int
        let numberOfPostDays: Int
        
        var numberOfDaysInMonthGird: Int {
            return numberOfDays + numberOfPrefixDays + numberOfPostDays
        }
        
        var title: String {
            let dateFormatter = DateFormatter()
            let dateFormat = DateFormatter.dateFormat(fromTemplate: "MMMM yyyy", options: 0, locale: calendar.locale ?? Locale.current)
            dateFormatter.dateFormat = dateFormat
            
            return dateFormatter.string(from: dateInterval.start)
        }
        
        // MARK: - Life cycle
        
        init(date: Date, using calendar: Calendar) {
            guard let dateInterval = calendar.dateInterval(of: .month, for: date) else {
                fatalError("Cannot get the `dateInterval` of month for the date: \(date)")
            }
            self.dateInterval = dateInterval
            self.calendar = calendar
            
            let numberOfWeekday = 7
            
            numberOfDays = calendar.range(of: .day, in: .month, for: date)!.count
            numberOfPrefixDays = calendar.component(.weekday, from: dateInterval.start) - 1
            numberOfPostDays = (numberOfWeekday - calendar.component(.weekday, from: dateInterval.end) + 1) % 7
        }
        
        // MARK: - Functions
        
        /// Return a day at the specified index.
        ///
        /// - Parameter index: The index.
        /// - Returns: A day at the specified index.
        func day(at index: Int) -> Day {
            let ordinalityOfDay = index - numberOfPrefixDays
            let date = calendar.date(byAdding: .day, value: ordinalityOfDay, to: dateInterval.start)!
            
            return Day(dateComponents: calendar.dateComponents([.calendar, .year, .month, .day], from: date))
        }
        
        func index(for day: Int) -> Int {
            return numberOfPrefixDays + day - 1
        }
    }
}

// MARK: - AirbnbDatePickerViewModel.Day

extension AirbnbDatePickerViewModel {
    struct Day {
        var options: DayOptions
        var dateComponents: DateComponents
        
        init(dateComponents: DateComponents, options: DayOptions = []) {
            self.dateComponents = dateComponents
            self.options = options
        }
        
        var date: Date {
            guard let date = dateComponents.calendar?.date(from: dateComponents) else {
                fatalError("A date cannot be created from the date components: \(dateComponents)")
            }
            return date
        }
    }
}

// MARK: - AirbnbDatePickerViewModel.DayOptions

extension AirbnbDatePickerViewModel {
    struct DayOptions: OptionSet {
        let rawValue: Int
        
        static let today         = DayOptions(rawValue: 1 << 0)
        static let selected      = DayOptions(rawValue: 1 << 1)
        static let selectedStart = DayOptions(rawValue: 1 << 2)
        static let selectedEnd   = DayOptions(rawValue: 1 << 3)
        static let unselectable  = DayOptions(rawValue: 1 << 4)
        static let empty         = DayOptions(rawValue: 1 << 5)
    }
}

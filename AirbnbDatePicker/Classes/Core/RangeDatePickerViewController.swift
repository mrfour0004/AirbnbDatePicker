//
//  AirbnbDatePickerViewController.swift
//  AirbnbDatePicker
//
//  Created by mrfour on 13/11/2017.
//  Copyright © 2017 mrfour. All rights reserved.
//

import UIKit

@objc public protocol AirbnbDatePickerViewControllerDelegate: class {
    @objc optional func datePickerController(_ picker: AirbnbDatePickerViewController, didFinishPicking dateInterval: DateInterval)
}

public class AirbnbDatePickerViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: AirbnbDatePickerViewModel
    
    private let calendar: Calendar
    private var isFirstLoad: Bool = true
    
    public weak var delegate: AirbnbDatePickerViewControllerDelegate?
    
    // MARK: - Views
    
    private var weekdayHeaderStackView: UIStackView!
    private let headerSeparator = UIView()
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let toolBar = UIToolbar()
    
    // MARK: - Life cycle
    
    public init(dateInterval: DateInterval, selectedDateInterval: DateInterval?, calendar: Calendar = Calendar.current) {
        self.calendar = calendar
        self.viewModel = AirbnbDatePickerViewModel(dateInterval: dateInterval, selectedDateInterval: selectedDateInterval, calendar: calendar)
        super.init(nibName: nil, bundle: nil)
        
        automaticallyAdjustsScrollViewInsets = false
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        prepareView()
        
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
    }
    
    @available(iOS 11.0, *)
    override public func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        guard isFirstLoad else { return }
        scrollToSelectedDateOrToday(animated: false)
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loggingPrint(navigationController)
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if #available(iOS 11.0, *) {
            // The logic is implemented in `viewSafeAreaInsetsDidChange`
        } else {
            guard isFirstLoad else { return }
            scrollToSelectedDateOrToday(animated: false)
        }
    }
}

// MARK: - Button events

public extension AirbnbDatePickerViewController {
    @objc func didClickTodayButton(_ button: UIBarButtonItem) {
        viewModel.selectToday()
        collectionView.reloadData()
        scrollToSelectedDateOrToday(animated: true)
    }
    
    @objc func didClickSaveButton(_ button: UIBarButtonSystemItem) {
        guard let selectedDateInterval = viewModel.selectedDateInterval else {
            // TODO: Should remind users to pick dates
            return
        }

        dismiss(animated: true) { [weak self] in
            guard let `self` = self else { return }
            self.delegate?.datePickerController?(self, didFinishPicking: selectedDateInterval)
        }
    }
}

// MARK: - Prepare view

fileprivate extension AirbnbDatePickerViewController {
    func prepareView() {
        view.backgroundColor = .white
        
        prepareNavigationItem()
        prepareHeaderSeparator()
        prepareCollectionView()
        prepareWeekdayStackView()
        prepareSubviewConstriats()
    }
    
    func prepareNavigationItem() {
        let saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(didClickSaveButton))
        navigationItem.rightBarButtonItem = saveButton
    }
    
    func prepareCollectionView() {
        collectionView.backgroundColor = .white
        collectionView.register(AirbnbDatePickerCollectionViewCell.self, forCellWithReuseIdentifier: AirbnbDatePickerCollectionViewCell.className)
        collectionView.register(AirbnbDatePickerHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: AirbnbDatePickerHeaderView.className)
        
        collectionView.dataSource = viewModel
        collectionView.delegate = self
    }
    
    func prepareHeaderSeparator() {
        headerSeparator.backgroundColor = .separator
    }
    
    func prepareWeekdayStackView() {
        let arrangedSubviews = calendar.veryShortWeekdaySymbols.map { symbol -> UILabel in
            let label = UILabel()
            label.text = symbol
            label.textColor = .text
            label.font = Font.regular(ofSize: 16)
            label.textAlignment = .center
            
            return label
        }
        
        weekdayHeaderStackView = UIStackView(arrangedSubviews: arrangedSubviews)
        
        weekdayHeaderStackView.alignment = .center
        weekdayHeaderStackView.axis = .horizontal
        weekdayHeaderStackView.distribution = .fillEqually
    }
    
    func prepareSubviewConstriats() {
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(toolBar)
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(weekdayHeaderStackView)
        weekdayHeaderStackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(headerSeparator)
        headerSeparator.translatesAutoresizingMaskIntoConstraints = false
        
        if #available(iOS 11.0, *) {
            let stackViewHeightConstraint = weekdayHeaderStackView.heightAnchor.constraint(equalToConstant: Config.weekdayHeaderHeight)
            let stackViewTopConstarint = weekdayHeaderStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
            let stackViewLeadingConstraint = weekdayHeaderStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Config.sectionHorizonInset)
            let stackViewTrailingConstraint = weekdayHeaderStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Config.sectionHorizonInset)
            
            let headerSeparatorHeightConstriant = headerSeparator.heightAnchor.constraint(equalToConstant: 1)
            let headerSeparatorTopConstraint = headerSeparator.topAnchor.constraint(equalTo: weekdayHeaderStackView.bottomAnchor)
            let headerSeparatorLeadingConstraint = headerSeparator.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)
            let headerSeparatorTrailingConstraint = headerSeparator.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
            let headerSeparatorBottomConstraint = headerSeparator.bottomAnchor.constraint(equalTo: collectionView.topAnchor)
            
            let collectionViewLeadingConstraint = collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)
            let collectionViewTrailingConstraint = collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
            let collectionViewBottomConstraint = collectionView.bottomAnchor.constraint(equalTo: toolBar.topAnchor)
            
            let toolBarLeadingConstraint = toolBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)
            let toolBarTrailingConstraint = toolBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
            let toolBarBottomConstraint = toolBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            
            NSLayoutConstraint.activate([stackViewHeightConstraint, stackViewTopConstarint, stackViewLeadingConstraint, stackViewTrailingConstraint, headerSeparatorHeightConstriant, headerSeparatorTopConstraint, headerSeparatorLeadingConstraint, headerSeparatorTrailingConstraint, headerSeparatorBottomConstraint, collectionViewLeadingConstraint, collectionViewTrailingConstraint, collectionViewBottomConstraint, toolBarBottomConstraint, toolBarLeadingConstraint, toolBarTrailingConstraint])
        } else {
            let stackViewHeightConstraint = weekdayHeaderStackView.heightAnchor.constraint(equalToConstant: Config.weekdayHeaderHeight)
            let stackViewTopConstarint = weekdayHeaderStackView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor)
            let stackViewLeadingConstraint = weekdayHeaderStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Config.sectionHorizonInset)
            let stackViewTrailingConstraint = weekdayHeaderStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Config.sectionHorizonInset)
            
            let headerSeparatorHeightConstriant = headerSeparator.heightAnchor.constraint(equalToConstant: 1)
            let headerSeparatorTopConstraint = headerSeparator.topAnchor.constraint(equalTo: weekdayHeaderStackView.bottomAnchor)
            let headerSeparatorLeadingConstraint = headerSeparator.leadingAnchor.constraint(equalTo: view.leadingAnchor)
            let headerSeparatorTrailingConstraint = headerSeparator.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            let headerSeparatorBottomConstraint = headerSeparator.bottomAnchor.constraint(equalTo: collectionView.topAnchor)
            
            let collectionViewLeadingConstraint = collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
            let collectionViewTrailingConstraint = collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            let collectionViewBottomConstraint = collectionView.bottomAnchor.constraint(equalTo: toolBar.topAnchor)
            
            let toolBarLeadingConstraint = toolBar.leadingAnchor.constraint(equalTo: view.leadingAnchor)
            let toolBarTrailingConstraint = toolBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            let toolBarBottomConstraint = toolBar.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor)
            
            NSLayoutConstraint.activate([stackViewHeightConstraint, stackViewTopConstarint, stackViewLeadingConstraint, stackViewTrailingConstraint, headerSeparatorHeightConstriant, headerSeparatorTopConstraint, headerSeparatorLeadingConstraint, headerSeparatorTrailingConstraint, headerSeparatorBottomConstraint, collectionViewLeadingConstraint, collectionViewTrailingConstraint, collectionViewBottomConstraint, toolBarBottomConstraint, toolBarLeadingConstraint, toolBarTrailingConstraint])
        }
    }
}

// MARK: - Private functions

fileprivate extension AirbnbDatePickerViewController {
    /// Scroll the collection view (calendar) to the `start` of `selectedDateInterval`, if `selectedDateInterval` is `nil, then scroll to today.
    func scrollToSelectedDateOrToday(animated: Bool) {
        view.layoutIfNeeded()
        
        let dateToScroll = viewModel.selectedDateInterval?.start ?? Date()
        guard let indexPath = viewModel.indexPath(for: dateToScroll) else { return }
        collectionView.scrollToSupplementaryView(ofKind: UICollectionElementKindSectionHeader, at: indexPath, at: .top, animated: animated)
    }
}

// MARK: - Collection delegate

extension AirbnbDatePickerViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.selectDay(at: indexPath)
        collectionView.reloadData()
    }
}

// MARK: - Collection flow layout

extension AirbnbDatePickerViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return interItemSize(in: collectionView)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 60)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Config.lineSpacing
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let itemSize = interItemSize(in: collectionView)
        let horizonInset = (collectionView.frame.width - itemSize.width*Config.numberOfWeekday) / 2
        let insets = UIEdgeInsets(vertical: Config.sectionVerticalInset, horizontal: horizonInset)
        return insets
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func interItemSize(in colletionView: UICollectionView) -> CGSize {
        let width = ceil((collectionView.frame.width - Config.sectionHorizonInset*2) / Config.numberOfWeekday)
        let height = width - Config.itemSpacing
        return CGSize(width: width, height: height)
    }
}

// MARK: - Configuration

fileprivate extension AirbnbDatePickerViewController {
    enum Config {
        static let itemSpacing: CGFloat = 4
        static let lineSpacing: CGFloat = 4
        static let numberOfWeekday: CGFloat = 7
        static let sectionVerticalInset: CGFloat = 8
        static let sectionHorizonInset: CGFloat = 4
        static let weekdayHeaderHeight: CGFloat = 44
    }
}

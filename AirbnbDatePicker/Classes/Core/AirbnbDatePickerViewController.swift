//
//  AirbnbDatePickerViewController.swift
//  AirbnbDatePicker
//
//  Created by mrfour on 13/11/2017.
//  Copyright © 2017 mrfour. All rights reserved.
//

import UIKit

@objc public protocol AirbnbDatePickerViewControllerDelegate: class {
    @objc optional func datePickerController(_ picker: AirbnbDatePickerViewController, didFinishPicking dateInterval: DateInterval?)
}

public class AirbnbDatePickerViewController: UIViewController {

    // MARK: - Public properties

    public weak var delegate: AirbnbDatePickerViewControllerDelegate?

    public var actionTitle: String = NSLocalizedString("Confirm", comment: "") {
        didSet {
            actionButton.setTitle(actionTitle, for: .normal)
        }
    }

    // MARK: - Private properties
    
    private let viewModel: AirbnbDatePickerViewModel
    private let calendar: Calendar
    private var isFirstLoad = true

    // MARK: - Views

    private var weekdayHeaderStackView: UIStackView!
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let headerView = UIView()
    private let titleView = AirbnbDatePickerTitleView(period: (nil, nil))
    private let clearButton = UIButton(type: .system)
    private let actionButton = UIButton(type: .system)
    
    // MARK: - Life cycle

    public init(dateInterval: DateInterval, selectedDateInterval: DateInterval?, calendar: Calendar = Calendar.current) {
        self.calendar = calendar
        self.viewModel = AirbnbDatePickerViewModel(dateInterval: dateInterval, selectedDateInterval: selectedDateInterval, calendar: calendar)
        super.init(nibName: nil, bundle: nil)
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

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        scrollToSelectedDateOrToday(animated: false)
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}

// MARK: - Button events

public extension AirbnbDatePickerViewController {
    @objc func didClickActionButton(_ button: UIButton) {
        dismiss(animated: true) { [weak self] in
            guard let `self` = self else { return }
            self.delegate?.datePickerController?(self, didFinishPicking: self.viewModel.selectedDateInterval)
        }
    }

    @objc func didClickClearButton(_ button: UIButton) {
        viewModel.clear()
        updateUI()
    }
}


// MARK: - Prepare view

fileprivate extension AirbnbDatePickerViewController {
    func prepareView() {
        view.backgroundColor = .white

        prepareTitleView()
        prepareCollectionView()
        prepareWeekdayStackView()
        prepareActionButton()
        prepareSubviewConstriats()

        updateUI()
    }

    func prepareTitleView() {
        clearButton.setTitle(NSLocalizedString("Clear", comment: ""), for: .normal)
        clearButton.setTitleColor(.darkGray, for: .normal)
        clearButton.setTitleColor(.disabled, for: .disabled)

        clearButton.titleLabel?.font = Font.medium(ofSize: 14)
        clearButton.addTarget(self, action: #selector(didClickClearButton(_:)), for: .touchUpInside)
        clearButton.translatesAutoresizingMaskIntoConstraints = false

        titleView.translatesAutoresizingMaskIntoConstraints = false

        headerView.addSubview(titleView)
        headerView.addSubview(clearButton)

        NSLayoutConstraint.activate([
            titleView.separator.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            clearButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            clearButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20)
        ])
    }
    
    func prepareCollectionView() {
        collectionView.backgroundColor = .white
        collectionView.register(AirbnbDatePickerCollectionViewCell.self, forCellWithReuseIdentifier: AirbnbDatePickerCollectionViewCell.className)
        collectionView.register(AirbnbDatePickerHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: AirbnbDatePickerHeaderView.className)
        collectionView.showsVerticalScrollIndicator = false
        
        collectionView.dataSource = viewModel
        collectionView.delegate = self
    }

    func prepareActionButton() {
        actionButton.setTitle(actionTitle, for: .normal)
        actionButton.setTitleColor(.main, for: .normal)
        actionButton.setTitleColor(.disabled, for: .disabled)
        actionButton.titleLabel?.font = Font.medium(ofSize: 16)
        actionButton.addTarget(self, action: #selector(didClickActionButton), for: .touchUpInside)
    }

    func prepareWeekdayStackView() {
        let arrangedSubviews = calendar.veryShortWeekdaySymbols.map { symbol -> UILabel in
            let label = UILabel()
            label.text = symbol
            label.textColor = .text
            label.font = Font.medium(ofSize: 12)
            label.textAlignment = .center
            
            return label
        }
        
        weekdayHeaderStackView = UIStackView(arrangedSubviews: arrangedSubviews)
        
        weekdayHeaderStackView.alignment = .center
        weekdayHeaderStackView.axis = .horizontal
        weekdayHeaderStackView.distribution = .fillEqually
    }
    
    func prepareSubviewConstriats() {
        let headerSeparator = UIView()
        headerSeparator.backgroundColor = .separator

        let footerSeparator = UIView()
        footerSeparator.backgroundColor = .separator

        let stackView = UIStackView(arrangedSubviews: [headerView, weekdayHeaderStackView, headerSeparator, collectionView, footerSeparator, actionButton])

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical

        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            headerView.heightAnchor.constraint(equalToConstant: Config.headerViewHeight),
            weekdayHeaderStackView.heightAnchor.constraint(equalToConstant: Config.weekdayHeaderHeight),
            headerSeparator.heightAnchor.constraint(equalToConstant: 1),
            footerSeparator.heightAnchor.constraint(equalToConstant: 1),
            actionButton.heightAnchor.constraint(equalToConstant: 44),
            stackView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
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

    func updateUI() {
        collectionView.reloadData()
        updateTitle()

        actionButton.setEnabled(viewModel.selectedStartDate == nil || viewModel.selectedEndDate != nil, animated: true)
        clearButton.setEnabled(viewModel.selectedStartDate != nil, animated: true)
    }

    func updateTitle() {
        titleView.period = (viewModel.selectedStartDate, viewModel.selectedEndDate)
    }
}

// MARK: - Collection delegate

extension AirbnbDatePickerViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.selectDay(at: indexPath)
        updateUI()
    }
}

// MARK: - Collection flow layout

extension AirbnbDatePickerViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return interItemSize(in: collectionView)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 40)
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
        static let sectionHorizonInset: CGFloat = 0
        static let weekdayHeaderHeight: CGFloat = 32
        static let headerViewHeight: CGFloat = 44

        static let titleFont = Font.medium(ofSize: 14)
    }
}

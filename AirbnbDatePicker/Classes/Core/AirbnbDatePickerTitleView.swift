//
//  AirbnbDatePickerTitleView.swift
//  AirbnbDatePicker
//
//  Created by mrfour on 2018/4/17.
//

import UIKit

typealias Period = (start: Date?, end: Date?)

class AirbnbDatePickerTitleView: UIView {

    // MARK: - Properties

    var period: (start: Date?, end: Date?) {
        didSet {
            updateUI()
        }
    }

    // MARK: - Views

    private let startLabel = UILabel()
    private let endLabel = UILabel()
    private let titleLabel = UILabel()
    let separator = UIView()

    var stackView: UIStackView!

    // MARK: - Life cycle

    init(period: Period) {
        self.period = period
        super.init(frame: .zero)

        setupConstraints()
        updateUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Prepare view

fileprivate extension AirbnbDatePickerTitleView {
    func setupConstraints() {
        separator.translatesAutoresizingMaskIntoConstraints = false

        let separatorContainerView = UIView()
        separatorContainerView.addSubview(separator)
        separatorContainerView.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView(arrangedSubviews: [startLabel, separatorContainerView, endLabel])
        stackView.spacing = 8
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false

        self.stackView = stackView

        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stackView)
        addSubview(titleLabel)

        let stackCenterXConstraint = stackView.centerXAnchor.constraint(equalTo: centerXAnchor)
        stackCenterXConstraint.priority = .defaultLow

        NSLayoutConstraint.activate([
            separator.leadingAnchor.constraint(equalTo: separatorContainerView.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: separatorContainerView.trailingAnchor),
            separator.centerYAnchor.constraint(equalTo: centerYAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1),
            separatorContainerView.widthAnchor.constraint(equalToConstant: 12),
            titleLabel.centerXAnchor.constraint(equalTo: separator.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: separator.centerYAnchor),
            stackCenterXConstraint,
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    func updateUI() {
        switch period {
        case (let start?, nil):
            titleLabel.alpha = 0
            stackView.alpha = 1

            startLabel.attributedText = attrString(for: start.shortDateString)
            separator.backgroundColor = .placeholder
            endLabel.attributedText = attrString(for: Config.endDateString, color: .placeholder)
        case (let start?, let end?):
            titleLabel.alpha = 0
            stackView.alpha = 1

            startLabel.attributedText = attrString(for: start.shortDateString)
            separator.backgroundColor = .text
            endLabel.attributedText = attrString(for: end.shortDateString)
        default:
            titleLabel.font = Config.titleFont
            titleLabel.textColor = .text
            titleLabel.alpha = 1
            titleLabel.text = Config.defaultTitle

            stackView.alpha = 0
        }
    }
}

// MARK: - Private functions

fileprivate extension AirbnbDatePickerTitleView {
    func attrString(for str: String, color: UIColor = .text) -> NSMutableAttributedString {
        return NSMutableAttributedString(string: str, attributes: [.foregroundColor: color, .font: Config.titleFont])
    }
}

// MARK: - Config

fileprivate extension AirbnbDatePickerTitleView {
    enum Config {
        static let titleFont = Font.medium(ofSize: 16)
        static let endDateString = NSLocalizedString("End Date", comment: "")
        static let defaultTitle = NSLocalizedString("Select dates", comment: "")
    }
}

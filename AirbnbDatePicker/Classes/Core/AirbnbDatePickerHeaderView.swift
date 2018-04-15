//
//  AirbnbDatePickerHeaderView.swift
//  AirbnbDatePicker
//
//  Created by mrfour on 15/11/2017.
//  Copyright © 2017 mrfour. All rights reserved.
//

import UIKit

class AirbnbDatePickerHeaderView: UICollectionReusableView {
    
    // MARK: - Properties
    
    let label = UILabel()
    
    // MARK: - Life cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prepareView()
    }
}

// MARK: - Prepare view

fileprivate extension AirbnbDatePickerHeaderView {
    func prepareView() {
        label.font = Font.regular(ofSize: 16)
        label.textColor = .text
        
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let bottomConstraint = bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: 8)
        let leadingConstraint = leadingAnchor.constraint(equalTo: label.leadingAnchor, constant: -Config.horizonPadding)
        let trailingConstraint = trailingAnchor.constraint(equalTo: label.trailingAnchor, constant: Config.horizonPadding)
        NSLayoutConstraint.activate([bottomConstraint, leadingConstraint, trailingConstraint])
    }
}

// MARK: - Configuration

fileprivate extension AirbnbDatePickerHeaderView {
    enum Config {
        static let horizonPadding: CGFloat = 20
    }
}

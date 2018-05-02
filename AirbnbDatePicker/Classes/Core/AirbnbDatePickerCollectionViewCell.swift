//
//  AirbnbDatePickerCollectionViewCell.swift
//  AirbnbDatePicker
//
//  Created by mrfour on 14/11/2017.
//  Copyright © 2017 mrfour. All rights reserved.
//

import UIKit

class AirbnbDatePickerCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    var day: AirbnbDatePickerViewModel.Day! {
        didSet {
            setNeedsDisplay()
        }
    }
    
    // MARK: - Views
    
    let label = UILabel()
    
    var circleView = UIView()
    var roundedView = UIView()
    var rectangleView = UIView()
    
    // MARK: - Life cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prepareView()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        populateCell(rect)
    }
}

// MARK: - Prepare view

fileprivate extension AirbnbDatePickerCollectionViewCell {
    func prepareView() {
        label.textColor = .text
        label.font = Font.regular(ofSize: 16)
        
        contentView.addSubview(roundedView)
        contentView.addSubview(circleView)
        contentView.addSubview(rectangleView)
        
        contentView.backgroundColor = .white
        contentView.addSubview(label)
    }
    
    func populateCell(_ rect: CGRect) {
        if let day = day.dateComponents.day {
            label.text = String(describing: day)
            label.sizeToFit()
            label.center = rect.center
        }
        
        label.isHidden = day.options.contains(.empty)
        label.textColor = day.options.contains(.unselectable) ? .disabled : .text
        
        if day.options.contains(.today) {
            setupRoundedView(in: rect)
            
            contentView.addSubview(roundedView)
            roundedView.center = contentView.center
            
            roundedView.isHidden = false
        } else {
            roundedView.isHidden = true
        }
        
        if day.options.contains(.selected) {
            label.textColor = .white
            switch day.options.intersection([.selectedStart, .selectedEnd]) {
            case [.selectedStart]: // left half circle
                setupCircleView(in: rect)
                setupRectangleView(in: CGRect(origin: CGPoint(x: rect.midX, y: 0), size: CGSize(width: rect.width / 2, height: rect.height)))
                
                circleView.isHidden = false
                rectangleView.isHidden = false
            case [.selectedStart, .selectedEnd]: // a circle
                setupCircleView(in: rect)
                
                circleView.isHidden = false
                rectangleView.isHidden = true
            case [.selectedEnd]: // right half circle
                setupCircleView(in: rect)
                setupRectangleView(in: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: rect.width / 2, height: rect.height)))
                
                circleView.isHidden = false
                rectangleView.isHidden = false
            default: // rectangle only
                setupRectangleView(in: rect)
                
                circleView.isHidden = true
                rectangleView.isHidden = false
            }
        } else {
            circleView.isHidden = true
            rectangleView.isHidden = true
        }
    }
    
    private func setupRoundedView(in rect: CGRect) {
        let diameter = rect.height
        
        roundedView.frame = CGRect(origin: .zero, size: CGSize(width: diameter, height: diameter))
        roundedView.backgroundColor = .clear
        roundedView.layer.cornerRadius = diameter / 2
        roundedView.layer.borderWidth = 1
        roundedView.layer.borderColor = Config.color.cgColor
    }
    
    private func setupCircleView(in rect: CGRect) {
        let diameter = rect.height
        
        circleView.frame = CGRect(origin: .zero, size: CGSize(width: diameter, height: diameter))
        circleView.backgroundColor = Config.color
        circleView.layer.cornerRadius = diameter / 2
        circleView.layer.masksToBounds = true
        circleView.center = rect.center
    }
    
    private func setupRectangleView(in rect: CGRect) {
        rectangleView.frame = rect
        rectangleView.backgroundColor = Config.color
    }
}

// MARK: - Configuration

fileprivate extension AirbnbDatePickerCollectionViewCell {
    enum Config {
        static let color: UIColor = .main
    }
}

//
//  UIControl+Extension.swift
//  AirbnbDatePicker
//
//  Created by mrfour on 2018/4/18.
//

import UIKit

extension UIControl {
    func setEnabled(_ isEnabled: Bool, animated: Bool) {
        UIView.transition(with: self, duration: animated ? 0.2 : 0, options: [.transitionCrossDissolve], animations: {
            self.isEnabled = isEnabled
        }, completion: nil)
    }
}

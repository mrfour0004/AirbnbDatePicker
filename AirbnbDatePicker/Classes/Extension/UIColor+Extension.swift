//
//  UIColor+Extension.swift
//  AirbnbDatePicker
//
//  Created by mrfour on 2018/4/10.
//

import UIKit

extension UIColor {
    convenience init(hexString: String) {
        let hexString = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner   = Scanner(string: hexString)

        if hexString.hasPrefix("#") {
            scanner.scanLocation = 1
        }

        var color: UInt32 = 0
        scanner.scanHexInt32(&color)

        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask

        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0

        self.init(red:red, green:green, blue:blue, alpha:1)
    }
}

extension UIColor {
    private static func color(_ hexString: String) -> UIColor {
        return UIColor(hexString: hexString)
    }


    static var text: UIColor { return ThemeManager.current.textColor }
    static var main: UIColor { return ThemeManager.current.mainColor }
    static var disabled: UIColor { return ThemeManager.current.disabledColor }
    static var separator: UIColor { return ThemeManager.current.separatorColor }
    static var placeholder: UIColor { return ThemeManager.current.placeholderColor }

}

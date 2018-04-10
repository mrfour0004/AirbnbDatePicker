//
//  UIColor+Extension.swift
//  AirbnbDatePicker
//
//  Created by Liang, KaiChih on 2018/4/10.
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

    /// Return a color with hex: `#4f4d4b`.
    static let text        = color("#4f4d4b")
    /// Return a color with hex: `#373533`.
    static let textDarker  = color("#373533")
    /// Return a color with hex: `#686562`.
    static let textLighter = color("#686562")

    /// Return a color with hex: `#3bcdac`.
    static let sub         = color("#3bcdac")
    /// Return a color with hex: `#00ab84`.
    static let subDarker   = color("#00ab84")
    /// Return a color with hex: `#67fcdb`.
    static let subLighter  = color("#67fcdb")

    /// Return a color with hex: `#f7931e`.
    static let main        = color("#f7931e")
    /// Return a color with hex: `#ebebeb`.
    static let separator   = color("#ebebeb")
    /// Return a color with hex: `#d4d4d4`.
    static let disabled    = color("#d4d4d4")
}

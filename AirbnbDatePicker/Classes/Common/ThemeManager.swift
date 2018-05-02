//
//  ThemeManager.swift
//  AirbnbDatePicker
//
//  Created by mrfour on 2018/4/30.
//

import UIKit

public struct ThemeManager {
    public var mainColor = UIColor(hexString: "#4F86C6")
    public var textColor = UIColor(hexString: "#484848")
    public var disabledColor = UIColor(hexString: "#d4d4d4")
    public var separatorColor = UIColor(hexString: "#ebebeb")
    public var placeholderColor = UIColor(hexString: "#888888")

    public init() {}
}

public extension ThemeManager {
    public static let `default` = ThemeManager()
    public static var current: ThemeManager = .default
}

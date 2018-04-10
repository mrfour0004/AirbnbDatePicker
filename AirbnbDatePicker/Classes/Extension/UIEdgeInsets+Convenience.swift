//
//  UIEdgeInsets+Convenience.swift
//  Rakuemon
//
//  Created by mrfour on 17/05/2017.
//  Copyright © 2017 mrfour. All rights reserved.
//

import UIKit

extension UIEdgeInsets {
    init(inset: CGFloat) {
        self.init(top: inset, left: inset, bottom: inset, right: inset)
    }
    
    init(vertical: CGFloat, horizontal: CGFloat) {
        self.init(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
    }
}

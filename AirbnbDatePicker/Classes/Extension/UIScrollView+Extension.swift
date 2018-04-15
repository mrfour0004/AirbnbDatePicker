//
//  UIScrollView+Extension.swift
//  AirbnbDatePicker
//
//  Created by mrfour on 2018/4/10.
//

import UIKit

extension UIScrollView {
    func stopScroll() {
        setContentOffset(contentOffset, animated: false)
    }
}

// MARK: - Properties

extension UIScrollView {
    var maxScrollableOffset: CGPoint {
        let maxOffsetY = contentSize.height - bounds.height - contentInset.bottom
        let maxOffsetX = contentSize.width - bounds.width - contentInset.right

        return CGPoint(x: maxOffsetX, y: maxOffsetY)
    }

    var minScrollableOffset: CGPoint {
        let minOffsetY = -contentInset.top
        let minOffsetX = -contentInset.left

        return CGPoint(x: minOffsetX, y: minOffsetY)
    }

    var isScrolledToTop: Bool {
        let topEdge = 0 - contentInset.top
        return contentOffset.y <= topEdge
    }

    var isScrolledToBottom: Bool {
        let bottomEdge = contentSize.height + contentInset.bottom - bounds.height
        return contentOffset.y >= bottomEdge
    }
}

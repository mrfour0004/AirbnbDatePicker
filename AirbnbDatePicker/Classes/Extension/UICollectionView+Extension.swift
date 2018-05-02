//
//  UICollectionView+Extension.swift
//  AirbnbDatePicker
//
//  Created by mrfour on 2018/4/10.
//

import UIKit

extension UICollectionView {
    /// Scrolls through the collection view until a supplementary view identified by index path is at a particular location on the screen.
    ///
    /// - Parameters:
    ///   - kind: The kind of supplementary view to locate.
    ///   - indexPath: The index path of the supplementary view.
    ///   - scrollPosition: A constant that identifies a relative position in the collection view for supplementary view when scrolling concludes. See [UITableViewScrollPosition](https://developer.apple.com/documentation/uikit/uicollectionviewscrollposition) for descriptions of valid constants.
    ///   - animated: true if you want to animate the change in position; false if it should be immediate.
    func scrollToSupplementaryView(ofKind kind: String, at indexPath: IndexPath, at scrollPosition: UICollectionViewScrollPosition, animated: Bool) {
        guard let supplementaryFrame = layoutAttributesForSupplementaryElement(ofKind: kind, at: indexPath)?.frame else { return }

        var offsetY: CGFloat?
        var offsetX: CGFloat?
        switch scrollPosition {
        case .top:
            offsetY = supplementaryFrame.minY - contentInset.top
        case .centeredVertically:
            offsetY = supplementaryFrame.midY - contentInset.top - (frame.height - contentInset.top - contentInset.bottom)/2
        case .bottom:
            offsetY = supplementaryFrame.maxY - self.frame.height
        case UICollectionViewScrollPosition.left:
            offsetX = supplementaryFrame.minX
        case UICollectionViewScrollPosition.centeredHorizontally:
            offsetX = supplementaryFrame.minX
        case UICollectionViewScrollPosition.right:
            offsetX = supplementaryFrame.maxX
        default: break
        }

        let offset = CGPoint(x: max(minScrollableOffset.x, min(offsetX ?? contentOffset.x, maxScrollableOffset.x)), y: max(minScrollableOffset.y, min(offsetY ?? contentOffset.y, maxScrollableOffset.y)))
        setContentOffset(offset, animated: animated)
    }
}

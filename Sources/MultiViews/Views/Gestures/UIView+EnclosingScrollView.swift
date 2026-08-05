//
//  UIView+EnclosingScrollView.swift
//  MultiViews
//

#if canImport(UIKit)
import UIKit

extension UIView {

    /// The nearest scroll view above this view in the hierarchy.
    ///
    /// Used to let a gesture take priority over the scroll view's pan,
    /// via `panGestureRecognizer.require(toFail:)`.
    var enclosingScrollView: UIScrollView? {
        var view: UIView? = superview
        while let currentView = view {
            if let scrollView = currentView as? UIScrollView {
                return scrollView
            }
            view = currentView.superview
        }
        return nil
    }
}
#endif

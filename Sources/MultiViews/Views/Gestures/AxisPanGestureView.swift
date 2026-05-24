#if canImport(UIKit)
import SwiftUI
import UIKit

public struct AxisPanGestureView: UIViewRepresentable {
    
    public let axis: AxisPanGestureRecognizer.Axis
    public let minimumNumberOfTouches: Int
    public let maximumNumberOfTouches: Int
    public let cancelsTouchesInView: Bool
    public let requiresEnclosingScrollViewToFail: Bool
    public let onChanged: (UIPanGestureRecognizer) -> Void
    public let onEnded: (UIPanGestureRecognizer) -> Void
    
    public init(
        axis: AxisPanGestureRecognizer.Axis,
        minimumNumberOfTouches: Int = 1,
        maximumNumberOfTouches: Int = 1,
        cancelsTouchesInView: Bool = true,
        requiresEnclosingScrollViewToFail: Bool = true,
        onChanged: @escaping (UIPanGestureRecognizer) -> Void,
        onEnded: @escaping (UIPanGestureRecognizer) -> Void = { _ in }
    ) {
        self.axis = axis
        self.minimumNumberOfTouches = minimumNumberOfTouches
        self.maximumNumberOfTouches = maximumNumberOfTouches
        self.cancelsTouchesInView = cancelsTouchesInView
        self.requiresEnclosingScrollViewToFail = requiresEnclosingScrollViewToFail
        self.onChanged = onChanged
        self.onEnded = onEnded
    }
    
    public func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        
        let panGesture = AxisPanGestureRecognizer(
            axis: axis,
            target: context.coordinator,
            action: #selector(Coordinator.pan(_:))
        )
        panGesture.minimumNumberOfTouches = minimumNumberOfTouches
        panGesture.maximumNumberOfTouches = maximumNumberOfTouches
        panGesture.cancelsTouchesInView = cancelsTouchesInView
        view.addGestureRecognizer(panGesture)
        context.coordinator.panGesture = panGesture
        
        connectScrollView(from: view, context: context)
        
        return view
    }
    
    public func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.onChanged = onChanged
        context.coordinator.onEnded = onEnded
        context.coordinator.requiresEnclosingScrollViewToFail = requiresEnclosingScrollViewToFail
        context.coordinator.panGesture?.minimumNumberOfTouches = minimumNumberOfTouches
        context.coordinator.panGesture?.maximumNumberOfTouches = maximumNumberOfTouches
        context.coordinator.panGesture?.cancelsTouchesInView = cancelsTouchesInView
        
        connectScrollView(from: uiView, context: context)
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(
            requiresEnclosingScrollViewToFail: requiresEnclosingScrollViewToFail,
            onChanged: onChanged,
            onEnded: onEnded
        )
    }
    
    private func connectScrollView(from view: UIView, context: Context) {
        DispatchQueue.main.async {
            guard
                context.coordinator.requiresEnclosingScrollViewToFail,
                let panGesture = context.coordinator.panGesture,
                let scrollView = view.enclosingScrollView,
                context.coordinator.connectedScrollView !== scrollView
            else { return }
            
            scrollView.panGestureRecognizer.require(toFail: panGesture)
            context.coordinator.connectedScrollView = scrollView
        }
    }
    
    public final class Coordinator: NSObject {
        
        var panGesture: AxisPanGestureRecognizer?
        weak var connectedScrollView: UIScrollView?
        
        var requiresEnclosingScrollViewToFail: Bool
        var onChanged: (UIPanGestureRecognizer) -> Void
        var onEnded: (UIPanGestureRecognizer) -> Void
        
        init(
            requiresEnclosingScrollViewToFail: Bool,
            onChanged: @escaping (UIPanGestureRecognizer) -> Void,
            onEnded: @escaping (UIPanGestureRecognizer) -> Void
        ) {
            self.requiresEnclosingScrollViewToFail = requiresEnclosingScrollViewToFail
            self.onChanged = onChanged
            self.onEnded = onEnded
        }
        
        @objc
        func pan(_ gesture: UIPanGestureRecognizer) {
            switch gesture.state {
            case .began, .changed:
                onChanged(gesture)
            case .ended, .cancelled, .failed:
                onEnded(gesture)
            default:
                break
            }
        }
    }
}

private extension UIView {
    
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

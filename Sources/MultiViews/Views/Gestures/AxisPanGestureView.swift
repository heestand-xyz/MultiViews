#if canImport(UIKit)
import SwiftUI
import UIKit

public struct AxisPanGestureView: UIViewRepresentable {
    
    public let axis: AxisPanGestureRecognizer.Axis
    public let minimumDistance: CGFloat
    public let simultaneousGesture: Bool
    public let simultaneousMinimumDistance: CGFloat?
    public let minimumNumberOfTouches: Int
    public let maximumNumberOfTouches: Int
    public let cancelsTouchesInView: Bool
    public let requiresEnclosingScrollViewToFail: Bool
    public let onChanged: (UIPanGestureRecognizer) -> Void
    public let onEnded: (UIPanGestureRecognizer) -> Void
    public let onSimultaneousChanged: ((UIPanGestureRecognizer) -> Void)?
    public let onSimultaneousEnded: ((UIPanGestureRecognizer) -> Void)?
    
    public init(
        axis: AxisPanGestureRecognizer.Axis,
        minimumDistance: CGFloat = 10.0,
        simultaneousGesture: Bool = false,
        simultaneousMinimumDistance: CGFloat? = nil,
        minimumNumberOfTouches: Int = 1,
        maximumNumberOfTouches: Int = 1,
        cancelsTouchesInView: Bool = true,
        requiresEnclosingScrollViewToFail: Bool = true,
        onChanged: @escaping (UIPanGestureRecognizer) -> Void,
        onEnded: @escaping (UIPanGestureRecognizer) -> Void = { _ in },
        onSimultaneousChanged: ((UIPanGestureRecognizer) -> Void)? = nil,
        onSimultaneousEnded: ((UIPanGestureRecognizer) -> Void)? = nil
    ) {
        self.axis = axis
        self.minimumDistance = minimumDistance
        self.simultaneousGesture = simultaneousGesture
        self.simultaneousMinimumDistance = simultaneousMinimumDistance
        self.minimumNumberOfTouches = minimumNumberOfTouches
        self.maximumNumberOfTouches = maximumNumberOfTouches
        self.cancelsTouchesInView = cancelsTouchesInView
        self.requiresEnclosingScrollViewToFail = requiresEnclosingScrollViewToFail
        self.onChanged = onChanged
        self.onEnded = onEnded
        self.onSimultaneousChanged = onSimultaneousChanged
        self.onSimultaneousEnded = onSimultaneousEnded
    }
    
    public func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        
        let panGesture = AxisPanGestureRecognizer(
            axis: axis,
            minimumDistance: minimumDistance,
            target: context.coordinator,
            action: #selector(Coordinator.pan(_:))
        )
        panGesture.delegate = context.coordinator
        panGesture.minimumNumberOfTouches = minimumNumberOfTouches
        panGesture.maximumNumberOfTouches = maximumNumberOfTouches
        panGesture.cancelsTouchesInView = cancelsTouchesInView
        view.addGestureRecognizer(panGesture)
        context.coordinator.panGesture = panGesture
        updateSimultaneousPanGesture(from: view, context: context)
        
        connectScrollView(from: view, context: context)
        
        return view
    }
    
    public func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.simultaneousGesture = simultaneousGesture
        context.coordinator.onChanged = onChanged
        context.coordinator.onEnded = onEnded
        context.coordinator.onSimultaneousChanged = onSimultaneousChanged
        context.coordinator.onSimultaneousEnded = onSimultaneousEnded
        context.coordinator.requiresEnclosingScrollViewToFail = requiresEnclosingScrollViewToFail
        context.coordinator.panGesture?.minimumDistance = minimumDistance
        context.coordinator.panGesture?.minimumNumberOfTouches = minimumNumberOfTouches
        context.coordinator.panGesture?.maximumNumberOfTouches = maximumNumberOfTouches
        context.coordinator.panGesture?.cancelsTouchesInView = cancelsTouchesInView
        updateSimultaneousPanGesture(from: uiView, context: context)
        
        connectScrollView(from: uiView, context: context)
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(
            simultaneousGesture: simultaneousGesture,
            requiresEnclosingScrollViewToFail: requiresEnclosingScrollViewToFail,
            onChanged: onChanged,
            onEnded: onEnded,
            onSimultaneousChanged: onSimultaneousChanged,
            onSimultaneousEnded: onSimultaneousEnded
        )
    }
    
    private func updateSimultaneousPanGesture(from view: UIView, context: Context) {
        guard let simultaneousMinimumDistance, onSimultaneousChanged != nil else {
            if let simultaneousPanGesture = context.coordinator.simultaneousPanGesture {
                view.removeGestureRecognizer(simultaneousPanGesture)
                context.coordinator.simultaneousPanGesture = nil
            }
            return
        }
        
        if let simultaneousPanGesture = context.coordinator.simultaneousPanGesture {
            simultaneousPanGesture.minimumDistance = simultaneousMinimumDistance
            simultaneousPanGesture.minimumNumberOfTouches = minimumNumberOfTouches
            simultaneousPanGesture.maximumNumberOfTouches = maximumNumberOfTouches
        } else {
            let simultaneousPanGesture = AxisPanGestureRecognizer(
                axis: .none,
                minimumDistance: simultaneousMinimumDistance,
                target: context.coordinator,
                action: #selector(Coordinator.simultaneousPan(_:))
            )
            simultaneousPanGesture.delegate = context.coordinator
            simultaneousPanGesture.minimumNumberOfTouches = minimumNumberOfTouches
            simultaneousPanGesture.maximumNumberOfTouches = maximumNumberOfTouches
            simultaneousPanGesture.cancelsTouchesInView = false
            view.addGestureRecognizer(simultaneousPanGesture)
            context.coordinator.simultaneousPanGesture = simultaneousPanGesture
        }
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
    
    public final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        
        var panGesture: AxisPanGestureRecognizer?
        var simultaneousPanGesture: AxisPanGestureRecognizer?
        weak var connectedScrollView: UIScrollView?
        
        var simultaneousGesture: Bool
        var requiresEnclosingScrollViewToFail: Bool
        var onChanged: (UIPanGestureRecognizer) -> Void
        var onEnded: (UIPanGestureRecognizer) -> Void
        var onSimultaneousChanged: ((UIPanGestureRecognizer) -> Void)?
        var onSimultaneousEnded: ((UIPanGestureRecognizer) -> Void)?
        
        init(
            simultaneousGesture: Bool,
            requiresEnclosingScrollViewToFail: Bool,
            onChanged: @escaping (UIPanGestureRecognizer) -> Void,
            onEnded: @escaping (UIPanGestureRecognizer) -> Void,
            onSimultaneousChanged: ((UIPanGestureRecognizer) -> Void)?,
            onSimultaneousEnded: ((UIPanGestureRecognizer) -> Void)?
        ) {
            self.simultaneousGesture = simultaneousGesture
            self.requiresEnclosingScrollViewToFail = requiresEnclosingScrollViewToFail
            self.onChanged = onChanged
            self.onEnded = onEnded
            self.onSimultaneousChanged = onSimultaneousChanged
            self.onSimultaneousEnded = onSimultaneousEnded
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
        
        @objc
        func simultaneousPan(_ gesture: UIPanGestureRecognizer) {
            switch gesture.state {
            case .began, .changed:
                onSimultaneousChanged?(gesture)
            case .ended, .cancelled, .failed:
                onSimultaneousEnded?(gesture)
            default:
                break
            }
        }
        
        public func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
        ) -> Bool {
            let isMainPanGesture = gestureRecognizer === panGesture
                || otherGestureRecognizer === panGesture
            let isSimultaneousPanGesture = gestureRecognizer === simultaneousPanGesture
                || otherGestureRecognizer === simultaneousPanGesture
            let isScrollPanGesture = gestureRecognizer === connectedScrollView?.panGestureRecognizer
                || otherGestureRecognizer === connectedScrollView?.panGestureRecognizer
            
            if requiresEnclosingScrollViewToFail, isMainPanGesture, isScrollPanGesture {
                return false
            }
            if isSimultaneousPanGesture { return true }
            guard simultaneousGesture else { return false }
            return true
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

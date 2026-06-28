#if canImport(UIKit)
import UIKit

public final class AxisPanGestureRecognizer: UIPanGestureRecognizer {
    
    public enum Axis: Equatable {
        case horizontal
        case vertical
        case none
    }
    
    public let axis: Axis
    public var minimumDistance: CGFloat
    
    private var startLocation: CGPoint?
    
    public init(axis: Axis, minimumDistance: CGFloat = 10.0, target: Any?, action: Selector?) {
        self.axis = axis
        self.minimumDistance = minimumDistance
        super.init(target: target, action: action)
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        startLocation = touches.first?.location(in: view)
        super.touchesBegan(touches, with: event)
        
        if axis == .none, minimumDistance <= 0.0, state == .possible {
            state = .began
        }
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        if state == .possible, let startLocation, let currentLocation = touches.first?.location(in: view) {
            let translation = CGPoint(
                x: currentLocation.x - startLocation.x,
                y: currentLocation.y - startLocation.y
            )
            let distance = hypot(translation.x, translation.y)
            guard distance >= minimumDistance else { return }
            
            switch axis {
            case .horizontal:
                if abs(translation.y) > abs(translation.x) {
                    state = .failed
                    return
                }
            case .vertical:
                if abs(translation.x) > abs(translation.y) {
                    state = .failed
                    return
                }
            case .none:
                break
            }
        }
        
        super.touchesMoved(touches, with: event)
    }
    
    public override func reset() {
        startLocation = nil
        super.reset()
    }
}
#endif

#if canImport(UIKit)
import UIKit

public final class AxisPanGestureRecognizer: UIPanGestureRecognizer {
    
    public enum Axis {
        case horizontal
        case vertical
    }
    
    public let axis: Axis
    
    public init(axis: Axis, target: Any?, action: Selector?) {
        self.axis = axis
        super.init(target: target, action: action)
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        let velocity: CGPoint = velocity(in: view)
        
        if state == .possible {
            switch axis {
            case .horizontal:
                if abs(velocity.y) > abs(velocity.x) {
                    state = .failed
                }
            case .vertical:
                if abs(velocity.x) > abs(velocity.y) {
                    state = .failed
                }
            }
        }
        
        super.touchesMoved(touches, with: event)
    }
}
#endif

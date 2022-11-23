#if os(macOS)
import AppKit
#else
import UIKit
#endif

#if os(macOS)
public typealias MPView = NSView
#else
public typealias MPView = UIView
#endif

#if os(macOS)
public extension NSView {
    var alpha: CGFloat {
        get {
            CGFloat(layer?.opacity ?? 1.0)
        }
        set {
            wantsLayer = true
            layer!.opacity = Float(newValue)
        }
    }
}
#endif

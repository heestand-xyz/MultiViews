//
//  Created by Heestand XYZ on 2020-12-07.
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
import SwiftUI
import CoreGraphicsExtensions

public enum MVInteraction {
    case started
    case endedInside
    case endedOutside
    var ended: Bool { self != .started }
}
    
public struct MVInteractView: ViewRepresentable {
    
    let passthrough: Bool
    let interacted: (MVInteraction) -> ()
    let interacting: ((CGPoint) -> ())?
    let scrolling: ((CGPoint) -> ())?

    public init(passthrough: Bool = false,
                interacted: @escaping (MVInteraction) -> (),
                interacting: ((CGPoint) -> ())? = nil,
                scrolling: ((CGPoint) -> ())? = nil) {
        self.passthrough = passthrough
        self.interacted = interacted
        self.interacting = interacting
        self.scrolling = scrolling
    }
    
    public func makeView(context: Context) -> MPView {
        MainInteractView(passthrough: passthrough, interacted: interacted, interacting: interacting, scrolling: scrolling)
    }
    public func updateView(_ view: MPView, context: Context) {}
}

class MainInteractView: MPView {
    
    let passthrough: Bool
    let interacted: (MVInteraction) -> ()
    let interacting: ((CGPoint) -> ())?
    let scrolling: ((CGPoint) -> ())?
    
    init(passthrough: Bool,
         interacted: @escaping (MVInteraction) -> (),
         interacting: ((CGPoint) -> ())?,
         scrolling: ((CGPoint) -> ())? = nil) {
        self.passthrough = passthrough
        self.interacted = interacted
        self.interacting = interacting
        self.scrolling = scrolling
        super.init(frame: .zero)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    #if os(iOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        interacted(.started)
        let location: CGPoint = touches.first!.location(in: self)
        interacting?(location)
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location: CGPoint = touches.first!.location(in: self)
        interacting?(location)
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let inside: Bool = bounds.contains(touches.first!.location(in: self))
        interacted(inside ? .endedInside : .endedOutside)
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        interacted(.endedOutside)
    }
    #endif
    
    #if os(macOS)
    override func mouseDown(with event: NSEvent) {
        interacted(.started)
        guard let location: CGPoint = getMouseLocation() else { return }
        interacting?(location)
    }
    override func mouseDragged(with event: NSEvent) {
        guard let location: CGPoint = getMouseLocation() else { return }
        interacting?(location)
    }
    override func mouseUp(with event: NSEvent) {
        guard let location: CGPoint = getMouseLocation() else { return }
        let inside: Bool = bounds.contains(location)
        interacted(inside ? .endedInside : .endedOutside)
    }
    override func scrollWheel(with event: NSEvent) {
        scrolling?(CGPoint(x: event.scrollingDeltaX, y: event.scrollingDeltaY))
    }
    func getMouseLocation() -> CGPoint? {
        guard let window: NSWindow = window else { return nil }
        let mouseLocation: CGPoint = window.mouseLocationOutsideOfEventStream
        guard let windowView: NSView = window.contentView else { return nil }
        var point: CGPoint = convert(.zero, to: windowView)
        if point.y == 0.0 { point = convert(CGPoint(x: 0.0, y: windowView.bounds.height), to: windowView) }
        let origin: CGPoint = CGPoint(x: point.x, y: windowView.bounds.size.height - point.y)
        let location: CGPoint = mouseLocation - origin
        let finalLocation: CGPoint = CGPoint(x: location.x, y: bounds.size.height - location.y)
        return finalLocation
    }
    #endif
    
    #if os(macOS)
    override func hitTest(_ point: NSPoint) -> NSView? {
        let view = super.hitTest(point)
        if passthrough {
            if view == self {
                interacting?(point)
                return nil
            }
        }
        return view
    }
    #else
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if passthrough {
            if view == self {
                interacting?(point)
                return nil
            }
        }
        return view
    }
    #endif
}

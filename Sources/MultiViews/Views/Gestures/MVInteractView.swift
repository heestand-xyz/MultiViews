//
//  Created by Heestand XYZ on 2020-12-07.
//

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif
import SwiftUI
import CoreGraphicsExtensions

public enum MVInteraction {
    case started
    case entered
    case exited
    case endedInside
    case endedOutside
    public var ended: Bool { [.endedInside, .endedOutside].contains(self) }
}
    
public struct MVInteractView: ViewRepresentable {
    
    let interacted: (MVInteraction) -> ()
    let interacting: ((CGPoint) -> ())?
    let scrolling: ((CGPoint) -> ())?

    public init(interacted: @escaping (MVInteraction) -> (),
                interacting: ((CGPoint) -> ())? = nil,
                scrolling: ((CGPoint) -> ())? = nil) {
        self.interacted = interacted
        self.interacting = interacting
        self.scrolling = scrolling
    }
    
    public func makeView(context: Context) -> MPView {
        MainInteractView(interacted: interacted, interacting: interacting, scrolling: scrolling)
    }
    public func updateView(_ view: MPView, context: Context) {}
}

class MainInteractView: MPView {
    
    let interacted: (MVInteraction) -> ()
    let interacting: ((CGPoint) -> ())?
    let scrolling: ((CGPoint) -> ())?
    
    private var isInside: Bool?
#if os(macOS)
    private var isInteracting: Bool = false
#endif
    
    init(interacted: @escaping (MVInteraction) -> (),
         interacting: ((CGPoint) -> ())?,
         scrolling: ((CGPoint) -> ())? = nil) {
        self.interacted = interacted
        self.interacting = interacting
        self.scrolling = scrolling
        super.init(frame: .zero)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    #if os(iOS) || os(visionOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        interacted(.started)
        let location: CGPoint = touches.first!.location(in: self)
        interacting?(location)
        isInside = true
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location: CGPoint = touches.first!.location(in: self)
        let isInside: Bool = bounds.contains(location)
        if self.isInside != isInside {
            interacted(isInside ? .entered : .exited)
            self.isInside = isInside
        }
        interacting?(location)
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        interacted(isInside == true ? .endedInside : .endedOutside)
        isInside = nil
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        interacted(.endedOutside)
        isInside = nil
    }
    #endif
    
    #if os(macOS)
    override func mouseDown(with event: NSEvent) {
        interacted(.started)
        guard let location: CGPoint = getMouseLocation() else { return }
        interacting?(location)
        isInside = true
        isInteracting = true
    }
    override func mouseDragged(with event: NSEvent) {
        guard isInteracting else { return }
        guard let location: CGPoint = getMouseLocation() else { return }
        let isInside: Bool = bounds.contains(location)
        if self.isInside != isInside {
            interacted(isInside ? .entered : .exited)
            self.isInside = isInside
        }
        interacting?(location)
    }
    override func mouseUp(with event: NSEvent) {
        interacted(isInside == true ? .endedInside : .endedOutside)
        isInside = nil
        isInteracting = false
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
}

//
//  Created by Heestand XYZ on 2020-12-07.
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
import SwiftUI

public struct MVMultiInteraction {
    public let id: UUID
    public let interaction: MVInteraction
    public let location: CGPoint
}

public struct MVMultiInteracting {
    public let id: UUID
    public let location: CGPoint
}

public struct MVMultiInteractView: ViewRepresentable {
    
    let interacted: ([MVMultiInteraction]) -> ()
    let interacting: (([MVMultiInteracting]) -> ())?

    public init(interacted: @escaping ([MVMultiInteraction]) -> (),
                interacting: (([MVMultiInteracting]) -> ())? = nil) {
        self.interacted = interacted
        self.interacting = interacting
    }
    
    public func makeView(context: Context) -> MPView {
        MainMultiInteractView(interacted: interacted, interacting: interacting)
    }
    public func updateView(_ view: MPView, context: Context) {}
}

class MainMultiInteractView: MPView {
    
    let interacted: ([MVMultiInteraction]) -> ()
    let interacting: (([MVMultiInteracting]) -> ())?
   
    #if os(iOS)
    var touchIDs: [UUID: UITouch] = [:]
    #elseif os(macOS)
    var clickID: UUID?
    #endif
    
    init(interacted: @escaping ([MVMultiInteraction]) -> (),
         interacting: (([MVMultiInteracting]) -> ())?) {
        self.interacted = interacted
        self.interacting = interacting
        super.init(frame: .zero)
        #if os(iOS)
        self.isMultipleTouchEnabled = true
        #endif
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    #if os(iOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let interactions: [MVMultiInteraction] = touches.map { touch in
            let id = UUID()
            let location: CGPoint = touch.location(in: self)
            touchIDs[id] = touch
            return MVMultiInteraction(id: id, interaction: .started, location: location)
        }
        interacted(interactions)
        let interactings: [MVMultiInteracting] = interactions.map({ interaction in
            MVMultiInteracting(id: interaction.id, location: interaction.location)
        })
        interacting?(interactings)
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let interactings: [MVMultiInteracting] = touches.compactMap { touch in
            guard let id: UUID = touchIDs.first(where: { $0.value == touch })?.key else { return nil }
            let location: CGPoint = touch.location(in: self)
            return MVMultiInteracting(id: id, location: location)
        }
        interacting?(interactings)
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let interactions: [MVMultiInteraction] = touches.compactMap { touch in
            guard let id: UUID = touchIDs.first(where: { $0.value == touch })?.key else { return nil }
            let location: CGPoint = touch.location(in: self)
            let inside: Bool = bounds.contains(location)
            touchIDs.removeValue(forKey: id)
            return MVMultiInteraction(id: id, interaction: inside ? .endedInside : .endedOutside, location: location)
        }
        interacted(interactions)
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        let interactions: [MVMultiInteraction] = touches.compactMap { touch in
            guard let id: UUID = touchIDs.first(where: { $0.value == touch })?.key else { return nil }
            let location: CGPoint = touch.location(in: self)
            touchIDs.removeValue(forKey: id)
            return MVMultiInteraction(id: id, interaction: .endedOutside, location: location)
        }
        interacted(interactions)
    }
    #endif
    
    #if os(macOS)
    override func mouseDown(with event: NSEvent) {
        clickID = UUID()
        guard let location: CGPoint = getMouseLocation(event: event) else { return }
        interacted([MVMultiInteraction(id: clickID!, interaction: .started, location: location)])
        interacting?([MVMultiInteracting(id: clickID!, location: location)])
    }
    override func mouseDragged(with event: NSEvent) {
        guard let id: UUID = clickID else { return }
        guard let location: CGPoint = getMouseLocation(event: event) else { return }
        interacting?([MVMultiInteracting(id: id, location: location)])
    }
    override func mouseUp(with event: NSEvent) {
        defer { clickID = nil }
        guard let id: UUID = clickID else { return }
        guard let location: CGPoint = getMouseLocation(event: event) else { return }
        let inside: Bool = bounds.contains(location)
        interacted([MVMultiInteraction(id: id, interaction: inside ? .endedInside : .endedOutside, location: location)])
    }
    func getMouseLocation(event: NSEvent) -> CGPoint? {
        let mouseLocation: CGPoint = event.locationInWindow
        guard let vcView: NSView = window?.contentViewController?.view else { return nil }
        let point: CGPoint = convert(.zero, to: vcView)
        let origin: CGPoint = CGPoint(x: point.x, y: vcView.bounds.size.height - point.y)
        let location: CGPoint = CGPoint(x: mouseLocation.x - origin.x, y: mouseLocation.y - origin.y)
        return location
    }
    #endif
}

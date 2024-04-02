//
//  Created by Heestand XYZ on 2020-12-07.
//

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
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
   
    #if os(iOS) || os(visionOS)
    var touchIDs: [UUID: UITouch] = [:]
    #elseif os(macOS)
    var clickID: UUID?
    #endif
    
    var isInsides: [UUID: Bool] = [:]
    
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
    
    #if os(iOS) || os(visionOS)
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
        for interaction in interactions {
            isInsides[interaction.id] = true
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let interactings: [MVMultiInteracting] = touches.compactMap { touch in
            guard let id: UUID = touchIDs.first(where: { $0.value == touch })?.key else { return nil }
            let location: CGPoint = touch.location(in: self)
            return MVMultiInteracting(id: id, location: location)
        }
        let interactions: [MVMultiInteraction] = interactings.compactMap { interacting in
            let wasInside: Bool = isInsides[interacting.id] ?? false
            let isInside: Bool = bounds.contains(interacting.location)
            if wasInside == isInside { return nil }
            return MVMultiInteraction(id: interacting.id, interaction: isInside ? .entered : .exited, location: interacting.location)
        }
        if !interactions.isEmpty {
            interacted(interactions)
        }
        interacting?(interactings)
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let interactions: [MVMultiInteraction] = touches.compactMap { touch in
            guard let id: UUID = touchIDs.first(where: { $0.value == touch })?.key else { return nil }
            let location: CGPoint = touch.location(in: self)
            let isInside: Bool = isInsides[id] ?? false
            touchIDs.removeValue(forKey: id)
            return MVMultiInteraction(id: id, interaction: isInside ? .endedInside : .endedOutside, location: location)
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
        let id = UUID()
        clickID = id
        guard let location: CGPoint = getMouseLocation(event: event) else { return }
        interacted([MVMultiInteraction(id: id, interaction: .started, location: location)])
        interacting?([MVMultiInteracting(id: id, location: location)])
        isInsides[id] = true
    }
    override func mouseDragged(with event: NSEvent) {
        guard let id: UUID = clickID else { return }
        guard let location: CGPoint = getMouseLocation(event: event) else { return }
        let isInside: Bool = bounds.contains(location)
        if self.isInsides[id] != isInside {
            interacted([MVMultiInteraction(id: id, interaction: isInside ? .entered : .exited, location: location)])
            self.isInsides[id] = isInside
        }
        interacting?([MVMultiInteracting(id: id, location: location)])
    }
    override func mouseUp(with event: NSEvent) {
        defer { clickID = nil }
        guard let id: UUID = clickID else { return }
        guard let location: CGPoint = getMouseLocation(event: event) else { return }
        interacted([MVMultiInteraction(id: id, interaction: isInsides[id] == true ? .endedInside : .endedOutside, location: location)])
        isInsides.removeValue(forKey: id)
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

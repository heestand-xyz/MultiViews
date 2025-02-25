//
//  SecondaryView.swift
//  MultiViews
//
//  Created by Anton on 2025-02-25.
//

#if os(macOS)

import AppKit
import SwiftUI
import CoreGraphicsExtensions

public extension View {
    func secondaryClick(action: @escaping (CGPoint) -> Void) -> some View {
        SecondaryView(action: action) {
            self
        }
    }
}

struct SecondaryView<Content: View>: NSViewRepresentable {
    
    let action: (CGPoint) -> Void
    let content: () -> Content
    
    func makeNSView(context: Context) -> SecondaryViewNSView {
        let hostingController = NSHostingController(rootView: content())
        context.coordinator.hostingController = hostingController
        let contentView: NSView = hostingController.view
        return SecondaryViewNSView(action: action, contentView: contentView)
    }
    
    func updateNSView(_ trackpadView: SecondaryViewNSView, context: Context) {
        context.coordinator.refresh()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(content: content)
    }
    
    class Coordinator {

        private let content: () -> Content

        var hostingController: NSHostingController<Content>?

        init(content: @escaping () -> Content) {
            self.content = content
        }

        func refresh() {
            hostingController?.rootView = content()
        }
    }
}

public class SecondaryViewNSView: NSView {
    
    let action: (CGPoint) -> Void
    
    private let contentView: NSView?
    
    public var canBecomeFirstResponder: Bool { true }
    
    public init(
        action: @escaping (CGPoint) -> Void,
        contentView: NSView?
    ) {
        
        self.action = action
        
        self.contentView = contentView

        super.init(frame: .zero)
        
        if let contentView {
            contentView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(contentView)
            NSLayoutConstraint.activate([
                contentView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
                contentView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
                contentView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
                contentView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            ])
        }
        
        becomeFirstResponder()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        action.description.contains("context")
    }
    
    // MARK: - Click
    
    public override func rightMouseUp(with event: NSEvent) {
        guard let location = getMouseLocation() else { return }
        action(location)
    }
    
    // MARK: - Mouse
    
    private func getMouseLocation() -> CGPoint? {
        guard let window: NSWindow else { return nil }
        let mouseLocation: CGPoint = window.mouseLocationOutsideOfEventStream
        guard let windowView: NSView = window.contentView else { return nil }
        var point: CGPoint = convert(.zero, to: windowView)
        if point.y == 0.0 { point = convert(CGPoint(x: 0.0, y: windowView.bounds.height), to: windowView) }
        let origin: CGPoint = CGPoint(x: point.x, y: windowView.bounds.size.height - point.y)
        let location: CGPoint = mouseLocation - origin
        let finalLocation: CGPoint = CGPoint(x: location.x, y: bounds.size.height - location.y)
        return finalLocation
    }
    
    // MARK: - NaN
    
    private func isNaN(_ value: CGFloat) -> Bool {
        value == .nan || "\(value)".lowercased() == "nan"
    }
}

#endif

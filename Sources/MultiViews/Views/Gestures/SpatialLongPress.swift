//
//  SpatialLongPress.swift
//  MultiViews
//
//  Created by a-heestand on 2025/01/10.
//

import SwiftUI
#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension View {
    
    public func onSpatialLongPress(
        duration: TimeInterval,
        didStart: @escaping (_ location: CGPoint) -> Void,
        didEnd: @escaping (_ success: Bool, _ location: CGPoint) -> Void
    ) -> some View {
        SpatialLongPressView(
            duration: duration,
            content: { self },
            didStart: didStart,
            didEnd: didEnd
        )
    }
}

struct SpatialLongPressView<Content: View>: ViewRepresentable {
    
    let duration: TimeInterval
    let content: () -> Content
    let didStart: (CGPoint) -> Void
    let didEnd: (Bool, CGPoint) -> Void
    
    func makeView(context: Context) -> MVSpatialLongPressView<Content> {
        MVSpatialLongPressView(
            duration: duration,
            content: content,
            didStart: didStart,
            didEnd: didEnd
        )
    }
    
    func updateView(_ view: MVSpatialLongPressView<Content>, context: Context) {
        view.updateView()
    }
}

#if os(macOS)

class MVSpatialLongPressView<Content: View>: NSView {
    
    private let duration: TimeInterval
    private let content: () -> Content
    private let didStart: (CGPoint) -> Void
    private let didEnd: (Bool, CGPoint) -> Void
    
    private let hostingController: MPHostingController<Content>
    
    private var startLocation: CGPoint?
    
    private var isActive: Bool = false
    
    private var timer: Timer?
    
    init(
        duration: TimeInterval,
        content: @escaping () -> Content,
        didStart: @escaping (CGPoint) -> Void,
        didEnd: @escaping (Bool, CGPoint) -> Void
    ) {
        self.duration = duration
        self.content = content
        self.didStart = didStart
        self.didEnd = didEnd
        hostingController = MPHostingController(rootView: content())
        super.init(frame: .zero)
        setupSubview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateView() {
        hostingController.rootView = content()
    }
    
    private func setupSubview() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
        addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        isActive = true
        startLocation = event.locationInWindow
        didStart(event.locationInWindow)
        timer = .scheduledTimer(withTimeInterval: duration, repeats: false, block: { [weak self] _ in
            self?.didEnd(true, event.locationInWindow)
            self?.startLocation = nil
            self?.isActive = false
        })
    }
    
    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        guard isActive else { return }
        timer?.invalidate()
        didEnd(false, event.locationInWindow)
        startLocation = nil
        isActive = false
    }
    
    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)
        guard isActive else { return }
        guard let startLocation: CGPoint else { return }
        let x: CGFloat = event.locationInWindow.x - startLocation.x
        let y: CGFloat = event.locationInWindow.y - startLocation.y
        if hypot(x, y) > 10 {
            timer?.invalidate()
            didEnd(false, event.locationInWindow)
            self.startLocation = nil
            isActive = false
        }
    }
}

#else

class MVSpatialLongPressView<Content: View>: UIView {
    
    private let duration: TimeInterval
    private let content: () -> Content
    private let didStart: (CGPoint) -> Void
    private let didEnd: (Bool, CGPoint) -> Void
    
    private let hostingController: MPHostingController<Content>
    
    private var isActive: Bool = false

    private var timer: Timer?
    
    init(
        duration: TimeInterval,
        content: @escaping () -> Content,
        didStart: @escaping (CGPoint) -> Void,
        didEnd: @escaping (Bool, CGPoint) -> Void
    ) {
        self.duration = duration
        self.content = content
        self.didStart = didStart
        self.didEnd = didEnd
        hostingController = MPHostingController(rootView: content())
        super.init(frame: .zero)
        setupSubview()
        setupGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateView() {
        hostingController.rootView = content()
    }
    
    private func setupSubview() {
        hostingController.view.backgroundColor = .clear
        addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    private func setupGesture() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        longPressGesture.minimumPressDuration = 0.0
        longPressGesture.cancelsTouchesInView = false
        addGestureRecognizer(longPressGesture)
    }
    
    @objc
    private func longPress(gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .recognized:
            guard isActive else { return }
            timer?.invalidate()
            didEnd(false, gesture.location(in: self))
            isActive = false
        case .began:
            isActive = true
            didStart(gesture.location(in: self))
            timer = .scheduledTimer(withTimeInterval: duration, repeats: false, block: { [weak self] _ in
                self?.didEnd(true, gesture.location(in: self))
                self?.isActive = false
            })
        case .cancelled:
            break
        case .ended:
            break
        case .changed:
            guard isActive else { return }
            timer?.invalidate()
            didEnd(false, gesture.location(in: self))
            isActive = false
        case .failed:
            break
        default:
            break
        }
    }
}

#endif

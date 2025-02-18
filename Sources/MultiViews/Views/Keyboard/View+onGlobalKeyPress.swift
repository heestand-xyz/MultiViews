//
//  View+onGlobalKeyPress.swift
//  MultiViews
//
//  Created by a-heestand on 2025/02/18.
//

import SwiftUI
#if os(macOS)
import AppKit
#else
import UIKit
#endif

public struct MVKeyPress {
    let character: Character
    enum Flag {
        case command
        case shift
        case control
        case option
    }
    let flags: Set<Flag>
}

extension View {
    public func onGlobalKeyPress(_ action: @escaping (MVKeyPress) -> Void) -> some View {
        MVKeyboardViewRepresentable(action: action) {
            self
        }
    }
}

struct MVKeyboardViewRepresentable<Content: View>: ViewRepresentable {
    
    let action: (MVKeyPress) -> Void
    let content: () -> Content
    
    func makeView(context: Context) -> MVKeyboardView<Content> {
        MVKeyboardView(action: action, content: content)
    }
    
    func updateView(_ view: MVKeyboardView<Content>, context: Context) {
        view.update()
    }
}

final class MVKeyboardView<Content: View>: MPView {
    
    let action: (MVKeyPress) -> Void
    let content: () -> Content
    
    let hostingController: MPHostingController<Content>
    
    init(action: @escaping (MVKeyPress) -> Void, content: @escaping () -> Content) {
        self.action = action
        self.content = content
        hostingController = MPHostingController(rootView: content())
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update() {
        hostingController.rootView = content()
    }
    
    private func setupView() {
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(hostingController.view)
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
#if os(macOS)
    override var acceptsFirstResponder: Bool { true }
    override func keyDown(with event: NSEvent) {
        guard let characters = event.characters, let character = characters.first else { return }
        var flags = Set<MVKeyPress.Flag>()
        if event.modifierFlags.contains(.command) { flags.insert(.command) }
        if event.modifierFlags.contains(.shift) { flags.insert(.shift) }
        if event.modifierFlags.contains(.control) { flags.insert(.control) }
        if event.modifierFlags.contains(.option) { flags.insert(.option) }
        action(MVKeyPress(character: character, flags: flags))
    }
#else
    override var canBecomeFirstResponder: Bool { true }
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        for press in presses {
            guard let key = press.key, let character = key.characters.first else { continue }
            var flags = Set<MVKeyPress.Flag>()
            if key.modifierFlags.contains(.command) { flags.insert(.command) }
            if key.modifierFlags.contains(.shift) { flags.insert(.shift) }
            if key.modifierFlags.contains(.control) { flags.insert(.control) }
            if key.modifierFlags.contains(.alternate) { flags.insert(.option) }
            action(MVKeyPress(character: character, flags: flags))
        }
        super.pressesBegan(presses, with: event)
    }
#endif
}

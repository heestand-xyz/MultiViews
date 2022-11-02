//
//  ModifierFlags.swift
//  
//
//  Created by Anton Heestand on 2022-11-02.
//

#if os(macOS)

import SwiftUI

extension View {
    
    public func keyboard(flags modifierFlags: NSEvent.ModifierFlags, active: Binding<Bool>) -> some View {
        self.background(KeyboardFlagViewRepresentable(modifierFlags: modifierFlags,
                                                      active: active))
    }
}

struct KeyboardFlagViewRepresentable: ViewRepresentable {
    
    let modifierFlags: NSEvent.ModifierFlags
    @Binding var active: Bool
    
    func makeView(context: Context) -> KeyboardFlagView {
        KeyboardFlagView(modifierFlags: modifierFlags,
                         active: $active)
    }
    
    func updateView(_ view: KeyboardFlagView, context: Context) {}
}

class KeyboardFlagView: MPView {
    
    let modifierFlags: NSEvent.ModifierFlags
    @Binding var active: Bool
    
    init(modifierFlags: NSEvent.ModifierFlags, active: Binding<Bool>) {
        self.modifierFlags = modifierFlags
        _active = active
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { [weak self] in
            self?.flagsChanged(with: $0)
            return $0
        }
    }
   
    override func flagsChanged(with event: NSEvent) {
        active = modifierFlags == event.modifierFlags.intersection(.deviceIndependentFlagsMask)
    }
}

#endif

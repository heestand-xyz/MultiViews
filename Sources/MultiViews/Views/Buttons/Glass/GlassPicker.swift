//
//  GlassPicker.swift
//  MultiViews
//
//  Created by Anton Heestand on 2025-07-15.
//

import SwiftUI

public enum GlassPickerStyleType {
    case regular(shape: GlassShape)
    case native(shape: GlassShape)
    case tinted(backgroundColor: Color?, shape: GlassShape)
    case nativeTinted(backgroundColor: Color?, shape: GlassShape)
    public static func tintedAccent(tintEnabled: Bool = true, shape: GlassShape) -> Self {
        .tinted(
            backgroundColor: tintEnabled ? .accentColor : nil,
            shape: shape
        )
    }
    public static func nativeTintedAccent(tintEnabled: Bool = true, shape: GlassShape) -> Self {
        .nativeTinted(
            backgroundColor: tintEnabled ? .accentColor : nil,
            shape: shape
        )
    }
    var backgroundColor: Color? {
        switch self {
        case .regular, .native:
            nil
        case .tinted(let backgroundColor, _),
                .nativeTinted(let backgroundColor, _):
            backgroundColor
        }
    }
    var shape: GlassShape {
        switch self {
        case .regular(let shape),
                .native(let shape),
                .tinted(_, let shape),
                .nativeTinted(_, let shape):
            shape
        }
    }
    var isNative: Bool {
        switch self {
        case .native, .nativeTinted:
            true
        case .regular, .tinted:
            false
        }
    }
}

public struct GlassPicker<SelectionValue: Hashable, Content: View>: View {
    
    var style: GlassPickerStyleType
    var hitPadding: CGFloat = 0.0
    let selection: Binding<SelectionValue>
    let content: () -> Content
    
    public init(
        selection: Binding<SelectionValue>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.selection = selection
        self.style = .regular(shape: .capsule)
        self.content = content
    }
    
    public var body: some View {
#if !os(visionOS)
        if #available(iOS 26.0, macOS 26.0, *) {
            glassPicker
        } else {
            frostPicker
        }
#else
        frostPicker
#endif
    }

#if !os(visionOS)
    
    @available(iOS 26.0, macOS 26.0, *)
    @ViewBuilder
    private var glassPicker: some View {
        if style.isNative {
            nativeGlassPicker
        } else {
            customGlassPicker
        }
    }
    
    @available(iOS 26.0, macOS 26.0, *)
    private var nativeGlassPicker: some View {
        Group {
            if let backgroundColor = style.backgroundColor {
                nativeGlassAsyncPicker
                    .buttonStyle(.glassProminent)
                    .tint(backgroundColor)
            } else {
                nativeGlassAsyncPicker
                    .buttonStyle(.glass(.regular))
            }
        }
    }
    
    private var nativeGlassAsyncPicker: some View {
        Picker(selection: selection) {
            content()
        } label: {
            EmptyView()
        }
        .labelsHidden()
        .pickerStyle(.menu)
        .menuStyle(.button)
        .buttonBorderShape(style.shape.buttonBorder)
#if !os(macOS)
        .hoverEffect()
#endif
    }
    
    
    @available(iOS 26.0, macOS 26.0, *)
    private var customGlassPicker: some View {
        Picker(selection: selection) {
            content()
        } label: {
            EmptyView()
        }
        .labelsHidden()
        .pickerStyle(.menu)
        .menuStyle(.button)
        .buttonStyle(.plain)
        .buttonBorderShape(style.shape.buttonBorder)
        .padding(-hitPadding)
    }
    
#endif
    
    private var frostPicker: some View {
        Picker(selection: selection) {
            content()
        } label: {
            EmptyView()
        }
        .labelsHidden()
        .pickerStyle(.menu)
        .menuStyle(.button)
        .buttonStyle(.plain)
        .padding(-hitPadding)
    }
}

extension GlassPicker {
    public func glassPickerStyle(_ style: GlassPickerStyleType) -> GlassPicker {
        var glassPicker: GlassPicker = self
        glassPicker.style = style
        return glassPicker
    }
}

extension GlassPicker {
    public func glassHitPadding(_ padding: CGFloat) -> GlassPicker {
        var glassPicker: GlassPicker = self
        glassPicker.hitPadding = padding
        return glassPicker
    }
}

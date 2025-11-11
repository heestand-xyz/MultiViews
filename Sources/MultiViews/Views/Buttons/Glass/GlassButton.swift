//
//  GlassButton.swift
//  MultiViews
//
//  Created by Anton Heestand on 2025-07-15.
//

import SwiftUI

public enum GlassButtonStyleType {
    case regular(shape: GlassShape, asyncStyle: AsyncButtonStyle = .default)
    case native(shape: GlassShape, asyncStyle: AsyncButtonStyle = .default)
    case tinted((foreground: Color, background: Color)?, shape: GlassShape, asyncStyle: AsyncButtonStyle = .default)
    case nativeTinted((foreground: Color, background: Color)?, shape: GlassShape, asyncStyle: AsyncButtonStyle = .default)
    public static func tintedAccent(tintEnabled: Bool = true, shape: GlassShape, asyncStyle: AsyncButtonStyle = .default) -> Self {
        .tinted(
            tintEnabled ? (foreground: .white, background: .accentColor) : nil,
            shape: shape,
            asyncStyle: asyncStyle
        )
    }
    public static func nativeTintedAccent(tintEnabled: Bool = true, shape: GlassShape, asyncStyle: AsyncButtonStyle = .default) -> Self {
        .nativeTinted(
            tintEnabled ? (foreground: .white, background: .accentColor) : nil,
            shape: shape,
            asyncStyle: asyncStyle
        )
    }
    var color: (foreground: Color, background: Color)? {
        switch self {
        case .regular, .native:
            nil
        case .tinted(let color, _, _), .nativeTinted(let color, _, _):
            color
        }
    }
    var shape: GlassShape {
        switch self {
        case .regular(let shape, _),
                .native(let shape, _),
                .tinted(_, let shape, _),
                .nativeTinted(_, let shape, _):
            shape
        }
    }
    var asyncStyle: AsyncButtonStyle {
        switch self {
        case .regular(_, let asyncStyle),
                .native(_, let asyncStyle),
                .tinted(_, _, let asyncStyle),
                .nativeTinted(_, _, let asyncStyle):
            asyncStyle
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

public struct GlassButton<Label: View>: View {
    
    let role: ButtonRole?
    var style: GlassButtonStyleType
    var hitPadding: CGFloat = 0.0
    let action: () async -> Void
    let label: () -> Label
    
    public init(
        role: ButtonRole? = nil,
        action: @escaping () async -> Void,
        @ViewBuilder label: @escaping () -> Label,
    ) {
        self.role = role
        self.style = .regular(shape: .capsule, asyncStyle: .default)
        self.action = action
        self.label = label
    }
    
    public var body: some View {
#if !os(visionOS)
        if #available(iOS 26.0, macOS 26.0, *) {
            glassButton
        } else {
            frostButton
        }
#else
        frostButton
#endif
    }
    
#if !os(visionOS)
    
    @available(iOS 26.0, macOS 26.0, *)
    @ViewBuilder
    private var glassButton: some View {
        if style.isNative {
            nativeGlassButton
        } else {
            customGlassButton
        }
    }
    
    @available(iOS 26.0, macOS 26.0, *)
    private var nativeGlassButton: some View {
        Group {
            if let (_, backgroundColor) = style.color {
#if os(macOS)
                nativeGlassAsyncButton
                    .buttonStyle(.glassProminent)
                    .tint(backgroundColor)
#else
                nativeGlassAsyncButton
                    .buttonStyle(.glass(.regular.tint(backgroundColor)))
#endif
            } else {
                nativeGlassAsyncButton
                    .buttonStyle(.glass(.regular))
            }
        }
    }
    
    private var nativeGlassAsyncButton: some View {
        AsyncButton(role: role) {
            await action()
        } label: {
            if let (foregroundColor, _) = style.color {
                label()
                    .foregroundStyle(foregroundColor)
            } else {
                label()
                    .foregroundStyle(.primary)
            }
        }
        .asyncButtonStyle(style.asyncStyle)
        .buttonBorderShape(style.shape.buttonBorder)
#if !os(macOS)
        .hoverEffect()
#endif
    }
    
    @available(iOS 26.0, macOS 26.0, *)
    private var customGlassButton: some View {
        AsyncButton(role: role) {
            await action()
        } label: {
            Group {
                if let (foregroundColor, backgroundColor) = style.color {
                    label()
                        .foregroundStyle(foregroundColor)
                        .glassEffect(.regular.interactive().tint(backgroundColor), in: style.shape.any)
                } else {
                    label()
                        .foregroundStyle(.primary)
                        .glassEffect(.regular.interactive(), in: style.shape.any)
                }
            }
            .padding(hitPadding)
            .contentShape(style.shape.any)
        }
        .asyncButtonStyle(style.asyncStyle)
        .buttonStyle(.plain)
        .padding(-hitPadding)
        .buttonBorderShape(style.shape.buttonBorder)
    }
    
#endif
    
    private var frostButton: some View {
        AsyncButton(role: role) {
            await action()
        } label: {
            Group {
                if let foregroundColor: Color = style.color?.foreground {
                    label()
                        .foregroundStyle(foregroundColor)
                } else {
                    label()
                }
            }
            .padding(style.isNative ? (visionOS ? 8 : 6) : 0)
            .background {
                if let tint: Color = style.color?.background {
                    style.shape.any
                        .foregroundStyle(tint)
                } else {
                    style.shape.any
                        .fill(.ultraThinMaterial)
                }
            }
            .overlay {
                style.shape.any
                    .stroke()
                    .foregroundStyle(style.color?.foreground ?? .primary)
                    .opacity(0.25)
            }
            .padding(hitPadding)
            .contentShape(style.shape.any)
        }
        .asyncButtonStyle(style.asyncStyle)
        .buttonStyle(.plain)
        .padding(-hitPadding)
    }
}

extension GlassButton {
    public func glassButtonStyle(_ style: GlassButtonStyleType) -> GlassButton {
        var glassButton: GlassButton = self
        glassButton.style = style
        return glassButton
    }
}

extension GlassButton {
    public func glassHitPadding(_ padding: CGFloat) -> GlassButton {
        var glassButton: GlassButton = self
        glassButton.hitPadding = padding
        return glassButton
    }
}


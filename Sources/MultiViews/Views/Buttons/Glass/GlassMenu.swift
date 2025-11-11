//
//  GlassMenu.swift
//  MultiViews
//
//  Created by Anton Heestand on 2025-07-15.
//

import SwiftUI
import MultiViews

public enum GlassMenuStyleType {
    case regular(shape: GlassShape)
    case native(shape: GlassShape)
    case tinted((foreground: Color, background: Color)?, shape: GlassShape)
    case nativeTinted((foreground: Color, background: Color)?, shape: GlassShape)
    public static func tintedAccent(tintEnabled: Bool = true, shape: GlassShape) -> Self {
        .tinted(
            tintEnabled ? (foreground: .white, background: .accentColor) : nil,
            shape: shape
        )
    }
    public static func nativeTintedAccent(tintEnabled: Bool = true, shape: GlassShape) -> Self {
        .nativeTinted(
            tintEnabled ? (foreground: .white, background: .accentColor) : nil,
            shape: shape
        )
    }
    var color: (foreground: Color, background: Color)? {
        switch self {
        case .regular, .native:
            nil
        case .tinted(let color, _), .nativeTinted(let color, _):
            color
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

public struct GlassMenu<Content: View, Label: View>: View {
    
    var style: GlassMenuStyleType
    var hitPadding: CGFloat = 0.0
    let content: () -> Content
    let label: () -> Label
    
    public init(
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder label: @escaping () -> Label,
    ) {
        self.style = .regular(shape: .capsule)
        self.content = content
        self.label = label
    }
    
    public var body: some View {
#if !os(visionOS)
        if #available(iOS 26.0, macOS 26.0, *) {
            glassMenu
        } else {
            frostMenu
        }
#else
        frostMenu
#endif
    }

#if !os(visionOS)
    
    @available(iOS 26.0, macOS 26.0, *)
    @ViewBuilder
    private var glassMenu: some View {
        if style.isNative {
            nativeGlassMenu
        } else {
            customGlassMenu
        }
    }
    
    @available(iOS 26.0, macOS 26.0, *)
    private var nativeGlassMenu: some View {
        Group {
            if let (_, backgroundColor) = style.color {
                nativeGlassAsyncMenu
                    .buttonStyle(.glass(.regular.tint(backgroundColor)))
            } else {
                nativeGlassAsyncMenu
                    .buttonStyle(.glass(.regular))
            }
        }
    }
    
    private var nativeGlassAsyncMenu: some View {
        Menu {
            content()
        } label: {
            if let (foregroundColor, _) = style.color {
                label()
                    .foregroundStyle(foregroundColor)
            } else {
                label()
                    .foregroundStyle(.primary)
            }
        }
        .menuStyle(.button)
        .buttonBorderShape(style.shape.buttonBorder)
#if !os(macOS)
        .hoverEffect()
#endif
    }
    
    
    @available(iOS 26.0, macOS 26.0, *)
    private var customGlassMenu: some View {
        Menu {
            content()
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
        .menuStyle(.button)
        .buttonStyle(.plain)
        .buttonBorderShape(style.shape.buttonBorder)
        .padding(-hitPadding)
    }
    
#endif
    
    private var frostMenu: some View {
        Menu {
            content()
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
        .menuStyle(.button)
        .buttonStyle(.plain)
        .padding(-hitPadding)
    }
}

extension GlassMenu {
    public func glassMenuStyle(_ style: GlassMenuStyleType) -> GlassMenu {
        var glassMenu: GlassMenu = self
        glassMenu.style = style
        return glassMenu
    }
}

extension GlassMenu {
    public func glassHitPadding(_ padding: CGFloat) -> GlassMenu {
        var glassMenu: GlassMenu = self
        glassMenu.hitPadding = padding
        return glassMenu
    }
}

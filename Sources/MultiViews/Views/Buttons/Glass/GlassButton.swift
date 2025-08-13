//
//  GlassButton.swift
//  MultiViews
//
//  Created by Anton Heestand on 2025-07-15.
//

import SwiftUI
import MultiViews

public enum GlassButtonStyleType {
    case regular(shape: any Shape, asyncStyle: AsyncButtonStyle = .default)
    case tinted((foreground: Color, background: Color)?, shape: any Shape, asyncStyle: AsyncButtonStyle = .default)
    public static func tintedAccent(tintEnabled: Bool = true, shape: any Shape, asyncStyle: AsyncButtonStyle = .default) -> Self {
        .tinted(
            tintEnabled ? (foreground: .white, background: .accentColor) : nil,
            shape: shape,
            asyncStyle: asyncStyle
        )
    }
    var color: (foreground: Color, background: Color)? {
        switch self {
        case .regular:
            nil
        case .tinted(let color, _, _):
            color
        }
    }
    var shape: some Shape {
        switch self {
        case .regular(let shape, _), .tinted(_, let shape, _):
            AnyShape(shape)
        }
    }
    var asyncStyle: AsyncButtonStyle {
        switch self {
        case .regular(_, let asyncStyle), .tinted(_, _, let asyncStyle):
            asyncStyle
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
    private var glassButton: some View {
        AsyncButton(role: role) {
            await action()
        } label: {
            Group {
                if let (foregroundColor, backgroundColor) = style.color {
                    label()
                        .foregroundStyle(foregroundColor)
                        .glassEffect(.regular.interactive().tint(backgroundColor), in: style.shape)
                } else {
                    label()
                        .foregroundStyle(.primary)
                        .glassEffect(.regular.interactive(), in: style.shape)
                }
            }
            .padding(hitPadding)
            .contentShape(style.shape)
        }
        .asyncButtonStyle(style.asyncStyle)
        .buttonStyle(.plain)
        .padding(-hitPadding)
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
            .background {
                if let tint: Color = style.color?.background {
                    style.shape
                        .foregroundStyle(tint)
                } else {
                    style.shape
                        .fill(.ultraThinMaterial)
                }
            }
            .overlay {
                style.shape
                    .stroke()
                    .foregroundStyle(style.color?.foreground ?? .primary)
                    .opacity(0.25)
            }
            .padding(hitPadding)
            .contentShape(style.shape)
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


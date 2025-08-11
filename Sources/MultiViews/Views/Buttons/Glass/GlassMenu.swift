//
//  GlassMenu.swift
//  MultiViews
//
//  Created by Anton Heestand on 2025-07-15.
//

import SwiftUI
import MultiViews

public enum GlassMenuStyleType {
    case regular(shape: any Shape)
    case tinted((foreground: Color, background: Color)?, shape: any Shape)
    public static func tintedAccent(tintEnabled: Bool = true, shape: any Shape) -> Self {
        .tinted(
            tintEnabled ? (foreground: .white, background: .accentColor) : nil,
            shape: shape
        )
    }
    var color: (foreground: Color, background: Color)? {
        switch self {
        case .regular:
            nil
        case .tinted(let color, _):
            color
        }
    }
    var shape: some Shape {
        switch self {
        case .regular(let shape), .tinted(_, let shape):
            AnyShape(shape)
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
        if #available(iOS 26.0, macOS 26.0, visionOS 26.0, *) {
            Menu {
                content()
            } label: {
                Group {
                    if let (foregroundColor, backgroundColor) = style.color {
                        label()
                            .foregroundStyle(foregroundColor)
                            .glassEffect(.regular.interactive().tint(backgroundColor), in: style.shape)
                    } else {
                        label()
                            .glassEffect(.regular.interactive(), in: style.shape)
                    }
                }
                .padding(hitPadding)
                .contentShape(style.shape)
            }
            .menuStyle(.button)
            .buttonStyle(.plain)
            .padding(-hitPadding)
        } else {
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
            .menuStyle(.button)
            .buttonStyle(.plain)
            .padding(-hitPadding)
        }
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

//
//  GlassShape.swift
//  MultiViews
//
//  Created by Anton Heestand on 2025-11-10.
//

import SwiftUI

public enum GlassShape: Sendable {
    case circle
    case capsule
    case rect(cornerRadius: CGFloat)
}

extension GlassShape {
    var any: AnyShape {
        switch self {
        case .circle:
            AnyShape(.circle)
        case .capsule:
            AnyShape(.capsule)
        case .rect(let cornerRadius):
            AnyShape(.rect(cornerRadius: cornerRadius))
        }
    }
}

extension GlassShape {
    var buttonBorder: ButtonBorderShape {
        switch self {
        case .circle:
            .circle
        case .capsule:
            .capsule
        case .rect(let cornerRadius):
            .roundedRectangle(radius: cornerRadius)
        }
    }
}

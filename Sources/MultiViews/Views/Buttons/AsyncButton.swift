//
//  AsyncButton.swift
//  Flow Nodes
//
//  Created by Anton Heestand on 2025-01-20.
//

import SwiftUI

public enum AsyncButtonStyle {
    case plain
    case pulse
    case spinner
    public static let `default`: AsyncButtonStyle = .plain
}

public struct AsyncButton<Label: View>: View {
    
    let role: ButtonRole?
    var style: AsyncButtonStyle
    let action: () async -> Void
    let label: () -> Label
    
    public init(
        role: ButtonRole? = nil,
        action: @escaping () async -> Void,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.role = role
        self.style = .default
        self.action = action
        self.label = label
    }
    
    @State private var isRunning: Bool = false
    @State private var runDate: Date = .now
    
    public var body: some View {
        Button(role: role) {
            runDate = .now
            isRunning = true
            Task {
                await action()
                isRunning = false
            }
        } label: {
            if isRunning {
                switch style {
                case .plain:
                    label()
                case .pulse:
                    TimelineView(.animation) { context in
                        let time: TimeInterval = runDate.distance(to: context.date)
                        let fraction: CGFloat = cos(time * .pi * 2.0) / 2.0 + 0.5
                        label()
                            .opacity(0.5 + fraction / 2.0)
                    }
                case .spinner:
                    HStack {
                        SmallProgressView()
                        label()
                    }
                    .animation(.default, value: isRunning)
                }
            } else {
                label()
            }
        }
        .disabled(isRunning)
    }
}

extension AsyncButton {
    public func asyncButtonStyle(_ style: AsyncButtonStyle) -> AsyncButton {
        var asyncButton: AsyncButton = self
        asyncButton.style = style
        return asyncButton
    }
}

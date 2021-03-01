//
//  Created by Anton Heestand on 2021-01-25.
//

#if os(macOS)
import AppKit
#else
import UIKit
#endif
import SwiftUI

public protocol ViewRepresentable: MPViewRepresentable {
    associatedtype V: MPView
    func makeView(context: Self.Context) -> V
    func updateView(_ view: V, context: Self.Context)
}

#if os(macOS)
extension ViewRepresentable {
    public func makeNSView(context: Self.Context) -> V {
        makeView(context: context)
    }
    public func updateNSView(_ nsView: V, context: Self.Context) {
        updateView(nsView, context: context)
    }
}
#else
extension ViewRepresentable {
    public func makeUIView(context: Self.Context) -> V {
        makeView(context: context)
    }
    public func updateUIView(_ uiView: V, context: Self.Context) {
        updateView(uiView, context: context)
    }
}
#endif

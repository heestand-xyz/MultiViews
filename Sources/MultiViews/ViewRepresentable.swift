//
//  Created by Anton Heestand on 2021-01-25.
//

#if os(macOS)
import AppKit
#else
import UIKit
#endif
import SwiftUI

protocol ViewRepresentable: MPViewRepresentable {
    func makeView(context: Self.Context) -> MPView
    func updateView(_ view: MPView, context: Self.Context)
}

#if os(macOS)
extension ViewRepresentable {
    func makeNSView(context: Self.Context) -> NSView {
        makeView(context: context)
    }
    func updateNSView(_ nsView: NSView, context: Self.Context) {
        updateView(nsView, context: context)
    }
}
#else
extension ViewRepresentable {
    func makeUIView(context: Self.Context) -> UIView {
        makeView(context: context)
    }
    func updateUIView(_ uiView: UIView, context: Self.Context) {
        updateView(uiView, context: context)
    }
}
#endif

#if os(macOS)
import AppKit
#else
import UIKit
#endif
import SwiftUI

@MainActor
public protocol ViewControllerRepresentable: MPViewControllerRepresentable {
    associatedtype VC: MPViewController
    func makeViewController(context: Self.Context) -> VC
    func updateViewController(_ viewController: VC, context: Self.Context)
}

#if os(macOS)
extension ViewControllerRepresentable {
    public func makeNSViewController(context: Self.Context) -> VC {
        makeViewController(context: context)
    }
    public func updateNSViewController(_ nsViewController: VC, context: Self.Context) {
        updateViewController(nsViewController, context: context)
    }
}
#else
extension ViewControllerRepresentable {
    public func makeUIViewController(context: Self.Context) -> VC {
        makeViewController(context: context)
    }
    public func updateUIViewController(_ uiViewController: VC, context: Self.Context) {
        updateViewController(uiViewController, context: context)
    }
}
#endif

#if os(macOS)
import AppKit
#else
import UIKit
#endif
import SwiftUI

#if os(macOS)
public typealias MPViewController = NSViewController
public typealias MPHostingView = NSHostingView
public typealias MPHostingController = NSHostingController
public typealias MPViewRepresentable = NSViewRepresentable
#else
public typealias MPViewController = UIViewController
public typealias MPHostingView = UIHostingController
public typealias MPHostingController = UIHostingController
public typealias MPViewRepresentable = UIViewRepresentable
#endif

#if os(macOS)
public extension MPHostingView {
    var view: MPView { self }
}
#endif

#if os(macOS)
import AppKit
#else
import UIKit
#endif
import SwiftUI

#if os(macOS)
public typealias MPViewController = NSViewController
public typealias MPHostingController = NSHostingController
public typealias MPViewRepresentable = NSViewRepresentable
public typealias MPViewControllerRepresentable = NSViewControllerRepresentable
#else
public typealias MPViewController = UIViewController
public typealias MPHostingController = UIHostingController
public typealias MPViewRepresentable = UIViewRepresentable
public typealias MPViewControllerRepresentable = UIViewControllerRepresentable
#endif

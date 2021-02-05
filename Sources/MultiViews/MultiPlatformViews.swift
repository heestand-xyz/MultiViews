//
//  MultiPlatform.swift
//  Jockey
//
//  Created by Anton Heestand on 2020-12-06.
//

#if os(macOS)
import AppKit
#else
import UIKit
#endif
import SwiftUI

#if os(macOS)
typealias MPView = NSView
#else
typealias MPView = UIView
#endif

#if os(macOS)
typealias MPViewController = NSViewController
typealias MPHostingView = NSHostingView
typealias MPViewRepresentable = NSViewRepresentable
#else
typealias MPViewController = UIViewController
typealias MPHostingView = UIHostingController
typealias MPViewRepresentable = UIViewRepresentable
#endif

#if os(macOS)
extension MPHostingView {
    var view: MPView { self }
}
#endif

//
//  File.swift
//  File
//
//  Created by Anton Heestand on 2021-08-31.
//

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

#if os(macOS)
public typealias ApplicationDelegate = NSApplicationDelegate
#else
public typealias ApplicationDelegate = UIApplicationDelegate
#endif

//
//  File.swift
//  File
//
//  Created by Anton Heestand on 2021-08-31.
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

#if os(iOS)
public typealias ApplicationDelegate = UIApplicationDelegate
#elseif os(macOS)
public typealias ApplicationDelegate = NSApplicationDelegate
#endif

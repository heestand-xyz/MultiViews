//
//  File.swift
//  File
//
//  Created by Anton Heestand on 2021-08-15.
//

#if os(macOS)
import AppKit
#else
import UIKit
#endif

#if os(macOS)
public typealias MPColor = NSColor
#else
public typealias MPColor = UIColor
#endif

//
//  File.swift
//  File
//
//  Created by Anton Heestand on 2021-08-15.
//

#if os(macOS)
import AppKit
#endif

#if os(macOS)
extension MPView {
    func image() -> NSImage {
        let imageRepresentation = bitmapImageRepForCachingDisplay(in: bounds)!
        cacheDisplay(in: bounds, to: imageRepresentation)
        return NSImage(cgImage: imageRepresentation.cgImage!, size: bounds.size)
    }
}
#endif

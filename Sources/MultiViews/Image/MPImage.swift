//
//  File.swift
//  
//
//  Created by Anton Heestand on 2021-02-23.
//

import Foundation
import SwiftUI

#if os(macOS)
public typealias MPImage = NSImage
public typealias MPImageView = NSImageView
public extension Image {
    init(image: NSImage) {
        self.init(nsImage: image)
    }
}
#else
public typealias MPImage = UIImage
public typealias MPImageView = UIImageView
public extension Image {
    init(image: UIImage) {
        self.init(uiImage: image)
    }
}
#endif

#if os(macOS)
public extension MPImage {
    func pngData() -> Data? {
        guard let representation = tiffRepresentation else { return nil }
        guard let bitmap = NSBitmapImageRep(data: representation) else { return nil }
        return bitmap.representation(using: .png, properties: [:])
    }
    func jpegData(compressionQuality: CGFloat) -> Data? {
        guard let representation = tiffRepresentation else { return nil }
        guard let bitmap = NSBitmapImageRep(data: representation) else { return nil }
        return bitmap.representation(using: .jpeg, properties: [.compressionFactor: compressionQuality])
    }
}
#endif

#if os(macOS)
public extension NSImage {
    var scale: CGFloat {
        guard let pixelsWide: Int = representations.first?.pixelsWide else { return 1.0 }
        let scale: CGFloat = CGFloat(pixelsWide) / size.width
        return scale
    }
}
#endif

#if os(macOS)
public extension NSImage {
    var cgImage: CGImage? {
        var frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        return cgImage(forProposedRect: &frame, context: nil, hints: nil)
    }
}
#endif

#if os(iOS)
public extension UIImage {
    convenience init(cgImage: CGImage, size: CGSize) {
        self.init(cgImage: cgImage)
    }
}
#endif

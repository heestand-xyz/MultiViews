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

////
////  Created by Anton Heestand on 2021-02-10.
////
//
//import SwiftUI
//
//public struct ReView<Content: View>: View {
//
//    let image: MPImage?
//
//    public init(content: @escaping () -> (Content)) {
//
//        let view: MPView = MPHostingView(rootView: content()).view
//        let size: CGSize = view.bounds.size
//        let bounds = CGRect(origin: .zero, size: size)
//
//        #if os(macOS)
//
//        self.image = view.image()
//
//        #else
//
//        view.isOpaque = false
//        view.backgroundColor = .clear
//
//        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
//        view.drawHierarchy(in: bounds, afterScreenUpdates: true)
//        self.image = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//
//        #endif
//
//    }
//
//    public var body: some View {
//        Image(image: image ?? UIImage())
//    }
//
//}
//
//#if os(macOS)
//extension NSView {
//
//    func image() -> NSImage {
//        let imageRepresentation = bitmapImageRepForCachingDisplay(in: bounds)!
//        cacheDisplay(in: bounds, to: imageRepresentation)
//        return NSImage(cgImage: imageRepresentation.cgImage!, size: bounds.size)
//    }
//
//}
//#endif

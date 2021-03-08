#if os(macOS)
import AppKit
#else
import UIKit
#endif

#if os(macOS)
public extension NSView {

    func image() -> NSImage? {
        
        guard let bitmap: NSBitmapImageRep = bitmapImageRepForCachingDisplay(in: bounds) else { return nil }
        
        cacheDisplay(in: bounds, to: bitmap)
        
        guard let cgImage: CGImage = bitmap.cgImage else { return nil }
        let image: NSImage = NSImage(cgImage: cgImage, size: bounds.size)
        
        return image
    }
}
#else
public extension UIView {
    
    func image(transparent: Bool = true) -> UIImage? {
        
        if transparent {
            isOpaque = false
            backgroundColor = .clear
        }

        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        guard let image: UIImage = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        
        return image
    }
}
#endif

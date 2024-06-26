//
//  Created by Anton Heestand on 2022-10-04.
//

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif

public struct Checker: ViewRepresentable {
    
    let scale: CGFloat
    
    public init(scale: CGFloat = 20) {
        self.scale = scale
    }
    
    public func makeView(context: Context) -> CheckerView {
        CheckerView(frame: .zero, scale: scale)
    }
    
    public func updateView(_ view: CheckerView, context: Context) {
        view.scale = scale
    }
}

public class CheckerView: MPView {
    
    public override var frame: CGRect {
        didSet {
            render()
        }
    }
    
    var scale: CGFloat {
        didSet {
            guard oldValue != scale else { return }
            render()
        }
    }
    
    init(frame: CGRect, scale: CGFloat) {
    
        self.scale = scale
        
        super.init(frame: frame)
        
#if os(iOS) || os(tvOS) || os(visionOS)
        isUserInteractionEnabled = false
#endif
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func render() {
#if os(iOS) || os(tvOS) || os(visionOS)
            setNeedsDisplay()
#elseif os(macOS)
            setNeedsDisplay(frame)
#endif
    }
    
    private func checkerImage() -> MPImage {
        let dark: CGFloat = 1 / 3
        let light: CGFloat = 2 / 3
#if os(iOS) || os(tvOS) || os(visionOS)
        let darkColor = UIColor(white: dark, alpha: 1.0).cgColor
        let lightColor = UIColor(white: light, alpha: 1.0).cgColor
        return UIGraphicsImageRenderer(size: CGSize(width: scale * 2, height: scale * 2)).image { ctx in
            ctx.cgContext.setFillColor(darkColor)
            ctx.cgContext.addRect(CGRect(x: 0, y: 0, width: scale, height: scale))
            ctx.cgContext.addRect(CGRect(x: scale, y: scale, width: scale, height: scale))
            ctx.cgContext.drawPath(using: .fill)
            ctx.cgContext.setFillColor(lightColor)
            ctx.cgContext.addRect(CGRect(x: 0, y: scale, width: scale, height: scale))
            ctx.cgContext.addRect(CGRect(x: scale, y: 0, width: scale, height: scale))
            ctx.cgContext.drawPath(using: .fill)
        }
#elseif os(macOS)
        let darkColor = CGColor(gray: dark, alpha: 1.0)
        let lightColor = CGColor(gray: light, alpha: 1.0)
        let img = NSImage(size: CGSize(width: scale * 2, height: scale * 2))
        img.lockFocus()
        let ctx = NSGraphicsContext.current!.cgContext
        ctx.setFillColor(darkColor)
        ctx.fill(CGRect(x: 0, y: 0, width: scale, height: scale))
        ctx.fill(CGRect(x: scale, y: scale, width: scale, height: scale))
        ctx.setFillColor(lightColor)
        ctx.fill(CGRect(x: 0, y: scale, width: scale, height: scale))
        ctx.fill(CGRect(x: scale, y: 0, width: scale, height: scale))
        img.unlockFocus()
        return img
#endif
    }
    
    public override func draw(_ rect: CGRect) {
        
#if os(macOS)
        guard let context = NSGraphicsContext.current?.cgContext else { return }
#else
        guard let context = UIGraphicsGetCurrentContext() else { return }
#endif
        
        context.saveGState();
        
        let phase = CGSize(width: rect.width / 2, height: rect.height / 2)
        context.setPatternPhase(phase)
        
        let checker = checkerImage()
        
#if os(macOS)
        let color = NSColor(patternImage: checker).cgColor
#else
        let color = UIColor(patternImage: checker).cgColor
#endif
        context.setFillColor(color)
        
        context.fill(CGRect(x: 0, y: 0, width: rect.width, height: rect.height))
        
        context.restoreGState()
        
        super.draw(rect)
        
    }
}

import SwiftUI
import CoreGraphicsExtensions

extension View {
    
    public func hover(offset: Binding<CGPoint?>,
                      zOffset: Binding<CGFloat?> = .constant(nil)) -> some View {
        background(HoverViewRepresentable(offset: offset, zOffset: zOffset))
    }
}


struct HoverViewRepresentable: ViewRepresentable {
    
    @Binding var offset: CGPoint?
    @Binding var zOffset: CGFloat?
    
    func makeView(context: Context) -> HoverView {
        HoverView(offset: $offset,
                  zOffset: $zOffset)
    }
    
    func updateView(_ view: HoverView, context: Context) {}
}

class HoverView: MPView {
    
    private var hovering: Bool = false
    @Binding var offset: CGPoint?
    @Binding var zOffset: CGFloat?
    
    #if os(macOS)
    var trackingArea : NSTrackingArea?
    #endif
    
    init(offset: Binding<CGPoint?>,
         zOffset: Binding<CGFloat?>) {
        _offset = offset
        _zOffset = zOffset
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        #if !os(macOS)
        let hoverGestureRecognizer = UIHoverGestureRecognizer(target: self, action: #selector(didHover))
        addGestureRecognizer(hoverGestureRecognizer)
        #endif
    }
    
    #if os(macOS)
    
    override func updateTrackingAreas() {
        if let trackingArea {
            self.removeTrackingArea(trackingArea)
        }
        let options: NSTrackingArea.Options = [
            .mouseEnteredAndExited,
            .mouseMoved,
            .activeInKeyWindow
        ]
        trackingArea = NSTrackingArea(
            rect: bounds,
            options: options,
            owner: self,
            userInfo: nil
        )
        addTrackingArea(trackingArea!)
    }
    
    override func mouseEntered(with event: NSEvent) {
        hovering = true
    }
    
    override func mouseMoved(with event: NSEvent) {
        guard hovering,
              let location = getMouseLocation()
        else { return }
        offset = location
    }
    
    override func mouseExited(with event: NSEvent) {
        hovering = false
        offset = nil
    }
    
    private func getMouseLocation() -> CGPoint? {
        guard let window: NSWindow = window else { return nil }
        let mouseLocation: CGPoint = window.mouseLocationOutsideOfEventStream
        guard let windowView: NSView = window.contentView else { return nil }
        var point: CGPoint = convert(.zero, to: windowView)
        if point.y == 0.0 { point = convert(CGPoint(x: 0.0, y: windowView.bounds.height), to: windowView) }
        let origin: CGPoint = CGPoint(x: point.x, y: windowView.bounds.size.height - point.y)
        let location: CGPoint = mouseLocation - origin
        let finalLocation: CGPoint = CGPoint(x: location.x, y: bounds.size.height - location.y)
        return finalLocation
    }
    
    #else
    
    @objc
    func didHover(_ gesture: UIHoverGestureRecognizer) {
        switch gesture.state {
        case .changed:
            offset = gesture.location(in: self)
            if #available(iOS 16.1, *) {
                zOffset = gesture.zOffset
            }
        default:
            break
        }
    }
    
    #endif
}

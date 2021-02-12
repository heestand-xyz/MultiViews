//
//  JScrollView.swift
//  Jockey
//
//  Created by Anton Heestand on 2021-01-25.
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
import SwiftUI

#if os(iOS)
typealias MPScrollView = UIScrollView
#elseif os(macOS)
typealias MPScrollView = MPNSScrollView
#endif

public struct MVScrollView<Content: View>: ViewRepresentable {
    
    let padding: CGFloat
    let pageWidth: CGFloat
    @Binding var scrollOffset: CGPoint
    
    let content: () -> (Content)
    let host: MPHostingView<Content>

    public init(padding: CGFloat, pageWidth: CGFloat, scrollOffset: Binding<CGPoint>, content: @escaping () -> (Content)) {
        self.padding = padding
        self.pageWidth = pageWidth
        _scrollOffset = scrollOffset
        self.content = content
        host = MPHostingView(rootView: content())
    }
    
    public func makeView(context: Context) -> MPView {
        
        let scrollView: MPScrollView
        #if os(iOS)
        scrollView = UIScrollView()
        #elseif os(macOS)
        scrollView = MPNSScrollView()
        
        #endif
        
        #if os(macOS)
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = true
        scrollView.usesPredominantAxisScrolling = false
        #endif
        
        #if os(iOS)
        scrollView.contentInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        #elseif os(macOS)
        scrollView.automaticallyAdjustsContentInsets = false
        scrollView.contentInsets = NSEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        #endif
        
        let view: MPView = host.view
        #if os(iOS)
        view.backgroundColor = .clear
        scrollView.addSubview(view)
        #elseif os(macOS)
        view.wantsLayer = true
        view.layer!.backgroundColor = .clear
        scrollView.drawsBackground = false
        scrollView.documentView = view
        #endif
        view.translatesAutoresizingMaskIntoConstraints = false
        #if os(iOS)
        view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        view.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        #endif
        
        #if os(iOS)
        scrollView.delegate = context.coordinator
        #endif

        #if os(macOS)
        scrollView.contentView.postsBoundsChangedNotifications = true
        #endif
        
        context.coordinator.scrollView = scrollView
        context.coordinator.setup()
        
        return scrollView
        
    }
    
    public func updateView(_ view: MPView, context: Context) {
//        let scrollView: MPScrollView = view as! MPScrollView
    }
    
    public func makeCoordinator() -> MPScrollViewCoordinator {
        MPScrollViewCoordinator(padding: padding, pageWidth: pageWidth, scrollOffset: $scrollOffset)
    }
    
}

public class MPScrollViewCoordinator: NSObject {
    
    let padding: CGFloat
    
    var scrollView: MPScrollView!
    
    let pageWidth: CGFloat
    @Binding var scrollOffset: CGPoint

    init(padding: CGFloat, pageWidth: CGFloat, scrollOffset: Binding<CGPoint>) {
        self.padding = padding
        self.pageWidth = pageWidth
        _scrollOffset = scrollOffset
        super.init()
    }
    
}

#if os(iOS)
extension MPScrollViewCoordinator: UIScrollViewDelegate {
    
    func setup() {}
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollOffset = scrollView.contentOffset
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        var x: CGFloat = targetContentOffset.pointee.x
        var y: CGFloat = targetContentOffset.pointee.y
        let isAtRight: Bool = 0.0 == scrollView.contentSize.width - scrollView.bounds.width - x + padding
        if !isAtRight {
            let relX: CGFloat = (x + padding) / pageWidth
            x = round(relX) * pageWidth - padding
        }
        let isAtBottom: Bool = 0.0 == scrollView.contentSize.height - scrollView.bounds.height - y + padding + scrollView.safeAreaInsets.bottom
        if !isAtBottom {
            let relY: CGFloat = (y + padding) / pageWidth
            y = round(relY) * pageWidth - padding
        }
        targetContentOffset.pointee = CGPoint(x: x, y: y)
    }
    
}
#elseif os(macOS)
extension MPScrollViewCoordinator {
    
    func setup() {
        NotificationCenter.default.addObserver(self, selector: #selector(boundsChange),
                                               name: NSView.boundsDidChangeNotification,
                                               object: scrollView.contentView)
    }
    
    @objc func boundsChange() {
        scrollOffset = scrollView.contentView.bounds.origin
    }
    
}
#endif

#if os(macOS)
class MPNSScrollView: NSScrollView {
    
//    override func scrollWheel(with event: NSEvent) {
//        dump(event)
//    }
    
//    override func hitTest(_ point: NSPoint) -> NSView? {
//        for subView in subviews {
//            if let view: NSView = subView.hitTest(point) {
//                return view
//            }
//        }
//        return nil
//    }
    
}
#endif

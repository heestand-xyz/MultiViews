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

#if os(iOS)
public typealias MPEdgeInsets = UIEdgeInsets
#elseif os(macOS)
public typealias MPEdgeInsets = NSEdgeInsets
#endif

public struct MVScrollView<Content: View>: ViewRepresentable {
    
    let padding: MPEdgeInsets
    let pageWidth: CGFloat
    @Binding var scrollOffset: CGPoint
    @Binding var scrollContainerSize: CGSize
    @Binding var scrollContentSize: CGSize

    let content: () -> (Content)

    public init(padding: MPEdgeInsets,
                pageWidth: CGFloat,
                scrollOffset: Binding<CGPoint>,
                scrollContainerSize: Binding<CGSize>,
                scrollContentSize: Binding<CGSize>,
                content: @escaping () -> (Content)) {
        self.padding = padding
        self.pageWidth = pageWidth
        _scrollOffset = scrollOffset
        _scrollContainerSize = scrollContainerSize
        _scrollContentSize = scrollContentSize
        self.content = content
    }
    
    public func makeView(context: Context) -> MPView {
        
        let host = MPHostingView(rootView: content())
        
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
        scrollView.contentInset = padding
        #elseif os(macOS)
        scrollView.automaticallyAdjustsContentInsets = false
        scrollView.contentInsets = padding
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
        #if os(iOS)
        view.translatesAutoresizingMaskIntoConstraints = false
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
        
        print("<<< Scroll View Update >>>")
        
        let scrollView: MPScrollView = view as! MPScrollView
        
        let couldNotScroll: Bool = scrollView.contentSize.width < scrollContainerSize.width && scrollView.contentSize.height < scrollContainerSize.height
        let canNotScroll: Bool = scrollContentSize.width < scrollContainerSize.width && scrollContentSize.height < scrollContainerSize.height
        func roundSize(_ size: CGSize) -> CGSize {
            CGSize(width: round(size.width), height: round(size.height))
        }
        let sizeIsNew: Bool = roundSize(scrollView.contentSize) != roundSize(scrollContentSize)
        #if os(iOS)
        let offsetIsNew: Bool = scrollView.contentOffset != scrollOffset
        if offsetIsNew {
            scrollView.setContentOffset(scrollOffset, animated: false)
        }
        if sizeIsNew {
            scrollView.contentSize = scrollContentSize
        }
        if !couldNotScroll && canNotScroll {
            RunLoop.current.add(Timer(timeInterval: 0.1, repeats: false, block: { _ in
                scrollView.setContentOffset(CGPoint(x: -padding.left, y: -padding.top), animated: true)
            }), forMode: .common)
        }
        #elseif os(macOS)
        let offsetIsNew: Bool = scrollView.contentView.bounds.origin != scrollOffset
        if offsetIsNew {
            scrollView.contentView.setBoundsOrigin(scrollOffset)
        }
        if sizeIsNew {
            scrollView.documentView?.setFrameSize(scrollContentSize)
        }
        if !couldNotScroll && canNotScroll {
            scrollView.contentView.setBoundsOrigin(.zero)
        }
        #endif
        
        context.coordinator.padding = padding
        #if os(iOS)
        scrollView.contentInset = padding
        #elseif os(macOS)
        scrollView.contentInsets = padding
        #endif
        
    }
    
    public func makeCoordinator() -> MPScrollViewCoordinator {
        MPScrollViewCoordinator(padding: padding, pageWidth: pageWidth, scrollOffset: $scrollOffset)
    }
    
}

public class MPScrollViewCoordinator: NSObject {
    
    var padding: MPEdgeInsets
    
    var scrollView: MPScrollView!
    
    let pageWidth: CGFloat
    @Binding var scrollOffset: CGPoint

    init(padding: MPEdgeInsets, pageWidth: CGFloat, scrollOffset: Binding<CGPoint>) {
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
        let isAtRight: Bool = 0.0 == scrollView.contentSize.width - scrollView.bounds.width - x + padding.right
        if !isAtRight {
            let relX: CGFloat = (x + padding.left) / pageWidth
            x = round(relX) * pageWidth - padding.left
        }
        let isAtBottom: Bool = 0.0 == scrollView.contentSize.height - scrollView.bounds.height - y + padding.bottom + scrollView.safeAreaInsets.bottom
        if !isAtBottom {
            let relY: CGFloat = (y + padding.top) / pageWidth
            y = round(relY) * pageWidth - padding.top
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
        DispatchQueue.main.async {
            self.scrollOffset = self.scrollView.contentView.bounds.origin
        }
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

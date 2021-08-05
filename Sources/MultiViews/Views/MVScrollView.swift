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

#if os(macOS)
public typealias MPScrollView = NSScrollView
#else
public typealias MPScrollView = UIScrollView
#endif

#if os(macOS)
public typealias MPEdgeInsets = NSEdgeInsets
#else
public typealias MPEdgeInsets = UIEdgeInsets
#endif

public struct MVScrollView<Content: View>: ViewRepresentable {
    
    public enum Axis {
        case free
        case vertical
        case horizontal
        var isVertical: Bool { self != .horizontal }
        var isHorizontal: Bool { self != .vertical }
    }
    let axis: Axis

    let padding: MPEdgeInsets
    let pageWidth: CGFloat
    
    @Binding var scrollOffset: CGPoint
    @Binding var scrollContainerSize: CGSize
    @Binding var scrollContentSize: CGSize
    @Binding var canScroll: Bool

    let content: () -> (Content)
    
    public init(axis: Axis = .free,
                padding: MPEdgeInsets,
                pageWidth: CGFloat,
                scrollOffset: Binding<CGPoint>,
                scrollContainerSize: Binding<CGSize>,
                scrollContentSize: Binding<CGSize>,
                canScroll: Binding<Bool> = .constant(true),
                content: @escaping () -> (Content)) {
        self.axis = axis
        self.padding = padding
        self.pageWidth = pageWidth
        _scrollOffset = scrollOffset
        _scrollContainerSize = scrollContainerSize
        _scrollContentSize = scrollContentSize
        _canScroll = canScroll
        self.content = content
    }
    
    public func makeView(context: Context) -> MPView {
        
        print("<<< <<< Scroll View Make >>> >>>")
        
        let host = MPHostingView(rootView: content())
        
        let scrollView: MPScrollView
        #if os(macOS)
        scrollView = NSScrollView()
        #else
        scrollView = UIScrollView()
        #endif
        
        #if os(macOS)
        scrollView.hasVerticalScroller = axis.isVertical
        scrollView.hasHorizontalScroller = axis.isHorizontal
        scrollView.verticalScrollElasticity = axis.isVertical ? .automatic : .none
        scrollView.horizontalScrollElasticity = axis.isHorizontal ? .automatic : .none
        scrollView.usesPredominantAxisScrolling = false
        #endif
        
        #if os(macOS)
        scrollView.automaticallyAdjustsContentInsets = false
        scrollView.contentInsets = padding
        #else
        scrollView.contentInset = padding
        #endif
        
        let view: MPView = host.view
        #if os(macOS)
        view.wantsLayer = true
        view.layer!.backgroundColor = .clear
        scrollView.drawsBackground = false
        scrollView.documentView = view
        #else
        view.backgroundColor = .clear
        scrollView.addSubview(view)
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
        
//        print("<<< Scroll View Update >>>")
        
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
        
        if context.coordinator.willScroll != canScroll {
            #if os(iOS)
            scrollView.isScrollEnabled = canScroll
            #elseif os(macOS)
            // Not implemented
            #endif
            context.coordinator.willScroll = canScroll
        }
        
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
    
    var willScroll: Bool?

    init(padding: MPEdgeInsets, pageWidth: CGFloat, scrollOffset: Binding<CGPoint>) {
        self.padding = padding
        self.pageWidth = pageWidth
        _scrollOffset = scrollOffset
        super.init()
    }
    
}

#if os(macOS)
extension MPScrollViewCoordinator {
    
    func setup() {
        NotificationCenter.default.addObserver(self, selector: #selector(boundsChange),
                                               name: NSView.boundsDidChangeNotification,
                                               object: scrollView.contentView)
    }

    @objc func boundsChange() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.scrollOffset = self.scrollView.contentView.bounds.origin
        }
    }
    
}
#else
extension MPScrollViewCoordinator: UIScrollViewDelegate {
    
    func setup() {}
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        DispatchQueue.main.async { [weak self] in
            self?.scrollOffset = scrollView.contentOffset
        }
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
#endif

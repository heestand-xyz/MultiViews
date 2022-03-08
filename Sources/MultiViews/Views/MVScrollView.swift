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
import CoreGraphicsExtensions

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

enum MVScrollDirection {
    case horizontal
    case vertical
}

public struct MVScrollView<Content: View>: ViewRepresentable {
    
    public enum Axis {
        case free
        case first
        case horizontal
        case vertical
        var isHorizontal: Bool { self != .vertical }
        var isVertical: Bool { self != .horizontal }
    }
    let axis: Axis

    let padding: MPEdgeInsets
    let pageWidth: CGFloat?
    let pageHeight: CGFloat?

    @Binding var scrollOffset: CGPoint
    @Binding var scrollContainerSize: CGSize
    @Binding var scrollContentSize: CGSize
    
    let hasIndicators: Bool

    @Binding var canScroll: Bool

    let content: () -> (Content)
    
    public init(axis: Axis = .free,
                padding: MPEdgeInsets = .zero,
                pageWidth: CGFloat? = nil,
                pageHeight: CGFloat? = nil,
                scrollOffset: Binding<CGPoint>,
                scrollContainerSize: Binding<CGSize>,
                scrollContentSize: Binding<CGSize>,
                hasIndicators: Bool = true,
                canScroll: Binding<Bool> = .constant(true),
                content: @escaping () -> (Content)) {
        self.axis = axis
        self.padding = padding
        self.pageWidth = pageWidth
        self.pageHeight = pageHeight
        _scrollOffset = scrollOffset
        _scrollContainerSize = scrollContainerSize
        _scrollContentSize = scrollContentSize
        self.hasIndicators = hasIndicators
        _canScroll = canScroll
        self.content = content
    }
    
    public func makeView(context: Context) -> MPView {
        
//        print("<<< <<< Scroll View Make >>> >>>")
        
        let host = MPHostingController(rootView: content())
        
        let scrollView: MPScrollView
        #if os(macOS)
        scrollView = NSScrollView()
        #else
        scrollView = UIScrollView()
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
        view.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
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
        
        #if os(iOS)
        context.coordinator.didStartScroll = {}
        context.coordinator.didScroll = { scrollOffset in
            if axis == .first {
                if context.coordinator.scrollStartOffset == nil {
                    context.coordinator.scrollStartOffset = scrollOffset
                }
                let scrollStartOffset = context.coordinator.scrollStartOffset!
                let offset: CGPoint = scrollOffset - scrollStartOffset
                guard hypot(offset.x, offset.y) > 0.0 else { return scrollStartOffset }
                if context.coordinator.firstDirection == nil {
                    context.coordinator.firstDirection = abs(offset.x) > abs(offset.y) ? .horizontal : .vertical
                }
                switch context.coordinator.firstDirection! {
                case .horizontal:
                    return scrollStartOffset + CGPoint(x: offset.x, y: 0.0)
                case .vertical:
                    return scrollStartOffset + CGPoint(x: 0.0, y: offset.y)
                }
            }
            return nil
        }
        context.coordinator.didEndScroll = {
            context.coordinator.firstDirection = nil
            context.coordinator.scrollStartOffset = nil
        }
        #endif
        
        context.coordinator.padding = padding
        #if os(iOS)
        scrollView.contentInset = padding
        #elseif os(macOS)
        scrollView.contentInsets = padding
        #endif
        
        return scrollView
        
    }
    
    public func updateView(_ view: MPView, context: Context) {
        
//        print("<<< Scroll View Update >>>")
        
        let scrollView: MPScrollView = view as! MPScrollView
        
        #if os(iOS)
        scrollView.showsHorizontalScrollIndicator = hasIndicators ? axis.isHorizontal : false
        scrollView.showsVerticalScrollIndicator = hasIndicators ? axis.isVertical : false
        scrollView.alwaysBounceHorizontal = axis.isHorizontal
        scrollView.alwaysBounceVertical = axis.isVertical
        #elseif os(macOS)
        scrollView.hasVerticalScroller = axis.isVertical
        scrollView.hasHorizontalScroller = axis.isHorizontal
        scrollView.verticalScrollElasticity = axis.isVertical ? .automatic : .none
        scrollView.horizontalScrollElasticity = axis.isHorizontal ? .automatic : .none
        scrollView.usesPredominantAxisScrolling = false
        #endif
        
        let couldNotScroll: Bool = scrollView.contentSize.width < scrollContainerSize.width && scrollView.contentSize.height < scrollContainerSize.height
        let canNotScroll: Bool = scrollContentSize.width < scrollContainerSize.width && scrollContentSize.height < scrollContainerSize.height
        func roundSize(_ size: CGSize) -> CGSize {
            CGSize(width: round(size.width), height: round(size.height))
        }
        let sizeIsNew: Bool = roundSize(scrollView.contentSize) != roundSize(scrollContentSize)
        #if os(iOS)
        let offsetIsNew: Bool = !compare(scrollView.contentOffset, rhs: scrollOffset)
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
        
        if context.coordinator.willScroll != canScroll {
            #if os(iOS)
//            scrollView.isScrollEnabled = canScroll
            #elseif os(macOS)
            // Not implemented
            #endif
            context.coordinator.willScroll = canScroll
        }
        
    }
    
    public func makeCoordinator() -> MPScrollViewCoordinator {
        MPScrollViewCoordinator(padding: padding, pageWidth: pageWidth, pageHeight: pageHeight, scrollOffset: $scrollOffset)
    }
    
    func compare(_ lhs: CGPoint, rhs: CGPoint) -> Bool {
        let lhs = CGPoint(x: round(lhs.x * 1_000_000) / 1_000_000,
                          y: round(lhs.y * 1_000_000) / 1_000_000)
        let rhs = CGPoint(x: round(rhs.x * 1_000_000) / 1_000_000,
                          y: round(rhs.y * 1_000_000) / 1_000_000)
        return lhs == rhs
    }
}

public class MPScrollViewCoordinator: NSObject {
    
    var padding: MPEdgeInsets
    
    var scrollView: MPScrollView!
    
    let pageWidth: CGFloat?
    let pageHeight: CGFloat?
    @Binding var scrollOffset: CGPoint
    
    var willScroll: Bool?
    var firstDirection: MVScrollDirection?
    
    var isScrolling: Bool = false
    var scrollStartOffset: CGPoint?
    var didStartScroll: (() -> ())?
    var didScroll: ((CGPoint) -> CGPoint?)?
    var didEndScroll: (() -> ())?

    init(padding: MPEdgeInsets,
         pageWidth: CGFloat?,
         pageHeight: CGFloat?,
         scrollOffset: Binding<CGPoint>) {
        self.padding = padding
        self.pageWidth = pageWidth
        self.pageHeight = pageHeight
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
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        didStartScroll?()
        isScrolling = true
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard isScrolling else { return }
        let contentOffset: CGPoint? = didScroll?(scrollView.contentOffset)
        if let contentOffset = contentOffset {
            scrollView.contentOffset = contentOffset
        }
        DispatchQueue.main.async { [weak self] in
            self?.scrollOffset = contentOffset ?? scrollView.contentOffset
        }
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        var x: CGFloat = targetContentOffset.pointee.x
        var y: CGFloat = targetContentOffset.pointee.y
        if let pageWidth: CGFloat = pageWidth {
            let isAtRight: Bool = 0.0 == scrollView.contentSize.width - scrollView.bounds.width - x + padding.right
            if !isAtRight {
                let relX: CGFloat = (x + padding.left) / pageWidth
                x = round(relX) * pageWidth - padding.left
            }
        }
        if let pageHeight: CGFloat = pageHeight {
            let isAtBottom: Bool = 0.0 == scrollView.contentSize.height - scrollView.bounds.height - y + padding.bottom + scrollView.safeAreaInsets.bottom
            if !isAtBottom {
                let relY: CGFloat = (y + padding.top) / pageHeight
                y = round(relY) * pageHeight - padding.top
            }
        }
        targetContentOffset.pointee = CGPoint(x: x, y: y)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollViewDidEndScrolling()
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidEndScrolling()
    }
        
    private func scrollViewDidEndScrolling() {
        isScrolling = false
        didEndScroll?()
    }
    
}
#endif

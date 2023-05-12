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

#if os(macOS)
extension NSEdgeInsets {
    public static let zero = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
}
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
    @Binding var zoomScale: CGFloat
    let containerSize: CGSize
    let contentSize: CGSize
    @Binding var scrollActive: Bool
    @Binding var zoomActive: Bool
    
    let hasIndicators: Bool
    
    let minZoom: CGFloat
    let maxZoom: CGFloat

    @Binding var canScroll: Bool
    let canZoom: Bool
    
    let centering: Bool

    let content: () -> (Content)
    
    public init(axis: Axis = .free,
                padding: MPEdgeInsets = .zero,
                pageWidth: CGFloat? = nil,
                pageHeight: CGFloat? = nil,
                scrollActive: Binding<Bool> = .constant(false),
                scrollOffset: Binding<CGPoint>,
                zoomActive: Binding<Bool> = .constant(false),
                zoomScale: Binding<CGFloat> = .constant(1.0),
                containerSize: CGSize,
                contentSize: CGSize,
                minZoom: CGFloat = 0.25,
                maxZoom: CGFloat = 4.0,
                hasIndicators: Bool = true,
                canScroll: Binding<Bool> = .constant(true),
                canZoom: Bool = false,
                centering: Bool = false,
                content: @escaping () -> (Content) = { Color.clear })  {
        self.axis = axis
        self.padding = padding
        self.pageWidth = pageWidth
        self.pageHeight = pageHeight
        _scrollActive = scrollActive
        _scrollOffset = scrollOffset
        _zoomActive = zoomActive
        _zoomScale = zoomScale
        self.containerSize = containerSize
        self.contentSize = contentSize
        self.hasIndicators = hasIndicators
        self.minZoom = minZoom
        self.maxZoom = maxZoom
        _canScroll = canScroll
        self.canZoom = canZoom
        self.centering = centering
        self.content = content
    }
    
    public func makeView(context: Context) -> MPView {
        
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
        
        #if os(iOS)
        scrollView.minimumZoomScale = minZoom
        scrollView.maximumZoomScale = maxZoom
        #elseif os(macOS)
        scrollView.allowsMagnification = canZoom
        scrollView.minMagnification = minZoom
        scrollView.maxMagnification = maxZoom
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
        context.coordinator.contentView = view
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
        context.coordinator.didStartScroll = {
            scrollActive = true
        }
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
            scrollActive = false
            context.coordinator.firstDirection = nil
            context.coordinator.scrollStartOffset = nil
        }
        context.coordinator.didStartZoom = {
            zoomActive = true
        }
        context.coordinator.didEndZoom = {
            zoomActive = false
        }
        #endif
        
        var padding = padding
        if centering {
            let horizontal = contentSize.width < containerSize.width ? (containerSize.width - contentSize.width) / 2 : 0.0
            let vertical = contentSize.height < containerSize.height ? (containerSize.height - contentSize.height) / 2 : 0.0
            padding = UIEdgeInsets(top: vertical + padding.top,
                                   left: horizontal + padding.left,
                                   bottom: vertical + padding.bottom,
                                   right: horizontal + padding.right)
        }
        context.coordinator.padding = padding
        #if os(iOS)
        scrollView.contentInset = padding
        #elseif os(macOS)
        scrollView.contentInsets = padding
        #endif
        
        return scrollView
        
    }
    
    public func updateView(_ view: MPView, context: Context) {
        
        if context.coordinator.pageWidth != pageWidth {
            context.coordinator.pageWidth = pageWidth
        }
        if context.coordinator.pageHeight != pageHeight {
            context.coordinator.pageHeight = pageHeight
        }
        
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
        
        let contentSize: CGSize = contentSize * zoomScale
        let contentOffset: CGPoint = remapIn(offset: scrollOffset)
        let couldNotScroll: Bool = scrollView.contentSize.width < containerSize.width && scrollView.contentSize.height < containerSize.height
        let canNotScroll: Bool = contentSize.width < containerSize.width && contentSize.height < containerSize.height
        func roundSize(_ size: CGSize) -> CGSize {
            CGSize(width: round(size.width), height: round(size.height))
        }
        let sizeIsNew: Bool = roundSize(scrollView.contentSize) != roundSize(contentSize)
        #if os(iOS)
        let offsetIsNew: Bool = !compare(scrollView.contentOffset, rhs: contentOffset)
        if offsetIsNew {
            scrollView.setContentOffset(contentOffset, animated: false)
        }
        if sizeIsNew {
            scrollView.contentSize = contentSize
        }
        if !couldNotScroll && canNotScroll {
            RunLoop.current.add(Timer(timeInterval: 0.1, repeats: false, block: { _ in
                scrollView.setContentOffset(CGPoint(x: -padding.left, y: -padding.top), animated: true)
            }), forMode: .common)
        }
        #elseif os(macOS)
        let offsetIsNew: Bool = scrollView.contentView.bounds.origin != contentOffset
        if offsetIsNew {
            scrollView.contentView.setBoundsOrigin(contentOffset)
        }
        if sizeIsNew {
            scrollView.documentView?.setFrameSize(contentSize)
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
        
        if canZoom {
            #if os(iOS)
            if zoomScale != scrollView.zoomScale {
                scrollView.zoomScale = zoomScale
            }
            #elseif os(macOS)
            if zoomScale != scrollView.magnification {
                scrollView.magnification = zoomScale
            }
            #endif
        }
    }
    
    public func makeCoordinator() -> MPScrollViewCoordinator {
        MPScrollViewCoordinator(containerSize: containerSize, contentSize: contentSize, padding: padding, pageWidth: pageWidth, pageHeight: pageHeight, scrollOffset: $scrollOffset, zoomScale: $zoomScale, canZoom: canZoom, centering: centering)
    }
    
    func compare(_ lhs: CGPoint, rhs: CGPoint) -> Bool {
        let lhs = CGPoint(x: round(lhs.x * 1_000_000) / 1_000_000,
                          y: round(lhs.y * 1_000_000) / 1_000_000)
        let rhs = CGPoint(x: round(rhs.x * 1_000_000) / 1_000_000,
                          y: round(rhs.y * 1_000_000) / 1_000_000)
        return lhs == rhs
    }
    
    func remapIn(offset: CGPoint) -> CGPoint {
        guard centering else { return offset }
        return offset - (containerSize - contentSize) / 2
    }
}

public class MPScrollViewCoordinator: NSObject {
    
    var padding: MPEdgeInsets
    
    let containerSize: CGSize
    let contentSize: CGSize
    
    var scrollView: MPScrollView!
    #if os(iOS)
    var contentView: UIView!
    #endif
    
    var pageWidth: CGFloat?
    var pageHeight: CGFloat?
    @Binding var scrollOffset: CGPoint
    @Binding var zoomScale: CGFloat
    
    var willScroll: Bool?
    var firstDirection: MVScrollDirection?
    
    var isScrolling: Bool = false
    var scrollStartOffset: CGPoint?
    
    var didStartScroll: (() -> ())?
    var didScroll: ((CGPoint) -> CGPoint?)?
    var didEndScroll: (() -> ())?
    
    let canZoom: Bool
    var didStartZoom: (() -> ())?
    var didEndZoom: (() -> ())?
    
    let centering: Bool

    init(containerSize: CGSize,
         contentSize: CGSize,
         padding: MPEdgeInsets,
         pageWidth: CGFloat?,
         pageHeight: CGFloat?,
         scrollOffset: Binding<CGPoint>,
         zoomScale: Binding<CGFloat>,
         canZoom: Bool,
         centering: Bool) {
        self.containerSize = containerSize
        self.contentSize = contentSize
        self.padding = padding
        self.pageWidth = pageWidth
        self.pageHeight = pageHeight
        _scrollOffset = scrollOffset
        _zoomScale = zoomScale
        self.canZoom = canZoom
        self.centering = centering
        super.init()
    }
    
    func remapOut(offset: CGPoint) -> CGPoint {
        guard centering else { return offset }
        return offset + (containerSize - contentSize) / 2
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
            self.scrollOffset = remapOut(offset: self.scrollView.contentView.bounds.origin)
            self.zoomScale = self.scrollView.magnification
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
        DispatchQueue.main.async {
            self.scrollOffset = self.remapOut(offset: contentOffset ?? scrollView.contentOffset)
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
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        canZoom ? contentView : nil
    }
    
    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        didStartZoom?()
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        DispatchQueue.main.async {
            self.zoomScale = scrollView.zoomScale
        }
    }
    
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        didEndZoom?()
    }
}

#endif

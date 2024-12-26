//
//  BindableScrollView.swift
//  
//
//  Created by Anton Heestand on 2022-10-21.
//

import SwiftUI
import CoreGraphicsExtensions

@available(iOS 16.0, macOS 13.0, *)
public struct BindableScrollView<Content: View>: View {
    
    @Binding var offset: CGFloat
    let isActive: Bool
    let isMoving: Bool?
    let isAnimated: Bool
    let animationDuration: TimeInterval?

    let axis: Axis
    let showsIndicators: Bool
    let content: () -> Content
    
    public init(axis: Axis = .vertical,
                showsIndicators: Bool = true,
                isActive: Bool = true,
                isMoving: Bool? = nil,
                isAnimated: Bool = false,
                animationDuration: TimeInterval? = nil,
                offset: Binding<CGFloat>,
                @ViewBuilder content: @escaping () -> Content) {
        self.axis = axis
        self.showsIndicators = showsIndicators
        self.isActive = isActive
        self.isMoving = isMoving
        self.isAnimated = isAnimated
        self.animationDuration = animationDuration
        _offset = offset
        self.content = content
    }
    
    @State private var isAnimating: Bool = false
    
    @State private var containerSize: CGSize = .one
    @State private var contentFrame: CGRect = .zero

    private var contentOrigin: CGFloat {
        switch axis {
        case .horizontal:
            return contentFrame.minX
        case .vertical:
            return contentFrame.minY
        }
    }
    
    private var containerLength: CGFloat {
        switch axis {
        case .horizontal:
            return containerSize.width
        case .vertical:
            return containerSize.height
        }
    }
    
    private var contentLength: CGFloat {
        switch axis {
        case .horizontal:
            return contentFrame.size.width
        case .vertical:
            return contentFrame.size.height
        }
    }
    
    @State private var id: UUID = UUID()
    
    private let prefix: String = "bindable-scroll-view"
    
    private var spaceIdentifier: String {
        "\(prefix)_\(id)_space"
    }
    
    private var contentIdentifier: String {
        "\(prefix)_\(id)_content"
    }
    
    public var body: some View {
     
        ScrollViewReader { scrollViewProxy in
            
            let scrollAxis: Axis.Set = axis == .vertical ? .vertical : .horizontal
            ScrollView(scrollAxis, showsIndicators: showsIndicators) {
                
                content()
                    .readGeometry(frame: $contentFrame, in: .named(spaceIdentifier))
                    .background(alignment: .topLeading) {
                        Color.clear
                            .id(contentIdentifier)
                            .frame(width: 0.0,
                                   height: 0.0)
                    }
            }
            .scrollDisabled(!isActive)
            .onChange(of: offset) { offset in
                guard isMoving != false else { return }
                guard offset != contentOrigin else { return }
                scroll(to: offset, with: scrollViewProxy, animated: isAnimated)
            }
            .onChange(of: contentOrigin) { contentOrigin in
                guard isMoving != true else { return }
                guard contentOrigin != offset else { return }
                offset = contentOrigin
            }
            .onAppear {
                DispatchQueue.main.async {
                    scroll(to: offset, with: scrollViewProxy, animated: false)
                }
            }
        }
        .readGeometry(size: $containerSize)
        .coordinateSpace(name: spaceIdentifier)
    }
    
    private func scroll(to offset: CGFloat, with scrollViewProxy: ScrollViewProxy, animated: Bool) {
        guard containerLength > 0.0
        else { return }
        let fraction = offset / containerLength
        let anchor = UnitPoint(x: axis == .horizontal ? fraction : 0.0,
                               y: axis == .vertical ? fraction : 0.0)
        if animated {
            isAnimating = true
            if let animationDuration {
                withAnimation(.easeInOut(duration: animationDuration)) {
                    scrollViewProxy.scrollTo(contentIdentifier, anchor: anchor)
                }
                Timer.scheduledTimer(withTimeInterval: animationDuration, repeats: false) { _ in
                    isAnimating = false
                }
            } else {
                if #available(iOS 17.0, macOS 14.0, visionOS 1.0, *) {
                    withAnimation(.easeInOut) {
                        scrollViewProxy.scrollTo(contentIdentifier, anchor: anchor)
                    } completion: {
                        isAnimating = false
                    }
                } else {
                    assertionFailure("Unsupported animation duration.")
                }
            }
        } else {
            scrollViewProxy.scrollTo(contentIdentifier, anchor: anchor)
        }
    }
}
